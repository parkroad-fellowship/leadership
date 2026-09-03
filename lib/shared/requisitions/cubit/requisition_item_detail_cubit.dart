import 'package:leadership/models/remote/prf_requisition_item.dart';
import 'package:leadership/services/api/requisition_item_service.dart';
import 'package:leadership/services/local_storage/hive/db/requisition_item_hive_db_service.dart';
import 'package:leadership/utils/crud/single_resource_cubit.dart';

class RequisitionItemDetailCubit
    extends SingleResourceCubit<PRFRequisitionItem> {
  RequisitionItemDetailCubit({
    required RequisitionItemService requisitionItemService,
    required RequisitionItemHiveDbService hiveDbService,
  }) : super(service: requisitionItemService, dbService: hiveDbService);

  @override
  List<String> get defaultIncludes => [
    'expenseCategory',
    'requisition',
  ];
}
