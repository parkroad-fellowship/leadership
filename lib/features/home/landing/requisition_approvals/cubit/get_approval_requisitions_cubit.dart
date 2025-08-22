import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_approval_status.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/services/api/requisition_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';

part 'get_approval_requisitions_state.dart';
part 'get_approval_requisitions_cubit.freezed.dart';

// Get requisitions that need logged in user's approval
class GetApprovalRequisitionsCubit extends Cubit<GetApprovalRequisitionsState> {
  GetApprovalRequisitionsCubit({
    required RequisitionService requisitionService,
    required HiveService hiveService,
  }) : super(const GetApprovalRequisitionsState.initial()) {
    _hiveService = hiveService;
    _requisitionService = requisitionService;
  }

  late RequisitionService _requisitionService;
  late HiveService _hiveService;

  Future<void> getApprovalRequisitions() async {
    emit(const GetApprovalRequisitionsState.loading());

    try {
      final member = _hiveService.retrieveMember()!;

      final requisitions = await _requisitionService.list(
        includes: [
          'member',
        ],
        filters: {
          'appointed_approver_ulid': member.ulid,
          'approval_status': PRFApprovalStatus.underReview.apiKey,
        },
        orderBy: 'requisition_date',
      );

      if (requisitions.isEmpty) {
        emit(const GetApprovalRequisitionsState.empty());
        return;
      }
      emit(GetApprovalRequisitionsState.loaded(requisitions: requisitions));
    } on Failure catch (f) {
      emit(GetApprovalRequisitionsState.error(f.message));
    } catch (e) {
      emit(GetApprovalRequisitionsState.error(e.toString()));
    }
  }
}
