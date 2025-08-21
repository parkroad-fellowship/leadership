part of 'create_requisition_item_cubit.dart';

@freezed
abstract class CreateRequisitionItemState with _$CreateRequisitionItemState {
  const factory CreateRequisitionItemState.initial() = _Initial;
  const factory CreateRequisitionItemState.loading() = _Loading;
  const factory CreateRequisitionItemState.loaded() = _Loaded;
  const factory CreateRequisitionItemState.error(String message) = _Error;
}
