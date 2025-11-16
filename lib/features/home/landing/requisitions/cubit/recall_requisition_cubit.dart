import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/services/_index.dart';
import 'package:leadership/services/api/requisition_service.dart';

part 'recall_requisition_state.dart';
part 'recall_requisition_cubit.freezed.dart';

class RecallRequisitionCubit extends Cubit<RecallRequisitionState> {
  RecallRequisitionCubit({
    required RequisitionService requisitionService,
    required HiveService hiveService,
  }) : super(const RecallRequisitionState.initial()) {
    _hiveService = hiveService;
    _requisitionService = requisitionService;
  }

  late RequisitionService _requisitionService;
  late HiveService _hiveService;

  Future<void> recallRequisition({
    required String ulid,
    required String approvalNotes,
  }) async {
    emit(const RecallRequisitionState.loading());
    try {
      final member = _hiveService.retrieveMember()!;
      final success = await _requisitionService.recallRequisition(
        ulid: ulid,
        approverUlid: member.ulid,
        approvalNotes: approvalNotes,
      );
      if (success) {
        emit(const RecallRequisitionState.loaded());
      } else {
        emit(const RecallRequisitionState.error('Recall failed'));
      }
    } on Failure catch (f) {
      emit(RecallRequisitionState.error(f.message));
    } catch (e) {
      emit(RecallRequisitionState.error(e.toString()));
    }
  }
}
