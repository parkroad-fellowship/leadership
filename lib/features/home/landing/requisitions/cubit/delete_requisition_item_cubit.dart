import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/services/api/requisition_item_service.dart';

part 'delete_requisition_item_state.dart';
part 'delete_requisition_item_cubit.freezed.dart';

class DeleteRequisitionItemCubit extends Cubit<DeleteRequisitionItemState> {
  DeleteRequisitionItemCubit({
    required RequisitionItemService requisitionItemService,
  }) : super(const DeleteRequisitionItemState.initial()) {
    _requisitionItemService = requisitionItemService;
  }

  late RequisitionItemService _requisitionItemService;

  Future<void> deleteRequisitionItem({
    required int index,
    required String requisitionItemUlid,
  }) async {
    emit(DeleteRequisitionItemState.loading(index: index));

    try {
      await _requisitionItemService.delete(ulid: requisitionItemUlid);
      emit(const DeleteRequisitionItemState.loaded());
    } on Failure catch (f) {
      emit(DeleteRequisitionItemState.error(f.message));
    } catch (e) {
      emit(DeleteRequisitionItemState.error(e.toString()));
    }
  }

  void resetState() {
    emit(const DeleteRequisitionItemState.initial());
  }
}
