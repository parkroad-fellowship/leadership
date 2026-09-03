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
    return dbService.filterBy(
      (mission) => [
        filters?['upcoming'] == null || mission.endDate.isAfter(DateTime.now()),
        filters?['past'] == null || mission.endDate.isBefore(DateTime.now()),
        filters?['status_keys'] == null ||
            (filters!['status_keys'] as String)
                .split(',')
                .contains(mission.status.apiKey.toString()),
        filters?['search'] == null ||
            (mission.school?.name.toLowerCase().contains(
                  (filters!['search'] as String).toLowerCase(),
                ) ??
                false),
      ],
    );
  }

  Future<void> loadUpcomingMissions() {
    _lastListFilters = {'upcoming': true};
    return loadAll(
      filters: _lastListFilters,
      sortBy: 'start_date',
    );
  }

  Future<void> loadPastMissions() {
    _lastListFilters = {'past': true};
    return loadAll(
      filters: _lastListFilters,
      sortBy: 'start_date',
    );
  }

  Future<void> createMission({required PRFMissionDTO dto}) async {
    await create(data: dto.toJson());
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
  }

  Future<void> deleteMission({required String missionUlid}) async {
    await delete(
      ulid: missionUlid,
      matchById: (mission) => mission.ulid == missionUlid,
    );
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
      await action();

      // The action only returns a bool (nothing was written to Hive), so
      // refresh just the affected mission and persist it — the DB stream
      // re-emits the list state.
      final mission = await _missionService.get(
        ulid: missionUlid,
        includes: defaultIncludes,
      );
      await dbService.persistEntity(mission);
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
}
