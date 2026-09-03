import 'package:leadership/models/remote/prf_mission_type.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class MissionTypeHiveDbService extends BaseHiveDbService<PRFMissionType> {
  @override
  String get boxName => 'prf_mission_types';

  @override
  String getKey(PRFMissionType entity) => entity.ulid;

  @override
  PRFMissionType fromJson(Map<String, dynamic> json) =>
      PRFMissionType.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFMissionType entity) => entity.toJson();
}
