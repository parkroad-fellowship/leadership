import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/missions/mission_details/widgets/domain_tab_section.dart';

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
    return MissionDomainTabSection(
      title: 'Finance',
      subtitle: 'Requisitions and expenses linked to this mission.',
      tabs: [
        Tab(text: requisitionsLabel),
        Tab(text: expensesLabel),
      ],
      children: [
        requisitions,
        expenses,
      ],
    );
  }
}
