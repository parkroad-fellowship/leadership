import 'package:leadership/models/remote/prf_class_group.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class ClassGroupHiveDbService extends BaseHiveDbService<PRFClassGroup> {
  @override
  String get boxName => 'prf_class_groups';

  @override
  String getKey(PRFClassGroup entity) => entity.ulid;

  @override
  PRFClassGroup fromJson(Map<String, dynamic> json) =>
      PRFClassGroup.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFClassGroup entity) => entity.toJson();
}
