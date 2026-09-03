import 'package:leadership/models/remote/mission/prf_mission_session.dart';
import 'package:leadership/services/api/mission_session_service.dart';
import 'package:leadership/services/local_storage/hive/db/mission_session_hive_db_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class MissionSessionResourceCubit extends ResourceCubit<PRFMissionSession> {
  MissionSessionResourceCubit({
    required MissionSessionService missionSessionService,
    required MissionSessionHiveDbService hiveDbService,
  }) : super(service: missionSessionService, dbService: hiveDbService);

  @override
  Future<List<PRFMissionSession>> loadCachedList({
    Map<String, dynamic>? filters,
  }) async {
    return dbService.list();
  }

  @override
  List<String> get defaultIncludes => [
    'facilitator',
    'speaker',
    'classGroup',
  ];

  Future<void> loadForMission({required String missionUlid}) {
    return loadAll(
      filters: {'mission_ulid': missionUlid},
      includes: defaultIncludes,
      sortBy: 'starts_at',
      limit: 200,
    );
  }
}
