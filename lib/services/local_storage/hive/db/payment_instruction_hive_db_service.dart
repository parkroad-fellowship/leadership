import 'package:leadership/models/remote/prf_payment_instruction.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';

class PaymentInstructionHiveDbService
    extends BaseHiveDbService<PRFPaymentInstruction> {
  @override
  String get boxName => 'prf_payment_instructions';

  @override
  String getKey(PRFPaymentInstruction entity) => entity.ulid;

  @override
  PRFPaymentInstruction fromJson(Map<String, dynamic> json) =>
      PRFPaymentInstruction.fromJson(json);

  @override
  Map<String, dynamic> toJson(PRFPaymentInstruction entity) => entity.toJson();
}
