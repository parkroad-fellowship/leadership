import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/actions/create_requisition_item/_handset.dart';

class CreateRequisitionItemView extends StatelessWidget {
  const CreateRequisitionItemView({required this.requisitionUlid, super.key});

  final String requisitionUlid;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => CreateRequisitionItemViewHandset(
        requisitionUlid: requisitionUlid,
      ),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => CreateRequisitionItemViewHandset(
          requisitionUlid: requisitionUlid,
        ),
      ),
    );
  }
}
