import 'package:leadership/models/remote/mission/prf_soul.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class SoulHiveDbService extends BaseHiveDbService<PRFSoul> {
  @override
  String get boxName => 'prf_souls';

  @override
  String getKey(PRFSoul entity) => entity.ulid;

  @override
  PRFSoul fromJson(Map<String, dynamic> json) => PRFSoul.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFSoul entity) => entity.toJson();
}
