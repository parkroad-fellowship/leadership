part of 'update_requisition_item_cubit.dart';

@freezed
class UpdateRequisitionItemState with _$UpdateRequisitionItemState {
  const factory UpdateRequisitionItemState.initial() = _Initial;
  const factory UpdateRequisitionItemState.loading() = _Loading;
  const factory UpdateRequisitionItemState.loaded() = _Loaded;
  const factory UpdateRequisitionItemState.error(String message) = _Error;
}
