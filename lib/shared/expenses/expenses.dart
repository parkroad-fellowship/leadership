import 'package:flutter/material.dart';
import 'package:leadership/shared/expenses/_handset.dart';
import 'package:prf_design/prf_design.dart';

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
    return PRFAdaptive(
      handset: (_) => ExpensesViewHandset(
        accountingEventUlid: accountingEventUlid,
        showFinancialReport: showFinancialReport,
      ),
      builder: (_, _) => ExpensesViewHandset(
        accountingEventUlid: accountingEventUlid,
        showFinancialReport: showFinancialReport,
      ),
    );
  }
}
