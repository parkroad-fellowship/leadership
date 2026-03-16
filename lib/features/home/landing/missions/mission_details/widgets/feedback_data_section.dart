import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/missions/mission_details/widgets/domain_tab_section.dart';

class FeedbackDataMissionDetailsSection extends StatelessWidget {
  const FeedbackDataMissionDetailsSection({
    required this.debriefNotes,
    required this.souls,
    required this.questions,
    super.key,
  });

  final Widget debriefNotes;
  final Widget souls;
  final Widget questions;

  @override
  Widget build(BuildContext context) {
    return MissionDomainTabSection(
      title: 'Feedback Data',
      subtitle: 'Questions captured and post-mission debrief reflections.',
      tabs: const [
        Tab(text: 'Debrief Notes'),
        Tab(text: 'Souls'),
        Tab(text: 'Questions'),
      ],
      children: [
        debriefNotes,
        souls,
        questions,
      ],
    );
  }
}
