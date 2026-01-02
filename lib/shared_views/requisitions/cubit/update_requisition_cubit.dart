import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_requisition_dto.dart';
import 'package:leadership/services/api/requisition_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';

part 'update_requisition_state.dart';
part 'update_requisition_cubit.freezed.dart';

class UpdateRequisitionCubit extends Cubit<UpdateRequisitionState> {
  UpdateRequisitionCubit({
    required RequisitionService requisitionService,
    required HiveService hiveService,
  }) : super(const UpdateRequisitionState.initial()) {
    _requisitionService = requisitionService;
    _hiveService = hiveService;
  }

  late RequisitionService _requisitionService;
  late HiveService _hiveService;

  Future<void> updateRequisition({
    required String requisitionUlid,
    required PRFAccountingEvent accountingEvent,
    required DateTime requisitionDate,
    required String remarks,
  }) async {
    emit(const UpdateRequisitionState.loading());

    try {
      final member = _hiveService.retrieveMember()!;

      await _requisitionService.update(
        id: requisitionUlid,
        data: PRFRequisitionDTO(
          memberUlid: member.ulid,
          accountingEventUlid: accountingEvent.ulid,
          responsibleDesk: accountingEvent.responsibleDesk,
          requisitionDate: requisitionDate,
          remarks: remarks,
        ).toJson(),
      );
      emit(const UpdateRequisitionState.loaded());
    } on Failure catch (f) {
      emit(UpdateRequisitionState.error(f.message));
    } catch (e) {
      emit(UpdateRequisitionState.error(e.toString()));
    }
  }
}
