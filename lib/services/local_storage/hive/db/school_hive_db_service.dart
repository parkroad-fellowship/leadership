import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class SchoolHiveDbService extends BaseHiveDbService<PRFSchool> {
  @override
  String get boxName => 'prf_schools';

  @override
  String getKey(PRFSchool entity) => entity.ulid;

  @override
  PRFSchool fromJson(Map<String, dynamic> json) => PRFSchool.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFSchool entity) => entity.toJson();
}
