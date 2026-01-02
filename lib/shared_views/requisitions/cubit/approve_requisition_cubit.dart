import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/services/api/requisition_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';

part 'approve_requisition_state.dart';
part 'approve_requisition_cubit.freezed.dart';

class ApproveRequisitionCubit extends Cubit<ApproveRequisitionState> {
  ApproveRequisitionCubit({
    required RequisitionService requisitionService,
    required HiveService hiveService,
  }) : super(const ApproveRequisitionState.initial()) {
    _requisitionService = requisitionService;
    _hiveService = hiveService;
  }

  late RequisitionService _requisitionService;
  late HiveService _hiveService;

  Future<void> approveRequisition({
    required String ulid,
    String? approvalNotes,
  }) async {
    emit(const ApproveRequisitionState.loading());
    try {
      final member = _hiveService.retrieveMember()!;
      final success = await _requisitionService.approveRequisition(
        ulid: ulid,
        approverUlid: member.ulid,
        approvalNotes: approvalNotes,
      );
      if (success) {
        emit(const ApproveRequisitionState.loaded());
      } else {
        emit(const ApproveRequisitionState.error('Approval failed'));
      }
    } on Failure catch (f) {
      emit(ApproveRequisitionState.error(f.message));
    } catch (e) {
      emit(ApproveRequisitionState.error(e.toString()));
    }
  }
}
