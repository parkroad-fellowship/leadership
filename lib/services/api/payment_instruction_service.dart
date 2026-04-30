import 'package:leadership/models/remote/prf_payment_instruction.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class PaymentInstructionService extends BaseAPIService<PRFPaymentInstruction> {
  @override
  String get endpoint => '/payment-instructions';

  @override
  PRFPaymentInstruction createFromJson(Map<String, dynamic> json) {
    return PRFPaymentInstruction.fromJson(json);
  }

  @override
  List<PRFPaymentInstruction> createListFromResponse(
    Map<String, dynamic> response,
  ) {
    throw UnimplementedError(
      'PaymentInstructionService does not support list creation from response',
    );
  }
}
