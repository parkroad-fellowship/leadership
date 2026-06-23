import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class MissionHiveDbService extends BaseHiveDbService<PRFMission> {
  @override
  String get boxName => 'prf_missions';

  @override
  String getKey(PRFMission entity) => entity.ulid;

  @override
  PRFMission fromJson(Map<String, dynamic> json) => PRFMission.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFMission entity) => entity.toJson();
}
