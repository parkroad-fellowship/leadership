import 'package:leadership/models/remote/prf_refund.dart';
import 'package:leadership/models/remote/prf_refund_dto.dart';
import 'package:leadership/services/api/refund_service.dart';
import 'package:leadership/services/local_storage/hive/db/refund_hive_db_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class RefundResourceCubit extends ResourceCubit<PRFRefund> {
  RefundResourceCubit({
    required RefundService refundService,
    required RefundHiveDbService hiveDbService,
  }) : super(service: refundService, dbService: hiveDbService);

  @override
  Future<List<PRFRefund>> loadCachedList({
    Map<String, dynamic>? filters,
  }) async {
    return dbService.list();
  }

  Future<void> addMissionRefund({
    required String accountingEventUlid,
    required int amount,
    required String confirmationMessage,
  }) {
    final dto = PRFRefundDTO(
      accountingEventUlid: accountingEventUlid,
      amount: amount,
      confirmationMessage: confirmationMessage,
    );

    return create(data: dto.toJson());
  }
}
