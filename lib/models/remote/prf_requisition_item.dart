import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/models/remote/prf_requisition.dart';

part 'prf_requisition_item.freezed.dart';
part 'prf_requisition_item.g.dart';

@freezed
abstract class PRFRequisitionItem with _$PRFRequisitionItem {
  factory PRFRequisitionItem(
    String ulid,
    @JsonKey(name: 'item_name') String itemName,
    @JsonKey(name: 'unit_price') int unitPrice,
    int quantity,
    @JsonKey(name: 'total_price') int totalPrice,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt, {
    String? narration,
    PRFRequisition? requisition,
    @JsonKey(name: 'expense_category') PRFExpenseCategory? expenseCategory,
  }) = _PRFRequisitionItem;

  factory PRFRequisitionItem.fromJson(Map<String, dynamic> json) =>
      _$PRFRequisitionItemFromJson(json);
}

@freezed
abstract class PRFRequisitionItemsResponse with _$PRFRequisitionItemsResponse {
  factory PRFRequisitionItemsResponse(
    List<PRFRequisitionItem> data,
  ) = _PRFRequisitionItemsResponse;

  factory PRFRequisitionItemsResponse.fromJson(Map<String, dynamic> json) =>
      _$PRFRequisitionItemsResponseFromJson(json);
}
