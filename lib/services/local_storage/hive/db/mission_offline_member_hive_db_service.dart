import 'package:leadership/models/remote/mission/prf_mission_offline_member.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class MissionOfflineMemberHiveDbService
    extends BaseHiveDbService<PRFMissionOfflineMember> {
  @override
  String get boxName => 'prf_mission_offline_members';

  @override
  String getKey(PRFMissionOfflineMember entity) => entity.ulid;

  @override
  PRFMissionOfflineMember fromJson(Map<String, dynamic> json) =>
      PRFMissionOfflineMember.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFMissionOfflineMember entity) =>
      entity.toJson();
}
