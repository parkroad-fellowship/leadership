import 'package:flutter/material.dart';
import 'package:leadership/shared/requisitions/requisition_details/actions/create_requisition_item/_handset.dart';
import 'package:prf_design/prf_design.dart';

class CreateRequisitionItemView extends StatelessWidget {
  const CreateRequisitionItemView({required this.requisitionUlid, super.key});

  final String requisitionUlid;

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => CreateRequisitionItemViewHandset(
        requisitionUlid: requisitionUlid,
      ),
      builder: (_, _) => CreateRequisitionItemViewHandset(
        requisitionUlid: requisitionUlid,
      ),
    );
  }
}
