import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/missions/mission_details/widgets/expenses/_handset.dart';

class ExpensesView extends StatelessWidget {
  const ExpensesView({required this.accountingEventUlid, super.key});

  final String accountingEventUlid;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) =>
          ExpensesViewHandset(accountingEventUlid: accountingEventUlid),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) =>
            ExpensesViewHandset(accountingEventUlid: accountingEventUlid),
      ),
    );
  }
}
