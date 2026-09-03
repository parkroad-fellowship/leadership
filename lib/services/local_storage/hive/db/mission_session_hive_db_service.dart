import 'package:leadership/models/remote/mission/prf_mission_session.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class MissionSessionHiveDbService extends BaseHiveDbService<PRFMissionSession> {
  @override
  String get boxName => 'prf_mission_sessions';

  @override
  String getKey(PRFMissionSession entity) => entity.ulid;

  @override
  PRFMissionSession fromJson(Map<String, dynamic> json) =>
      PRFMissionSession.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFMissionSession entity) => entity.toJson();
}
