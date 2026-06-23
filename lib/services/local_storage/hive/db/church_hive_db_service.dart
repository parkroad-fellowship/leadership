import 'package:leadership/models/remote/prf_church.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class ChurchHiveDbService extends BaseHiveDbService<PRFChurch> {
  @override
  String get boxName => 'prf_churches';

  @override
  String getKey(PRFChurch entity) => entity.ulid;

  @override
  PRFChurch fromJson(Map<String, dynamic> json) => PRFChurch.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFChurch entity) => entity.toJson();
}
