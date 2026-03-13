import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/missions/mission_details/widgets/domain_tab_section.dart';

class PeopleDataMissionDetailsSection extends StatelessWidget {
  const PeopleDataMissionDetailsSection({
    required this.subscribers,
    required this.sessions,
    super.key,
  });

  final Widget subscribers;
  final Widget sessions;

  @override
  Widget build(BuildContext context) {
    return MissionDomainTabSection(
      title: 'People Data',
      subtitle: 'Subscribers and ministry outcomes from the mission.',
      tabs: const [
        Tab(text: 'Subscribers'),
        Tab(text: 'Sessions'),
      ],
      children: [
        subscribers,
        sessions,
      ],
    );
  }
}
