part of 'get_requisition_cubit.dart';

@freezed
abstract class GetRequisitionState with _$GetRequisitionState {
  const factory GetRequisitionState.initial() = _Initial;
  const factory GetRequisitionState.loading() = _Loading;
  const factory GetRequisitionState.loaded({
    required PRFRequisition requisition,
  }) = _Loaded;
  const factory GetRequisitionState.error(String message) = _Error;
}
