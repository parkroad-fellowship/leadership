import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/requisitions/actions/create_payment_instruction/_handset.dart';

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
