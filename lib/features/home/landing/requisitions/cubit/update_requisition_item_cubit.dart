import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_requisition_item_dto.dart';
import 'package:leadership/services/api/requisition_item_service.dart';

part 'update_requisition_item_state.dart';
part 'update_requisition_item_cubit.freezed.dart';

class UpdateRequisitionItemCubit extends Cubit<UpdateRequisitionItemState> {
  UpdateRequisitionItemCubit({
    required RequisitionItemService requisitionItemService,
  }) : super(const UpdateRequisitionItemState.initial()) {
    _requisitionItemService = requisitionItemService;
  }

  late RequisitionItemService _requisitionItemService;

  Future<void> updateRequisitionItem({
    required String requisitionUlid,
    required String requisitionItemUlid,
    required String expenseCategoryUlid,
    required String itemName,
    required int unitPrice,
    required int quantity,
  }) async {
    emit(const UpdateRequisitionItemState.loading());

    try {
      await _requisitionItemService.update(
        id: requisitionItemUlid,
        data: PRFRequisitionItemDTO(
          requisitionUlid: requisitionUlid,
          expenseCategoryUlid: expenseCategoryUlid,
          itemName: itemName,
          unitPrice: unitPrice,
          quantity: quantity,
        ).toJson(),
      );

      emit(const UpdateRequisitionItemState.loaded());
    } on Failure catch (f) {
      emit(UpdateRequisitionItemState.error(f.message));
    } catch (e) {
      emit(UpdateRequisitionItemState.error(e.toString()));
    }
  }
}
