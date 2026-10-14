import 'package:flutter/material.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:prf_design/prf_design.dart';

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
    return PRFDomainTabSection(
      title: context.l10n.missionDetailsFeedback,
      subtitle: context.l10n.missionDetailsFeedbackSummary,
      tabs: [
        Tab(text: context.l10n.debriefNotes),
        Tab(text: context.l10n.souls),
        Tab(text: context.l10n.questions),
      ],
      children: [debriefNotes, souls, questions],
    );
  }
}
