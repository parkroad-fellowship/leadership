import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_responsible_desk.dart';
import 'package:leadership/models/remote/prf_refund.dart';

part 'prf_accounting_event.freezed.dart';
part 'prf_accounting_event.g.dart';

@freezed
abstract class PRFAccountingEvent with _$PRFAccountingEvent {
  factory PRFAccountingEvent(
    String ulid,
    String name,
    @JsonKey(name: 'due_date') DateTime dueDate,
    @JsonEnum()
    @JsonKey(name: 'responsible_desk')
    PRFResponsibleDesk responsibleDesk,
    int credits,
    int debits,
    int balance,
    @JsonKey(name: 'refund_charge') int refundCharge,
    @JsonKey(name: 'amount_to_refund') int amountToRefund,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt, {
    @Default([]) List<PRFRefund> refunds,
    @JsonKey(name: 'latest_refund') PRFRefund? latestRefund,
  }) = _PRFAccountingEvent;

  factory PRFAccountingEvent.fromJson(Map<String, dynamic> json) =>
      _$PRFAccountingEventFromJson(json);
}
