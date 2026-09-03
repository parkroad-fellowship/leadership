import 'package:flutter/material.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/actions/edit_requisition/_handset.dart';
import 'package:prf_design/prf_design.dart';

class EditRequisitionView extends StatelessWidget {
  const EditRequisitionView({required this.requisitionUlid, super.key});

  final String requisitionUlid;

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => EditRequisitionViewHandset(
        requisitionUlid: requisitionUlid,
      ),
      builder: (_, _) => EditRequisitionViewHandset(
        requisitionUlid: requisitionUlid,
      ),
    );
  }
}
