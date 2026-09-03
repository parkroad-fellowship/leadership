import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/missions/actions/create_mission/_handset.dart';
import 'package:prf_design/prf_design.dart';

class CreateMissionView extends StatelessWidget {
  const CreateMissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => const CreateMissionViewHandset(),
      builder: (_, _) => const CreateMissionViewHandset(),
    );
  }
}
