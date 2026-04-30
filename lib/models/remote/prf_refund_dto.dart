import 'package:freezed_annotation/freezed_annotation.dart';

part 'prf_refund_dto.freezed.dart';
part 'prf_refund_dto.g.dart';

@freezed
abstract class PRFRefundDTO with _$PRFRefundDTO {
  factory PRFRefundDTO({
    @JsonKey(name: 'accounting_event_ulid') required String accountingEventUlid,
    required int amount,
    @JsonKey(name: 'confirmation_message') required String confirmationMessage,
  }) = _PRFRefundDTO;

  factory PRFRefundDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFRefundDTOFromJson(json);
}
