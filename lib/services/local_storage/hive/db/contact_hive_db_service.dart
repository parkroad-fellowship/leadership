import 'package:leadership/models/remote/prf_contact.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class ContactHiveDbService extends BaseHiveDbService<PRFContact> {
  @override
  String get boxName => 'prf_contacts';

  @override
  String getKey(PRFContact entity) => entity.ulid;

  @override
  PRFContact fromJson(Map<String, dynamic> json) => PRFContact.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFContact entity) => entity.toJson();
}
