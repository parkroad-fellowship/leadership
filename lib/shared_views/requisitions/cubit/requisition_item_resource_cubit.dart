import 'package:leadership/models/remote/prf_requisition_item.dart';
import 'package:leadership/models/remote/prf_requisition_item_dto.dart';
import 'package:leadership/services/api/requisition_item_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class RequisitionItemResourceCubit extends ResourceCubit<PRFRequisitionItem> {
  RequisitionItemResourceCubit({
    required RequisitionItemService requisitionItemService,
  }) : super(service: requisitionItemService);

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
}
