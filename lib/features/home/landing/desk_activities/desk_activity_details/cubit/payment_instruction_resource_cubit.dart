import 'package:leadership/enums/prf_payment_method.dart';
import 'package:leadership/models/remote/prf_payment_instruction.dart';
import 'package:leadership/models/remote/prf_payment_instruction_dto.dart';
import 'package:leadership/services/api/payment_instruction_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class PaymentInstructionResourceCubit
    extends ResourceCubit<PRFPaymentInstruction> {
  PaymentInstructionResourceCubit({
    required PaymentInstructionService paymentInstructionService,
  }) : super(service: paymentInstructionService);

  Future<void> createPaymentInstruction({
    required String requisitionUlid,
    required PRFPaymentMethod paymentMethod,
    required String recipientName,
    String? reference,

    // MPESA
    String? mpesaPhoneNumber,

    // Bank
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountName,
    String? bankBranch,
    String? bankSwiftCode,

    // Paybill
    String? paybillNumber,
    String? paybillAccountNumber,

    // Till
    String? tillNumber,
  }) {
    final dto = PRFPaymentInstructionDTO(
      requisitionUlid: requisitionUlid,
      paymentMethod: paymentMethod,
      recipientName: recipientName,
      reference: reference,
      mpesaPhoneNumber: mpesaPhoneNumber,
      bankName: bankName,
      bankAccountNumber: bankAccountNumber,
      bankAccountName: bankAccountName,
      bankBranch: bankBranch,
      bankSwiftCode: bankSwiftCode,
      paybillNumber: paybillNumber,
      paybillAccountNumber: paybillAccountNumber,
      tillNumber: tillNumber,
    );

    return create(data: dto.toJson());
  }
}
