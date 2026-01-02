import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/shared_views/expenses/_handset.dart';

class ExpensesView extends StatelessWidget {
  const ExpensesView({
    required this.accountingEventUlid,
    this.showFinancialReport = false,
    super.key,
  });

  final String accountingEventUlid;
  final bool showFinancialReport;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => ExpensesViewHandset(
        accountingEventUlid: accountingEventUlid,
        showFinancialReport: showFinancialReport,
      ),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => ExpensesViewHandset(
          accountingEventUlid: accountingEventUlid,
          showFinancialReport: showFinancialReport,
        ),
      ),
    );
  }
}
