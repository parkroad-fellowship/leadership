import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/missions/mission_details/widgets/domain_tab_section.dart';

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
    return MissionDomainTabSection(
      title: 'Overview',
      subtitle: 'Mission context, field notes, and operation controls.',
      tabs: const [
        Tab(text: 'Mission Ground'),
        Tab(text: 'Operations'),
      ],
      children: [
        missionGround,
        operations,
      ],
    );
  }
}
