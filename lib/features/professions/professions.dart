import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/professions/_handset.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class ProfessionsPage extends StatelessWidget {
  const ProfessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => const ProfessionsPageHandset(),
      builder: (_, _) => const ProfessionsPageHandset(),
    );
  }
}
