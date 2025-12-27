part of 'delete_requisition_item_cubit.dart';

@freezed
abstract class DeleteRequisitionItemState with _$DeleteRequisitionItemState {
  const factory DeleteRequisitionItemState.initial() = _Initial;
  const factory DeleteRequisitionItemState.loading({required int index}) =
      _Loading;
  const factory DeleteRequisitionItemState.loaded() = _Loaded;
  const factory DeleteRequisitionItemState.error(String message) = _Error;
}
