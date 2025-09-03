part of 'update_requisition_cubit.dart';

@freezed
abstract class UpdateRequisitionState with _$UpdateRequisitionState {
  const factory UpdateRequisitionState.initial() = _Initial;
  const factory UpdateRequisitionState.loading() = _Loading;
  const factory UpdateRequisitionState.loaded() = _Loaded;
  const factory UpdateRequisitionState.error(String message) = _Error;
}
