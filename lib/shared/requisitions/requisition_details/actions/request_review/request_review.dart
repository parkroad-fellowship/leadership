import 'package:flutter/material.dart';
import 'package:leadership/shared/requisitions/requisition_details/actions/request_review/_handset.dart';
import 'package:prf_design/prf_design.dart';

class RequestReviewView extends StatelessWidget {
  const RequestReviewView({required this.requisitionUlid, super.key});

  final String requisitionUlid;

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => RequestReviewViewHandset(
        requisitionUlid: requisitionUlid,
      ),
      builder: (_, _) => RequestReviewViewHandset(
        requisitionUlid: requisitionUlid,
      ),
    );
  }
}
