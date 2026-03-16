import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/missions/mission_details/widgets/mission_ground/_handset.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';

class MissionGroundView extends StatelessWidget {
  const MissionGroundView({required this.mission, super.key});

  final PRFMission mission;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => MissionGroundViewHandset(mission: mission),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => MissionGroundViewHandset(mission: mission),
      ),
    );
  }
}
