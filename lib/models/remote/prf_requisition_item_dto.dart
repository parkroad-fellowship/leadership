import 'package:freezed_annotation/freezed_annotation.dart';

part 'prf_requisition_item_dto.freezed.dart';
part 'prf_requisition_item_dto.g.dart';

@freezed
abstract class PRFRequisitionItemDTO with _$PRFRequisitionItemDTO {
  factory PRFRequisitionItemDTO({
    @JsonKey(name: 'requisition_ulid') required String requisitionUlid,
    @JsonKey(name: 'expense_category_ulid') required String expenseCategoryUlid,
    @JsonKey(name: 'item_name') required String itemName,
    @JsonKey(name: 'unit_price') required int unitPrice,
    required int quantity,
    @JsonKey(includeIfNull: false) String? narration,
  }) = _PRFRequisitionItemDTO;

  factory PRFRequisitionItemDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFRequisitionItemDTOFromJson(json);
}
