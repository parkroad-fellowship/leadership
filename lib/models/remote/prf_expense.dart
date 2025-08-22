import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_charge_type.dart';
import 'package:leadership/enums/prf_morph_types.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/models/remote/prf_media.dart';
import 'package:leadership/models/remote/prf_member.dart';

part 'prf_expense.freezed.dart';
part 'prf_expense.g.dart';

@freezed
abstract class PRFExpense with _$PRFExpense {
  factory PRFExpense(
    String ulid,
    @JsonEnum() @JsonKey(name: 'expenseable_type') PRFMorphType expenseableType,
    @JsonEnum() @JsonKey(name: 'charge_type') PRFChargeType chargeType,
    @JsonKey(name: 'unit_cost') int unitCost,
    int quantity,
    @JsonKey(name: 'line_total') int lineTotal,
    int charge,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt, {
    @Default('') String narration,
    @JsonKey(name: 'confirmation_message') String? confirmationMessage,
    @JsonKey(name: 'expense_category') PRFExpenseCategory? expenseCategory,
    PRFMember? member,
    @Default([]) @JsonKey(name: 'receipts') List<PRFMedia> receipts,
  }) = _PRFExpense;

  factory PRFExpense.fromJson(Map<String, dynamic> json) =>
      _$PRFExpenseFromJson(json);
}
