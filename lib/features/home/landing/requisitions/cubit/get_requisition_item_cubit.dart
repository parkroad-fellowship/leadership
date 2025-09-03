import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_requisition_item.dart';
import 'package:leadership/services/api/requisition_item_service.dart';

part 'get_requisition_item_state.dart';
part 'get_requisition_item_cubit.freezed.dart';

class GetRequisitionItemCubit extends Cubit<GetRequisitionItemState> {
  GetRequisitionItemCubit({
    required RequisitionItemService requisitionItemService,
  }) : super(const GetRequisitionItemState.initial()) {
    _requisitionItemService = requisitionItemService;
  }

  late RequisitionItemService _requisitionItemService;

  Future<void> getRequisitionItem({
    required String requisitionItemUlid,
  }) async {
    emit(const GetRequisitionItemState.loading());

    try {
      final requisitionItem = await _requisitionItemService.get(
        ulid: requisitionItemUlid,
        includes: ['expenseCategory', 'requisition'],
      );
      emit(GetRequisitionItemState.loaded(requisitionItem: requisitionItem));
    } on Failure catch (f) {
      emit(GetRequisitionItemState.error(f.message));
    } catch (e) {
      emit(GetRequisitionItemState.error(e.toString()));
    }
  }
}
