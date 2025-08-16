import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/services/api/requisition_service.dart';

part 'get_requisitions_state.dart';
part 'get_requisitions_cubit.freezed.dart';

class GetRequisitionsCubit extends Cubit<GetRequisitionsState> {
  GetRequisitionsCubit({
    required RequisitionService requisitionService,
  }) : super(const GetRequisitionsState.initial()) {
    _requisitionService = requisitionService;
  }

  late RequisitionService _requisitionService;

  Future<void> getRequisitions({
    required String accountingEventUlid,
  }) async {
    emit(const GetRequisitionsState.loading());
    try {
      final requisitions = await _requisitionService.list(
        filters: {
          'accounting_event_ulid': accountingEventUlid,
        },
        includes: [
          'member',
          'appointedApprover',
          'approvedBy',
        ],
      );
      if (requisitions.isEmpty) {
        emit(const GetRequisitionsState.empty());
      } else {
        emit(GetRequisitionsState.loaded(requisitions: requisitions));
      }
    } catch (e) {
      emit(GetRequisitionsState.error(e.toString()));
    }
  }
}
