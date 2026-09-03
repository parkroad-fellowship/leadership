import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/shared/requisitions/requisition_details/_handset.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class RequisitionDetailsPage extends StatelessWidget {
  const RequisitionDetailsPage({required this.requisitionUlid, super.key});

  final String requisitionUlid;

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) =>
          RequisitionDetailsPageHandset(requisitionUlid: requisitionUlid),
      builder: (_, _) =>
          RequisitionDetailsPageHandset(requisitionUlid: requisitionUlid),
    );
  }
}
