import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class ContactTypeHiveDbService extends BaseHiveDbService<PRFContactType> {
  @override
  String get boxName => 'prf_contact_types';

  @override
  String getKey(PRFContactType entity) => entity.ulid;

  @override
  PRFContactType fromJson(Map<String, dynamic> json) =>
      PRFContactType.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFContactType entity) => entity.toJson();
}
