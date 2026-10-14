import 'package:flutter/material.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:prf_design/prf_design.dart';

class FinanceMissionDetailsSection extends StatelessWidget {
  const FinanceMissionDetailsSection({
    required this.requisitionsLabel,
    required this.expensesLabel,
    required this.requisitions,
    required this.expenses,
    super.key,
  });

  final String requisitionsLabel;
  final String expensesLabel;
  final Widget requisitions;
  final Widget expenses;

  @override
  Widget build(BuildContext context) {
    return PRFDomainTabSection(
      title: context.l10n.missionDetailsFinance,
      subtitle: context.l10n.missionDetailsFinanceSubtitle,
      tabs: [
        Tab(text: requisitionsLabel),
        Tab(text: expensesLabel),
      ],
      children: [requisitions, expenses],
    );
  }
}
