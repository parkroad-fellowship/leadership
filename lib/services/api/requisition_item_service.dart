import 'package:leadership/models/remote/prf_requisition_item.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class RequisitionItemService extends BaseAPIService<PRFRequisitionItem> {
  @override
  String get endpoint => '/requisition-items';

  @override
  PRFRequisitionItem createFromJson(Map<String, dynamic> json) {
    return PRFRequisitionItem.fromJson(json);
  }

  @override
  List<PRFRequisitionItem> createListFromResponse(
    Map<String, dynamic> response,
  ) {
    return PRFRequisitionItemsResponse.fromJson(response).data;
  }
}
