import 'package:leadership/models/remote/prf_school_term.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class SchoolTermHiveDbService extends BaseHiveDbService<PRFSchoolTerm> {
  @override
  String get boxName => 'prf_school_terms';

  @override
  String getKey(PRFSchoolTerm entity) => entity.ulid;

  @override
  PRFSchoolTerm fromJson(Map<String, dynamic> json) =>
      PRFSchoolTerm.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFSchoolTerm entity) => entity.toJson();
}
