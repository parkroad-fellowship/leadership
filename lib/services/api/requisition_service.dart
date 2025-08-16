import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class RequisitionService extends BaseAPIService<PRFRequisition> {
  @override
  String get endpoint => '/requisitions';

  @override
  PRFRequisition createFromJson(Map<String, dynamic> json) {
    return PRFRequisition.fromJson(json);
  }

  @override
  List<PRFRequisition> createListFromResponse(
    Map<String, dynamic> response,
  ) {
    return PRFRequisitionResponse.fromJson(response).data;
  }
}
