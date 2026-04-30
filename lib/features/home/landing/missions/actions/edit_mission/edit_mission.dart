import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/missions/actions/edit_mission/_handset.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';

class EditMissionView extends StatelessWidget {
  const EditMissionView({required this.mission, super.key});

  final PRFMission mission;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => EditMissionViewHandset(mission: mission),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => EditMissionViewHandset(mission: mission),
      ),
    );
  }
}
