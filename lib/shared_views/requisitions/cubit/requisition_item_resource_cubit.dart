import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_requisition_item.dart';
import 'package:leadership/models/remote/prf_requisition_item_dto.dart';
import 'package:leadership/services/api/requisition_item_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';
import 'package:leadership/utils/crud/resource_state.dart';

class RequisitionItemResourceCubit extends ResourceCubit<PRFRequisitionItem> {
  RequisitionItemResourceCubit({
    required RequisitionItemService requisitionItemService,
  }) : _requisitionItemService = requisitionItemService,
       super(service: requisitionItemService);

  final RequisitionItemService _requisitionItemService;

  Future<void> loadForRequisition({required String requisitionUlid}) {
    return loadAll(
      filters: {'requisition_ulid': requisitionUlid},
      limit: 200,
    );
  }

  Future<void> createRequisitionItem({
    required String requisitionUlid,
    required String expenseCategoryUlid,
    required String itemName,
    required String narration,
    required int unitPrice,
    required int quantity,
  }) {
    return create(
      data: PRFRequisitionItemDTO(
        requisitionUlid: requisitionUlid,
        expenseCategoryUlid: expenseCategoryUlid,
        itemName: itemName,
        narration: narration,
        unitPrice: unitPrice,
        quantity: quantity,
      ).toJson(),
    );
  }

  Future<void> loadRequisitionItem({
    required String requisitionItemUlid,
  }) async {
    emit(const ResourceState<PRFRequisitionItem>.listLoading());

    try {
      final requisitionItem = await _requisitionItemService.get(
        ulid: requisitionItemUlid,
        includes: ['expenseCategory', 'requisition'],
      );
      emit(
        ResourceState<PRFRequisitionItem>.listLoaded(
          items: [requisitionItem],
        ),
      );
    } on Failure catch (e) {
      emit(
        ResourceState<PRFRequisitionItem>.error(
          message: e.message,
          items: currentItems,
        ),
      );
    } catch (e) {
      emit(
        ResourceState<PRFRequisitionItem>.error(
          message: e.toString(),
          items: currentItems,
        ),
      );
    }
  }

  Future<void> updateRequisitionItem({
    required String requisitionUlid,
    required String requisitionItemUlid,
    required String expenseCategoryUlid,
    required String itemName,
    required String narration,
    required int unitPrice,
    required int quantity,
  }) {
    return update(
      id: requisitionItemUlid,
      data: PRFRequisitionItemDTO(
        requisitionUlid: requisitionUlid,
        expenseCategoryUlid: expenseCategoryUlid,
        itemName: itemName,
        narration: narration,
        unitPrice: unitPrice,
        quantity: quantity,
      ).toJson(),
      includes: ['expenseCategory', 'requisition'],
      matchById: (item) => item.ulid == requisitionItemUlid,
    );
  }

  Future<void> deleteRequisitionItem({required String requisitionItemUlid}) {
    return delete(
      ulid: requisitionItemUlid,
      matchById: (item) => item.ulid == requisitionItemUlid,
    );
  }
}
