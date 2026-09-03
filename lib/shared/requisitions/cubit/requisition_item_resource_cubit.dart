import 'package:leadership/models/remote/prf_requisition_item.dart';
import 'package:leadership/models/remote/prf_requisition_item_dto.dart';
import 'package:leadership/services/api/requisition_item_service.dart';
import 'package:leadership/services/local_storage/hive/db/requisition_item_hive_db_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class RequisitionItemResourceCubit extends ResourceCubit<PRFRequisitionItem> {
  RequisitionItemResourceCubit({
    required RequisitionItemService requisitionItemService,
    required RequisitionItemHiveDbService hiveDbService,
  }) : super(service: requisitionItemService, dbService: hiveDbService);

  @override
  Future<List<PRFRequisitionItem>> loadCachedList({
    Map<String, dynamic>? filters,
  }) async {
    return dbService.list();
  }

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
