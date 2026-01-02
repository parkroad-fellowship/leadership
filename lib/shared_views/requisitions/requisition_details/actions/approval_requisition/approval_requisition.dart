import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/actions/approval_requisition/_handset.dart';

class ApproveRequisitionView extends StatelessWidget {
  const ApproveRequisitionView({
    required this.requisitionUlid,
    super.key,
  });

  final String requisitionUlid;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => ApproveRequisitionViewHandset(
        requisitionUlid: requisitionUlid,
      ),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => ApproveRequisitionViewHandset(
          requisitionUlid: requisitionUlid,
        ),
      ),
    );
  }
}
