import 'package:leadership/models/remote/prf_refund.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class RefundHiveDbService extends BaseHiveDbService<PRFRefund> {
  @override
  String get boxName => 'prf_refunds';

  @override
  String getKey(PRFRefund entity) => entity.ulid;

  @override
  PRFRefund fromJson(Map<String, dynamic> json) => PRFRefund.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFRefund entity) => entity.toJson();
}
