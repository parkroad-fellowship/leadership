import 'package:flutter/material.dart';
import 'package:leadership/shared/requisitions/requisition_details/actions/recall_requisition/_handset.dart';
import 'package:prf_design/prf_design.dart';

class RecallRequisitionView extends StatelessWidget {
  const RecallRequisitionView({
    required this.requisitionUlid,
    super.key,
  });

  final String requisitionUlid;

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => RecallRequisitionViewHandset(
        requisitionUlid: requisitionUlid,
      ),
      builder: (_, _) => RecallRequisitionViewHandset(
        requisitionUlid: requisitionUlid,
      ),
    );
  }
}
