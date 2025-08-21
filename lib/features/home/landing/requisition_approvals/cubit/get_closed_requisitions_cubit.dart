import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_approval_status.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/services/api/requisition_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';

part 'get_closed_requisitions_state.dart';
part 'get_closed_requisitions_cubit.freezed.dart';

class GetClosedRequisitionsCubit extends Cubit<GetClosedRequisitionsState> {
  GetClosedRequisitionsCubit({
    required RequisitionService requisitionService,
    required HiveService hiveService,
  }) : super(const GetClosedRequisitionsState.initial()) {
    _hiveService = hiveService;
    _requisitionService = requisitionService;
  }

  late RequisitionService _requisitionService;
  late HiveService _hiveService;

  Future<void> getClosedRequisitions() async {
    emit(const GetClosedRequisitionsState.loading());

    try {
      final member = _hiveService.retrieveMember()!;

      final requisitions = await _requisitionService.list(
        includes: [
          'member',
        ],
        filters: {
          'appointed_approver_ulid': member.ulid,
          'approval_statuses': [
            PRFApprovalStatus.approved.apiKey,
            PRFApprovalStatus.rejected.apiKey,
          ],
        },
        orderBy: 'requisition_date',
      );

      if (requisitions.isEmpty) {
        emit(const GetClosedRequisitionsState.empty());
        return;
      }
      emit(GetClosedRequisitionsState.loaded(requisitions: requisitions));
    } on Failure catch (f) {
      emit(GetClosedRequisitionsState.error(f.message));
    } catch (e) {
      emit(GetClosedRequisitionsState.error(e.toString()));
    }
  }
}
