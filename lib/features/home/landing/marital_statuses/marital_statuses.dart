import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/marital_statuses/_handset.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class MaritalStatusesPage extends StatelessWidget {
  const MaritalStatusesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => const MaritalStatusesPageHandset(),
      builder: (_, _) => const MaritalStatusesPageHandset(),
    );
  }
}
