import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_payment_method.dart';

part 'prf_payment_instruction_dto.freezed.dart';
part 'prf_payment_instruction_dto.g.dart';

@freezed
abstract class PRFPaymentInstructionDTO with _$PRFPaymentInstructionDTO {
  factory PRFPaymentInstructionDTO({
    @JsonKey(name: 'requisition_ulid') required String requisitionUlid,
    @JsonEnum()
    @JsonKey(name: 'payment_method')
    required PRFPaymentMethod paymentMethod,
    @JsonKey(name: 'recipient_name') required String recipientName,
    String? reference,

    // MPESA
    @JsonKey(name: 'mpesa_phone_number') String? mpesaPhoneNumber,

    // Bank
    @JsonKey(name: 'bank_name') String? bankName,
    @JsonKey(name: 'bank_account_number') String? bankAccountNumber,
    @JsonKey(name: 'bank_account_name') String? bankAccountName,
    @JsonKey(name: 'bank_branch') String? bankBranch,
    @JsonKey(name: 'bank_swift_code') String? bankSwiftCode,

    // Paybill
    @JsonKey(name: 'paybill_number') String? paybillNumber,
    @JsonKey(name: 'paybill_account_number') String? paybillAccountNumber,

    // Till
    @JsonKey(name: 'till_number') String? tillNumber,
  }) = _PRFPaymentInstructionDTO;

  factory PRFPaymentInstructionDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFPaymentInstructionDTOFromJson(json);
}
