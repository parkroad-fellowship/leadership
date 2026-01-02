import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/shared_views/requisitions/requisition_details/_handset.dart';

@RoutePage()
class RequisitionDetailsPage extends StatelessWidget {
  const RequisitionDetailsPage({required this.requisitionUlid, super.key});

  final String requisitionUlid;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) =>
          RequisitionDetailsPageHandset(requisitionUlid: requisitionUlid),
    );
  }
}
