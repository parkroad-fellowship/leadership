import 'package:flutter/material.dart';
import 'package:leadership/shared/requisitions/requisition_details/actions/create_payment_instruction/_handset.dart';
import 'package:prf_design/prf_design.dart';

class CreatePaymentInstructionView extends StatelessWidget {
  const CreatePaymentInstructionView({
    required this.requisitionUlid,
    super.key,
  });

  final String requisitionUlid;

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => CreatePaymentInstructionViewHandset(
        requisitionUlid: requisitionUlid,
      ),
      builder: (_, _) => CreatePaymentInstructionViewHandset(
        requisitionUlid: requisitionUlid,
      ),
    );
  }
}
