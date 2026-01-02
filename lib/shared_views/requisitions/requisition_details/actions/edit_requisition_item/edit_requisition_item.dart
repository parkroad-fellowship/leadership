import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/actions/edit_requisition_item/_handset.dart';

class EditRequisitionItemView extends StatelessWidget {
  const EditRequisitionItemView({required this.requisitionItemUlid, super.key});

  final String requisitionItemUlid;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => EditRequisitionItemViewHandset(
        requisitionItemUlid: requisitionItemUlid,
      ),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => EditRequisitionItemViewHandset(
          requisitionItemUlid: requisitionItemUlid,
        ),
      ),
    );
  }
}
