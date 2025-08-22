import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/missions/mission_details/widgets/expenses/_handset.dart';

class ExpensesView extends StatelessWidget {
  const ExpensesView({required this.missionUlid, super.key});

  final String missionUlid;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => ExpensesViewHandset(missionUlid: missionUlid),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => ExpensesViewHandset(missionUlid: missionUlid),
      ),
    );
  }
}
