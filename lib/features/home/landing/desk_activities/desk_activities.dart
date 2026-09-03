import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/desk_activities/_handset.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class DeskActivitiesPage extends StatelessWidget {
  const DeskActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => const DeskActivitiesHandset(),
      builder: (_, _) => const DeskActivitiesHandset(),
    );
  }
}
