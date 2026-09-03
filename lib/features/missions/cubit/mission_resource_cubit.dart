import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:leadership/models/remote/prf_mission_dto.dart';
import 'package:leadership/services/api/mission_service.dart';
import 'package:leadership/services/local_storage/hive/db/mission_hive_db_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';

class MissionResourceCubit extends ResourceCubit<PRFMission> {
  MissionResourceCubit({
    required MissionService missionService,
    required MissionHiveDbService hiveDbService,
  }) : _missionService = missionService,
       super(service: missionService, dbService: hiveDbService);

  final MissionService _missionService;

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

  @override
  Future<List<PRFMission>> loadCachedList({
    Map<String, dynamic>? filters,
  }) async {
    return dbService.list();
  }

  Future<void> loadUpcomingMissions() {
    _lastListFilters = {'upcoming': true};
    _lastOrderDirection = 'asc';
    return loadAll(
      filters: _lastListFilters,
      orderBy: 'start_date',
      orderDirection: _lastOrderDirection,
    );
  }

  Future<void> loadPastMissions() {
    _lastListFilters = {'past': true};
    _lastOrderDirection = 'desc';
    return loadAll(
      filters: _lastListFilters,
      orderBy: 'start_date',
      orderDirection: _lastOrderDirection,
    );
  }

  Future<void> createMission({required PRFMissionDTO dto}) async {
    await create(data: dto.toJson());
    await _reloadListContext();
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
    await _reloadListContext();
  }

  Future<void> deleteMission({required String missionUlid}) async {
    await delete(
      ulid: missionUlid,
      matchById: (mission) => mission.ulid == missionUlid,
    );
    await _reloadListContext();
  }

  Future<void> approveMission({required String missionUlid}) {
    return _runAction(
      action: () => _missionService.approveMission(ulid: missionUlid),
    );
  }

  Future<void> rejectMission({
    required String missionUlid,
    String? reason,
  }) {
    return _runAction(
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
      action: () => _missionService.cancelMission(
        ulid: missionUlid,
        reason: reason,
      ),
    );
  }

  Future<void> completeMission({required String missionUlid}) {
    return _runAction(
      action: () => _missionService.completeMission(ulid: missionUlid),
    );
  }

  Future<void> notifySchool({required String missionUlid}) {
    return _runAction(
      action: () => _missionService.notifySchool(ulid: missionUlid),
    );
  }

  Future<void> requestSchoolFeedback({required String missionUlid}) {
    return _runAction(
      action: () => _missionService.requestSchoolFeedback(ulid: missionUlid),
    );
  }

  Future<void> notifyWhatsappGroup({required String missionUlid}) {
    return _runAction(
      action: () => _missionService.notifyWhatsappGroup(ulid: missionUlid),
    );
  }

  Future<void> generateSummary({required String missionUlid}) {
    return _runAction(
      action: () => _missionService.generateSummary(ulid: missionUlid),
    );
  }

  Future<void> uploadMediaToDrive({required String missionUlid}) {
    return _runAction(
      action: () => _missionService.uploadMediaToDrive(ulid: missionUlid),
    );
  }

  Future<void> makeZeroRequisition({required String missionUlid}) {
    return _runAction(
      action: () => _missionService.makeZeroRequisition(ulid: missionUlid),
    );
  }

  Future<void> _runAction({
    required Future<bool> Function() action,
  }) async {
    emit(
      ResourceState<PRFMission>.mutating(
        items: currentItems,
        operation: ResourceOperation.update,
      ),
    );

    try {
      await action();

      emit(
        ResourceState<PRFMission>.mutated(
          items: currentItems,
          operation: ResourceOperation.update,
        ),
      );

      await _reloadListContext();
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

  Future<void> _reloadListContext() async {
    if (_lastListFilters != null) {
      await loadAll(
        filters: _lastListFilters,
        orderBy: 'start_date',
        orderDirection: _lastOrderDirection,
      );
    }
  }
}
