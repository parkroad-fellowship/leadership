import 'package:flutter/material.dart';
import 'package:leadership/features/missions/actions/edit_mission/_handset.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:prf_design/prf_design.dart';

class EditMissionView extends StatelessWidget {
  const EditMissionView({required this.mission, super.key});

  final PRFMission mission;

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => EditMissionViewHandset(mission: mission),
      builder: (_, _) => EditMissionViewHandset(mission: mission),
    );
  }
}
