import 'package:leadership/models/remote/prf_gift.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class GiftHiveDbService extends BaseHiveDbService<PRFGift> {
  @override
  String get boxName => 'prf_gifts';

  @override
  String getKey(PRFGift entity) => entity.ulid;

  @override
  PRFGift fromJson(Map<String, dynamic> json) => PRFGift.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFGift entity) => entity.toJson();
}
