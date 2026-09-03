import 'package:leadership/models/remote/prf_marital_status.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class MaritalStatusHiveDbService extends BaseHiveDbService<PRFMaritalStatus> {
  @override
  String get boxName => 'prf_marital_statuses';

  @override
  String getKey(PRFMaritalStatus entity) => entity.ulid;

  @override
  PRFMaritalStatus fromJson(Map<String, dynamic> json) =>
      PRFMaritalStatus.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFMaritalStatus entity) => entity.toJson();
}
