import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/actions/request_review/_handset.dart';

class RequestReviewView extends StatelessWidget {
  const RequestReviewView({required this.requisitionUlid, super.key});

  final String requisitionUlid;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => RequestReviewViewHandset(
        requisitionUlid: requisitionUlid,
      ),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => RequestReviewViewHandset(
          requisitionUlid: requisitionUlid,
        ),
      ),
    );
  }
}
