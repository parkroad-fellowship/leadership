import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:leadership/models/remote/prf_mission_dto.dart';
import 'package:leadership/services/api/mission_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:logger/logger.dart';

class MissionResourceCubit extends ResourceCubit<PRFMission> {
  MissionResourceCubit({required MissionService missionService})
    : _missionService = missionService,
      super(service: missionService);

  final MissionService _missionService;

  String? _lastMissionUlid;
  Map<String, dynamic>? _lastListFilters;
  String? _lastOrderDirection;

  @override
  List<String> get defaultIncludes => [
    'school',
    'missionType',
    'school.schoolContacts.contactType',
    'accountingEvent',
    'schoolTerm',
    'weatherForecasts',
    'missionType',
  ];

  PRFMission? get currentMission {
    if (currentItems.isEmpty) {
      return null;
    }
    return currentItems.first;
  }

  Future<void> loadUpcomingMissions() {
    _lastMissionUlid = null;
    _lastListFilters = {'upcoming': true};
    _lastOrderDirection = 'asc';
    return loadAll(
      filters: _lastListFilters,
      orderBy: 'start_date',
      orderDirection: _lastOrderDirection,
    );
  }

  Future<void> loadPastMissions() {
    _lastMissionUlid = null;
    _lastListFilters = {'past': true};
    _lastOrderDirection = 'desc';
    return loadAll(
      filters: _lastListFilters,
      orderBy: 'start_date',
      orderDirection: _lastOrderDirection,
    );
  }

  Future<void> loadMission({required String missionUlid}) async {
    _lastMissionUlid = missionUlid;
    _lastListFilters = null;

    emit(const ResourceState<PRFMission>.listLoading());
    try {
      final mission = await _missionService.get(
        ulid: missionUlid,
        includes: [
          ...defaultIncludes,
        ],
      );
      emit(ResourceState<PRFMission>.listLoaded(items: [mission]));
    } on Failure catch (e, s) {
      Logger().e('Error loading mission', error: e, stackTrace: s);
      emit(ResourceState<PRFMission>.error(message: e.message));
    } catch (e, s) {
      Logger().e('Error loading mission', error: e, stackTrace: s);
      emit(ResourceState<PRFMission>.error(message: e.toString()));
    }
  }

  Future<void> createMission({required PRFMissionDTO dto}) async {
    await create(data: dto.toJson());
    await _reloadContext();
  }

  Future<void> updateMission({
    required String missionUlid,
    required PRFMissionDTO dto,
  }) async {
    await update(
      id: missionUlid,
      data: dto.toJson(),
      matchById: (mission) => mission.ulid == missionUlid,
    );
    await _reloadContext();
  }

  Future<void> deleteMission({required String missionUlid}) async {
    await delete(
      ulid: missionUlid,
      matchById: (mission) => mission.ulid == missionUlid,
    );
    await _reloadContext();
  }

  Future<void> approveMission({required String missionUlid}) {
    return _runAction(
      missionUlid: missionUlid,
      action: () => _missionService.approveMission(ulid: missionUlid),
    );
  }

  Future<void> rejectMission({
    required String missionUlid,
    String? reason,
  }) {
    return _runAction(
      missionUlid: missionUlid,
      action: () => _missionService.rejectMission(
        ulid: missionUlid,
        reason: reason,
      ),
    );
  }

  Future<void> cancelMission({
    required String missionUlid,
    String? reason,
  }) {
    return _runAction(
      missionUlid: missionUlid,
      action: () => _missionService.cancelMission(
        ulid: missionUlid,
        reason: reason,
      ),
    );
  }

  Future<void> completeMission({required String missionUlid}) {
    return _runAction(
      missionUlid: missionUlid,
      action: () => _missionService.completeMission(ulid: missionUlid),
    );
  }

  Future<void> notifySchool({required String missionUlid}) {
    return _runAction(
      missionUlid: missionUlid,
      action: () => _missionService.notifySchool(ulid: missionUlid),
    );
  }

  Future<void> requestSchoolFeedback({required String missionUlid}) {
    return _runAction(
      missionUlid: missionUlid,
      action: () => _missionService.requestSchoolFeedback(ulid: missionUlid),
    );
  }

  Future<void> notifyWhatsappGroup({required String missionUlid}) {
    return _runAction(
      missionUlid: missionUlid,
      action: () => _missionService.notifyWhatsappGroup(ulid: missionUlid),
    );
  }

  Future<void> generateSummary({required String missionUlid}) {
    return _runAction(
      missionUlid: missionUlid,
      action: () => _missionService.generateSummary(ulid: missionUlid),
    );
  }

  Future<void> uploadMediaToDrive({required String missionUlid}) {
    return _runAction(
      missionUlid: missionUlid,
      action: () => _missionService.uploadMediaToDrive(ulid: missionUlid),
    );
  }

  Future<void> makeZeroRequisition({required String missionUlid}) {
    return _runAction(
      missionUlid: missionUlid,
      action: () => _missionService.makeZeroRequisition(ulid: missionUlid),
    );
  }

  Future<void> _runAction({
    required String missionUlid,
    required Future<bool> Function() action,
  }) async {
    emit(
      ResourceState<PRFMission>.mutating(
        items: currentItems,
        operation: ResourceOperation.update,
      ),
    );

    try {
      _lastMissionUlid = missionUlid;
      await action();

      emit(
        ResourceState<PRFMission>.mutated(
          items: currentItems,
          operation: ResourceOperation.update,
        ),
      );

      await _reloadContext();
    } on Failure catch (e) {
      emit(
        ResourceState<PRFMission>.error(
          message: e.message,
          items: currentItems,
        ),
      );
    } catch (e) {
      emit(
        ResourceState<PRFMission>.error(
          message: e.toString(),
          items: currentItems,
        ),
      );
    }
  }

  Future<void> _reloadContext() async {
    if (_lastMissionUlid != null) {
      await loadMission(missionUlid: _lastMissionUlid!);
      return;
    }

    if (_lastListFilters != null) {
      await loadAll(
        filters: _lastListFilters,
        orderBy: 'start_date',
        orderDirection: _lastOrderDirection,
      );
    }
  }
}
