import 'package:flutter/material.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:prf_design/prf_design.dart';

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
    return PRFDomainTabSection(
      title: context.l10n.missionDetailsPeople,
      subtitle: context.l10n.missionDetailsPeopleSubtitle,
      tabs: [
        Tab(text: context.l10n.missionDetailsSubscribers),
        Tab(text: context.l10n.sessions),
      ],
      children: [subscribers, sessions],
    );
  }
}
