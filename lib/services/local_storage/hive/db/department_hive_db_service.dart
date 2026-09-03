import 'package:leadership/models/remote/prf_department.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class DepartmentHiveDbService extends BaseHiveDbService<PRFDepartment> {
  @override
  String get boxName => 'prf_departments';

  @override
  String getKey(PRFDepartment entity) => entity.ulid;

  @override
  PRFDepartment fromJson(Map<String, dynamic> json) =>
      PRFDepartment.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFDepartment entity) => entity.toJson();
}
