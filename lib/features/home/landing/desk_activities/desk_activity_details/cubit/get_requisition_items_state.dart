part of 'get_requisition_items_cubit.dart';

@freezed
class GetRequisitionItemsState with _$GetRequisitionItemsState {
  const factory GetRequisitionItemsState.initial() = _Initial;
  const factory GetRequisitionItemsState.loading() = _Loading;
  const factory GetRequisitionItemsState.loaded({
    required List<PRFRequisitionItem> requisitionItems,
  }) = _Loaded;
  const factory GetRequisitionItemsState.empty() = _Empty;
  const factory GetRequisitionItemsState.error(String message) = _Error;
}
