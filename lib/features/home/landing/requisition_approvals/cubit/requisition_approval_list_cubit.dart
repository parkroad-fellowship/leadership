import 'package:leadership/models/remote/prf_requisition.dart';
import 'package:leadership/services/api/requisition_service.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

abstract class RequisitionApprovalListCubit
    extends ResourceCubit<PRFRequisition> {
  RequisitionApprovalListCubit({
    required RequisitionService requisitionService,
    required this._hiveService,
  }) : super(service: requisitionService);

  final HiveService _hiveService;

  HiveService get hiveService => _hiveService;

  @override
  List<String> get defaultIncludes => ['member'];

  Future<void> loadRequisitions({
    required Map<String, dynamic> filters,
    String? orderDirection,
  }) {
    return loadAll(
      filters: filters,
      orderBy: 'requisition_date',
      orderDirection: orderDirection,
    );
  }
}
