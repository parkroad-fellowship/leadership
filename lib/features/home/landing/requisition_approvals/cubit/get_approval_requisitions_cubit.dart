import 'package:leadership/enums/prf_approval_status.dart';
import 'package:leadership/features/home/landing/requisition_approvals/cubit/requisition_approval_list_cubit.dart';

// Get requisitions that need logged in user's approval
class GetApprovalRequisitionsCubit extends RequisitionApprovalListCubit {
  GetApprovalRequisitionsCubit({
    required super.requisitionService,
    required super.hiveService,
  });

  Future<void> getApprovalRequisitions() async {
    final member = hiveService.retrieveMember()!;

    await loadRequisitions(
      filters: {
        'appointed_approver_ulid': member.ulid,
        'approval_status': PRFApprovalStatus.underReview.apiKey,
      },
    );
  }
}
