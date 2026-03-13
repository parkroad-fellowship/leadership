import 'package:leadership/models/remote/prf_refund.dart';
import 'package:leadership/models/remote/prf_refund_dto.dart';
import 'package:leadership/services/api/refund_service.dart';
import 'package:leadership/utils/crud/resource_cubit.dart';

class RefundResourceCubit extends ResourceCubit<PRFRefund> {
  RefundResourceCubit({required RefundService refundService})
    : super(service: refundService);

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
