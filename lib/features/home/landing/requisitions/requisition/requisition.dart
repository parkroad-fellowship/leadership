import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/requisitions/requisition/_handset.dart';

@RoutePage()
class RequisitionPage extends StatelessWidget {
  const RequisitionPage({required this.requisitionUlid, super.key});

  final String requisitionUlid;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) =>
          RequisitionPageHandset(requisitionUlid: requisitionUlid),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) =>
            RequisitionPageHandset(requisitionUlid: requisitionUlid),
      ),
    );
  }
}
