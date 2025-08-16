part of 'get_requisitions_cubit.dart';

@freezed
class GetRequisitionsState with _$GetRequisitionsState {
  const factory GetRequisitionsState.initial() = _Initial;
  const factory GetRequisitionsState.loading() = _Loading;
  const factory GetRequisitionsState.loaded({
    required List<PRFRequisition> requisitions,
  }) = _Loaded;
  const factory GetRequisitionsState.empty() = _Empty;
  const factory GetRequisitionsState.error(String message) = _Error;
}
