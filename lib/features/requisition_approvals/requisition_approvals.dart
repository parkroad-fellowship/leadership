import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/requisition_approvals/_handset.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class RequisitionApprovalsPage extends StatelessWidget {
  const RequisitionApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => const RequisitionApprovalsPageHandset(),
      builder: (_, _) => const RequisitionApprovalsPageHandset(),
    );
  }
}
