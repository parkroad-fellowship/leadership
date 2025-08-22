import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_requisition_dto.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/services/api/requisition_service.dart';

part 'create_requisition_state.dart';
part 'create_requisition_cubit.freezed.dart';

class CreateRequisitionCubit extends Cubit<CreateRequisitionState> {
  CreateRequisitionCubit({
    required RequisitionService requisitionService,
    required HiveService hiveService,
  }) : super(const CreateRequisitionState.initial()) {
    _requisitionService = requisitionService;
    _hiveService = hiveService;
  }

  late RequisitionService _requisitionService;
  late HiveService _hiveService;

  Future<void> createRequisition({
    required PRFAccountingEvent accountingEvent,
    required DateTime requisitionDate,
    required String remarks,
  }) async {
    emit(const CreateRequisitionState.loading());

    try {
      final member = _hiveService.retrieveMember()!;
      await _requisitionService.create(
        data: PRFRequisitionDTO(
          memberUlid: member.ulid,
          accountingEventUlid: accountingEvent.ulid,
          responsibleDesk: accountingEvent.responsibleDesk,
          requisitionDate: requisitionDate,
          remarks: remarks,
        ).toJson(),
      );
      emit(const CreateRequisitionState.loaded());
    } on Failure catch (e) {
      emit(CreateRequisitionState.error(e.message));
    } catch (e) {
      emit(CreateRequisitionState.error(e.toString()));
    }
  }
}
