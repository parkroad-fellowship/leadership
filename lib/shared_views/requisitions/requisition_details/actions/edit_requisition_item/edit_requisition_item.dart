import 'package:flutter/material.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/actions/edit_requisition_item/_handset.dart';
import 'package:prf_design/prf_design.dart';

class EditRequisitionItemView extends StatelessWidget {
  const EditRequisitionItemView({required this.requisitionItemUlid, super.key});

  final String requisitionItemUlid;

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => EditRequisitionItemViewHandset(
        requisitionItemUlid: requisitionItemUlid,
      ),
      builder: (_, _) => EditRequisitionItemViewHandset(
        requisitionItemUlid: requisitionItemUlid,
      ),
    );
  }
}
