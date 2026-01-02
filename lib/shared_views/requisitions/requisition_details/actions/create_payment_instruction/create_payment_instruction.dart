import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/actions/create_payment_instruction/_handset.dart';

class CreatePaymentInstructionView extends StatelessWidget {
  const CreatePaymentInstructionView({
    required this.requisitionUlid,
    super.key,
  });

  final String requisitionUlid;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => CreatePaymentInstructionViewHandset(
        requisitionUlid: requisitionUlid,
      ),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => CreatePaymentInstructionViewHandset(
          requisitionUlid: requisitionUlid,
        ),
      ),
    );
  }
}
