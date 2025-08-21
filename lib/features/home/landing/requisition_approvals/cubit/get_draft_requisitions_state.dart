part of 'get_draft_requisitions_cubit.dart';

@freezed
class GetDraftRequisitionsState with _$GetDraftRequisitionsState {
  const factory GetDraftRequisitionsState.initial() = _Initial;
  const factory GetDraftRequisitionsState.loading() = _Loading;
  const factory GetDraftRequisitionsState.loaded({
    required List<PRFRequisition> requisitions,
  }) = _Loaded;
  const factory GetDraftRequisitionsState.empty() = _Empty;
  const factory GetDraftRequisitionsState.error(String message) = _Error;
}
