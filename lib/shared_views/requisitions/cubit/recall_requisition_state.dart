part of 'recall_requisition_cubit.dart';

@freezed
class RecallRequisitionState with _$RecallRequisitionState {
  const factory RecallRequisitionState.initial() = _Initial;
  const factory RecallRequisitionState.loading() = _Loading;
  const factory RecallRequisitionState.loaded() = _Loaded;
  const factory RecallRequisitionState.error(String message) = _Error;
}
