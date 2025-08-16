import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/requisitions/_handset.dart';

class RequisitionsView extends StatelessWidget {
  const RequisitionsView({required this.accountingEventUlid, super.key});

  final String accountingEventUlid;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) =>
          RequisitionsViewHandset(accountingEventUlid: accountingEventUlid),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) =>
            RequisitionsViewHandset(accountingEventUlid: accountingEventUlid),
      ),
    );
  }
}
