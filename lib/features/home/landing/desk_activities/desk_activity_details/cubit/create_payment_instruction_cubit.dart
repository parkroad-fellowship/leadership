import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_payment_method.dart';
import 'package:leadership/models/remote/prf_payment_instruction_dto.dart';
import 'package:leadership/services/api/payment_instruction_service.dart';

part 'create_payment_instruction_state.dart';
part 'create_payment_instruction_cubit.freezed.dart';

class CreatePaymentInstructionCubit
    extends Cubit<CreatePaymentInstructionState> {
  CreatePaymentInstructionCubit({
    required PaymentInstructionService paymentInstructionService,
  }) : _paymentInstructionService = paymentInstructionService,
       super(const CreatePaymentInstructionState.initial());

  final PaymentInstructionService _paymentInstructionService;

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
  }) async {
    try {
      emit(const CreatePaymentInstructionState.loading());

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

      await _paymentInstructionService.create(data: dto.toJson());

      emit(const CreatePaymentInstructionState.loaded());
    } catch (e) {
      emit(CreatePaymentInstructionState.error(e.toString()));
    }
  }
}
