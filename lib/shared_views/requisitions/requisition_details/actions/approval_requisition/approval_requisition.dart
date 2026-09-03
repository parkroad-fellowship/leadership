import 'package:flutter/material.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/actions/approval_requisition/_handset.dart';
import 'package:prf_design/prf_design.dart';

class ApproveRequisitionView extends StatelessWidget {
  const ApproveRequisitionView({
    required this.requisitionUlid,
    super.key,
  });

  final String requisitionUlid;

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => ApproveRequisitionViewHandset(
        requisitionUlid: requisitionUlid,
      ),
      builder: (_, _) => ApproveRequisitionViewHandset(
        requisitionUlid: requisitionUlid,
      ),
    );
  }
}
