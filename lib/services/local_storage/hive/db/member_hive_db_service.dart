import 'package:leadership/models/remote/prf_member.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class MemberHiveDbService extends BaseHiveDbService<PRFMember> {
  @override
  String get boxName => 'prf_members';

  @override
  String getKey(PRFMember entity) => entity.ulid;

  @override
  PRFMember fromJson(Map<String, dynamic> json) => PRFMember.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFMember entity) => entity.toJson();
}
