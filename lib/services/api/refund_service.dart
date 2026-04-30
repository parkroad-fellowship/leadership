import 'package:leadership/models/remote/prf_refund.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class RefundService extends BaseAPIService<PRFRefund> {
  @override
  String get endpoint => '/refunds';

  @override
  PRFRefund createFromJson(Map<String, dynamic> json) {
    return PRFRefund.fromJson(json);
  }

  @override
  List<PRFRefund> createListFromResponse(
    Map<String, dynamic> response,
  ) {
    throw UnimplementedError();
  }
}
