import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/missions/actions/create_mission/_handset.dart';

class CreateMissionView extends StatelessWidget {
  const CreateMissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => const CreateMissionViewHandset(),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => const CreateMissionViewHandset(),
      ),
    );
  }
}
