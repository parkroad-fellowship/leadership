part of 'get_approval_requisitions_cubit.dart';

@freezed
abstract class GetApprovalRequisitionsState
    with _$GetApprovalRequisitionsState {
  const factory GetApprovalRequisitionsState.initial() = _Initial;
  const factory GetApprovalRequisitionsState.loading() = _Loading;
  const factory GetApprovalRequisitionsState.loaded({
    required List<PRFRequisition> requisitions,
  }) = _Loaded;
  const factory GetApprovalRequisitionsState.empty() = _Empty;
  const factory GetApprovalRequisitionsState.error(String message) = _Error;
}
