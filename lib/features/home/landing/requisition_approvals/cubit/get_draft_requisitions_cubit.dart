import 'package:leadership/enums/prf_approval_status.dart';
import 'package:leadership/features/home/landing/requisition_approvals/cubit/requisition_approval_list_cubit.dart';

class GetDraftRequisitionsCubit extends RequisitionApprovalListCubit {
  GetDraftRequisitionsCubit({
    required super.requisitionService,
    required super.hiveService,
  });

  Future<void> getDraftRequisitions() async {
    await loadRequisitions(
      filters: {
        'responsible_desks': hiveService.responsibleDesks
            .map((desk) => desk.apiKey)
            .toList()
            .join(','),
        'approval_statuses': [
          PRFApprovalStatus.pending.apiKey,
        ].join(','),
      },
    );
  }
}
