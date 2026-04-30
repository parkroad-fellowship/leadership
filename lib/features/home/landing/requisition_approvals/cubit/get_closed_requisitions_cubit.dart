import 'package:leadership/enums/prf_approval_status.dart';
import 'package:leadership/features/home/landing/requisition_approvals/cubit/requisition_approval_list_cubit.dart';

class GetClosedRequisitionsCubit extends RequisitionApprovalListCubit {
  GetClosedRequisitionsCubit({
    required super.requisitionService,
    required super.hiveService,
  });

  Future<void> getClosedRequisitions() async {
    final member = hiveService.retrieveMember()!;

    await loadRequisitions(
      filters: {
        'appointed_approver_ulid': member.ulid,
        'responsible_desks': hiveService.responsibleDesks
            .map((desk) => desk.apiKey)
            .toList()
            .join(','),
        'approval_statuses': [
          PRFApprovalStatus.approved.apiKey,
          PRFApprovalStatus.rejected.apiKey,
        ].join(','),
      },
    );
  }
}
