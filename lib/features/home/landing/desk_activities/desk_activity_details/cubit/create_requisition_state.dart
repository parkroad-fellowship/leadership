part of 'create_requisition_cubit.dart';

@freezed
class CreateRequisitionState with _$CreateRequisitionState {
  const factory CreateRequisitionState.initial() = _Initial;
  const factory CreateRequisitionState.loading() = _Loading;
  const factory CreateRequisitionState.loaded() = _Loaded;
  const factory CreateRequisitionState.error(String message) = _Error;
}
