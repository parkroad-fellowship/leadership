import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_requisition_item_dto.dart';
import 'package:leadership/services/api/requisition_item_service.dart';

part 'create_requisition_item_state.dart';
part 'create_requisition_item_cubit.freezed.dart';

class CreateRequisitionItemCubit extends Cubit<CreateRequisitionItemState> {
  CreateRequisitionItemCubit({
    required RequisitionItemService requisitionItemService,
  }) : super(const CreateRequisitionItemState.initial()) {
    _requisitionItemService = requisitionItemService;
  }

  late RequisitionItemService _requisitionItemService;

  Future<void> createRequisitionItem({
    required String requisitionUlid,
    required String expenseCategoryUlid,
    required String itemName,
    required int unitPrice,
    required int quantity,
  }) async {
    emit(const CreateRequisitionItemState.loading());

    try {
      await _requisitionItemService.create(
        data: PRFRequisitionItemDTO(
          requisitionUlid: requisitionUlid,
          expenseCategoryUlid: expenseCategoryUlid,
          itemName: itemName,
          unitPrice: unitPrice,
          quantity: quantity,
        ).toJson(),
      );

      emit(const CreateRequisitionItemState.loaded());
    } on Failure catch (f) {
      emit(CreateRequisitionItemState.error(f.message));
    } catch (e) {
      emit(CreateRequisitionItemState.error(e.toString()));
    }
  }
}
