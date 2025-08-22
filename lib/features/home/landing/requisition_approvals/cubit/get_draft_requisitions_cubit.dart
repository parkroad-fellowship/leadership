import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_approval_status.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/services/api/requisition_service.dart';

part 'get_draft_requisitions_state.dart';
part 'get_draft_requisitions_cubit.freezed.dart';

class GetDraftRequisitionsCubit extends Cubit<GetDraftRequisitionsState> {
  GetDraftRequisitionsCubit({
    required RequisitionService requisitionService,
    required HiveService hiveService,
  }) : super(const GetDraftRequisitionsState.initial()) {
    _requisitionService = requisitionService;
    _hiveService = hiveService;
  }

  late RequisitionService _requisitionService;
  late HiveService _hiveService;

  Future<void> getDraftRequisitions() async {
    emit(const GetDraftRequisitionsState.loading());

    try {
      final requisitions = await _requisitionService.list(
        includes: [
          'member',
        ],
        filters: {
          'responsible_desks': _hiveService.responsibleDesks
              .map((desk) => desk.apiKey)
              .toList()
              .join(','),
          'approval_statuses': [
            PRFApprovalStatus.pending.apiKey,
          ].join(','),
        },
        orderBy: 'requisition_date',
      );

      if (requisitions.isEmpty) {
        emit(const GetDraftRequisitionsState.empty());
        return;
      }
      emit(GetDraftRequisitionsState.loaded(requisitions: requisitions));
    } on Failure catch (f) {
      emit(GetDraftRequisitionsState.error(f.message));
    } catch (e) {
      emit(GetDraftRequisitionsState.error(e.toString()));
    }
  }
}
