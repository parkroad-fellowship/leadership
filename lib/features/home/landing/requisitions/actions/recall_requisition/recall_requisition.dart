import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/requisitions/actions/recall_requisition/_handset.dart';

class RecallRequisitionView extends StatelessWidget {
  const RecallRequisitionView({
    required this.requisitionUlid,
    super.key,
  });

  final String requisitionUlid;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => RecallRequisitionViewHandset(
        requisitionUlid: requisitionUlid,
      ),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => RecallRequisitionViewHandset(
          requisitionUlid: requisitionUlid,
        ),
      ),
    );
  }
}
