import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/churches/_handset.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class ChurchesPage extends StatelessWidget {
  const ChurchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => const ChurchesPageHandset(),
      builder: (_, _) => const ChurchesPageHandset(),
    );
  }
}
