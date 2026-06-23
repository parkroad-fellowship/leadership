import 'package:leadership/models/remote/prf_requisition_item.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class RequisitionItemHiveDbService
    extends BaseHiveDbService<PRFRequisitionItem> {
  @override
  String get boxName => 'prf_requisition_items';

  @override
  String getKey(PRFRequisitionItem entity) => entity.ulid;

  @override
  PRFRequisitionItem fromJson(Map<String, dynamic> json) =>
      PRFRequisitionItem.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFRequisitionItem entity) => entity.toJson();
}
