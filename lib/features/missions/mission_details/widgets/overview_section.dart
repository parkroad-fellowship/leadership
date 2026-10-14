import 'package:flutter/material.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:prf_design/prf_design.dart';

class OverviewMissionDetailsSection extends StatelessWidget {
  const OverviewMissionDetailsSection({
    required this.missionGround,
    required this.operations,
    super.key,
  });

  final Widget missionGround;
  final Widget operations;

  @override
  Widget build(BuildContext context) {
    return PRFDomainTabSection(
      title: context.l10n.missionDetailsOverview,
      subtitle: context.l10n.missionDetailsOverviewSubtitle,
      tabs: [
        Tab(text: context.l10n.missionGround),
        Tab(text: context.l10n.missionDetailsOperations),
      ],
      children: [missionGround, operations],
    );
  }
}
