import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:leadership/services/api/mission_service.dart';
import 'package:leadership/services/local_storage/hive/db/mission_hive_db_service.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:leadership/utils/crud/single_resource_cubit.dart';

class MissionDetailCubit extends SingleResourceCubit<PRFMission> {
  MissionDetailCubit({
    required MissionService missionService,
    required MissionHiveDbService hiveDbService,
  }) : _missionService = missionService,
       super(service: missionService, dbService: hiveDbService);

  final MissionService _missionService;

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

  Future<void> approveMission({required String missionUlid}) {
    return _runAction(
      action: () => _missionService.approveMission(ulid: missionUlid),
      missionUlid: missionUlid,
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
      missionUlid: missionUlid,
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
      missionUlid: missionUlid,
    );
  }

  Future<void> completeMission({required String missionUlid}) {
    return _runAction(
      action: () => _missionService.completeMission(ulid: missionUlid),
      missionUlid: missionUlid,
    );
  }

  Future<void> notifySchool({required String missionUlid}) {
    return _runAction(
      action: () => _missionService.notifySchool(ulid: missionUlid),
      missionUlid: missionUlid,
    );
  }

  Future<void> requestSchoolFeedback({required String missionUlid}) {
    return _runAction(
      action: () => _missionService.requestSchoolFeedback(ulid: missionUlid),
      missionUlid: missionUlid,
    );
  }

  Future<void> notifyWhatsappGroup({required String missionUlid}) {
    return _runAction(
      action: () => _missionService.notifyWhatsappGroup(ulid: missionUlid),
      missionUlid: missionUlid,
    );
  }

  Future<void> generateSummary({required String missionUlid}) {
    return _runAction(
      action: () => _missionService.generateSummary(ulid: missionUlid),
      missionUlid: missionUlid,
    );
  }

  Future<void> uploadMediaToDrive({required String missionUlid}) {
    return _runAction(
      action: () => _missionService.uploadMediaToDrive(ulid: missionUlid),
      missionUlid: missionUlid,
    );
  }

  Future<void> makeZeroRequisition({required String missionUlid}) {
    return _runAction(
      action: () => _missionService.makeZeroRequisition(ulid: missionUlid),
      missionUlid: missionUlid,
    );
  }

  Future<void> _runAction({
    required Future<bool> Function() action,
    required String missionUlid,
  }) async {
    emit(ResourceState.itemLoading(item: currentItem));

    try {
      await action();
      await loadOne(
        id: missionUlid,
        matchById: (m) => m.ulid == missionUlid,
        refresh: true,
      );
    } on Failure catch (e) {
      emit(
        ResourceState.itemError(
          message: e.message,
          item: currentItem,
        ),
      );
    } catch (e) {
      emit(
        ResourceState.itemError(
          message: e.toString(),
          item: currentItem,
        ),
      );
    }
  }
}
