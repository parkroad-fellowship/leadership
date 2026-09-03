import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class RequisitionHiveDbService extends BaseHiveDbService<PRFRequisition> {
  @override
  String get boxName => 'prf_requisitions';

  @override
  String getKey(PRFRequisition entity) => entity.ulid;

  @override
  PRFRequisition fromJson(Map<String, dynamic> json) =>
      PRFRequisition.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFRequisition entity) => entity.toJson();
}
