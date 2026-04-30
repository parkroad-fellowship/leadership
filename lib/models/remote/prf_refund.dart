import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';

part 'prf_refund.freezed.dart';
part 'prf_refund.g.dart';

@freezed
abstract class PRFRefund with _$PRFRefund {
  factory PRFRefund(
    String ulid,
    int amount,
    @JsonKey(name: 'deficit_amount') int deficitAmount,
    @JsonKey(name: 'confirmation_message') String confirmationMessage,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt, {
    @JsonKey(name: 'accounting_event') PRFAccountingEvent? accountingEvent,
  }) = _PRFRefund;

  factory PRFRefund.fromJson(Map<String, dynamic> json) =>
      _$PRFRefundFromJson(json);
}
