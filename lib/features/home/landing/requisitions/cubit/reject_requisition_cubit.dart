import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/services/api/requisition_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';

part 'reject_requisition_state.dart';
part 'reject_requisition_cubit.freezed.dart';

class RejectRequisitionCubit extends Cubit<RejectRequisitionState> {
  RejectRequisitionCubit({
    required RequisitionService requisitionService,
    required HiveService hiveService,
  }) : super(const RejectRequisitionState.initial()) {
    _hiveService = hiveService;
    _requisitionService = requisitionService;
  }

  late RequisitionService _requisitionService;
  late HiveService _hiveService;

  Future<void> rejectRequisition({
    required String ulid,
    required String approvalNotes,
  }) async {
    emit(const RejectRequisitionState.loading());
    try {
      final member = _hiveService.retrieveMember()!;
      final success = await _requisitionService.rejectRequisition(
        ulid: ulid,
        approverUlid: member.ulid,
        approvalNotes: approvalNotes,
      );
      if (success) {
        emit(const RejectRequisitionState.loaded());
      } else {
        emit(const RejectRequisitionState.error('Rejection failed'));
      }
    } on Failure catch (f) {
      emit(RejectRequisitionState.error(f.message));
    } catch (e) {
      emit(RejectRequisitionState.error(e.toString()));
    }
  }
}
