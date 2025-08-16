import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/services/api/requisition_service.dart';

part 'get_requisition_state.dart';
part 'get_requisition_cubit.freezed.dart';

class GetRequisitionCubit extends Cubit<GetRequisitionState> {
  GetRequisitionCubit({
    required RequisitionService requisitionService,
  }) : super(GetRequisitionState.initial()) {
    _requisitionService = requisitionService;
  }

  late RequisitionService _requisitionService;

  Future<void> getRequisition({
    required String requisitionUlid,
  }) async {
    emit(GetRequisitionState.loading());

    try {
      final requisition = await _requisitionService.get(
        ulid: requisitionUlid,
        includes: [
          'member',
          'appointedApprover',
          'approvedBy',
          'paymentInstruction',
        ],
      );
      emit(GetRequisitionState.loaded(requisition: requisition));
    } on Failure catch (f) {
      emit(GetRequisitionState.error(f.message));
    } catch (e) {
      emit(GetRequisitionState.error(e.toString()));
    }
  }
}
