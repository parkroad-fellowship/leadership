part of 'get_requisition_item_cubit.dart';

@freezed
class GetRequisitionItemState with _$GetRequisitionItemState {
  const factory GetRequisitionItemState.initial() = _Initial;
  const factory GetRequisitionItemState.loading() = _Loading;
  const factory GetRequisitionItemState.loaded({
    required PRFRequisitionItem requisitionItem,
  }) = _Loaded;
  const factory GetRequisitionItemState.error(String message) = _Error;
}
