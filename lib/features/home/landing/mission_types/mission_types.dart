import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/mission_types/_handset.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class MissionTypesPage extends StatelessWidget {
  const MissionTypesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => const MissionTypesPageHandset(),
      builder: (_, _) => const MissionTypesPageHandset(),
    );
  }
}
