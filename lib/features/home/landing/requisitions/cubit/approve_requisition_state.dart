part of 'approve_requisition_cubit.dart';

@freezed
abstract class ApproveRequisitionState with _$ApproveRequisitionState {
  const factory ApproveRequisitionState.initial() = _Initial;
  const factory ApproveRequisitionState.loading() = _Loading;
  const factory ApproveRequisitionState.loaded() = _Loaded;
  const factory ApproveRequisitionState.error(String message) = _Error;
}
