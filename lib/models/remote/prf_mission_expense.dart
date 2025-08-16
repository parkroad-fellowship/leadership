import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/prf_expense.dart';

part 'prf_mission_expense.freezed.dart';
part 'prf_mission_expense.g.dart';

@freezed
abstract class PRFMissionExpense with _$PRFMissionExpense {
  factory PRFMissionExpense(
    String ulid,
    @JsonKey(name: 'amount_received') int amountReceived,
    @JsonKey(name: 'amount_spent') int amountSpent,
    int balance,
    @JsonKey(name: 'token_amount') int tokenAmount,
    @JsonKey(name: 'amount_to_refund') int amountToRefund,
    @JsonKey(name: 'amount_refunded') int amountRefunded,
    @JsonKey(name: 'refund_charge') int refundCharge,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt, {
    @JsonKey(name: 'is_refunded') required bool isRefunded,
    @Default([]) List<PRFExpense> expenses,
  }) = _PRFMissionExpense;

  factory PRFMissionExpense.fromJson(Map<String, dynamic> json) =>
      _$PRFMissionExpenseFromJson(json);
}
