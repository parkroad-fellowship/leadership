part of 'reject_requisition_cubit.dart';

@freezed
abstract class RejectRequisitionState with _$RejectRequisitionState {
  const factory RejectRequisitionState.initial() = _Initial;
  const factory RejectRequisitionState.loading() = _Loading;
  const factory RejectRequisitionState.loaded() = _Loaded;
  const factory RejectRequisitionState.error(String message) = _Error;
}
