import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/models/remote/prf_requisition_item.dart';
import 'package:leadership/services/api/requisition_item_service.dart';

part 'get_requisition_items_state.dart';
part 'get_requisition_items_cubit.freezed.dart';

class GetRequisitionItemsCubit extends Cubit<GetRequisitionItemsState> {
  GetRequisitionItemsCubit({
    required RequisitionItemService requisitionItemService,
  }) : super(const GetRequisitionItemsState.initial()) {
    _requisitionItemService = requisitionItemService;
  }

  late RequisitionItemService _requisitionItemService;

  Future<void> getRequisitionItems({
    required String requisitionUlid,
  }) async {
    emit(const GetRequisitionItemsState.loading());
    try {
      final requisitionItems = await _requisitionItemService.list(
        filters: {
          'requisition_ulid': requisitionUlid,
        },
      );
      if (requisitionItems.isEmpty) {
        emit(const GetRequisitionItemsState.empty());
      } else {
        emit(
          GetRequisitionItemsState.loaded(requisitionItems: requisitionItems),
        );
      }
    } catch (e) {
      emit(GetRequisitionItemsState.error(e.toString()));
    }
  }
}
