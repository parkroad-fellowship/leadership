import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/missions/mission_details/widgets/mission_ground/_handset.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:prf_design/prf_design.dart';

class MissionGroundView extends StatelessWidget {
  const MissionGroundView({required this.mission, super.key});

  final PRFMission mission;

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => MissionGroundViewHandset(mission: mission),
      builder: (_, _) => MissionGroundViewHandset(mission: mission),
    );
  }
}
