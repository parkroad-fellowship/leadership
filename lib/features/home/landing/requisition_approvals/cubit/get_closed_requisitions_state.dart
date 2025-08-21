part of 'get_closed_requisitions_cubit.dart';

@freezed
class GetClosedRequisitionsState with _$GetClosedRequisitionsState {
  const factory GetClosedRequisitionsState.initial() = _Initial;
  const factory GetClosedRequisitionsState.loading() = _Loading;
  const factory GetClosedRequisitionsState.loaded({
    required List<PRFRequisition> requisitions,
  }) = _Loaded;
  const factory GetClosedRequisitionsState.empty() = _Empty;
  const factory GetClosedRequisitionsState.error(String message) = _Error;
}
