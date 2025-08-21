import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_payment_method.dart';
import 'package:leadership/models/remote/prf_requisition.dart';

part 'prf_payment_instruction.freezed.dart';
part 'prf_payment_instruction.g.dart';

@freezed
abstract class PRFPaymentInstruction with _$PRFPaymentInstruction {
  factory PRFPaymentInstruction(
    String ulid,
    @JsonEnum() @JsonKey(name: 'payment_method') PRFPaymentMethod paymentMethod,
    @JsonKey(name: 'recipient_name') String recipientName, {
    String? reference,

    // MPESA
    @JsonKey(name: 'mpesa_phone_number') int? mpesaPhoneNumber,

    // Bank
    @JsonKey(name: 'bank_name') String? bankName,
    @JsonKey(name: 'bank_account_number') int? bankAccountNumber,
    @JsonKey(name: 'bank_account_name') String? bankAccountName,
    @JsonKey(name: 'bank_branch') String? bankBranch,
    @JsonKey(name: 'bank_swift_code') String? bankSwiftCode,

    // Paybill
    @JsonKey(name: 'paybill_number') int? paybillNumber,
    @JsonKey(name: 'paybill_account_number') String? paybillAccountNumber,

    // Till
    @JsonKey(name: 'till_number') int? tillNumber,

    PRFRequisition? requisition,
  }) = _PRFPaymentInstruction;

  factory PRFPaymentInstruction.fromJson(Map<String, dynamic> json) =>
      _$PRFPaymentInstructionFromJson(json);
}
