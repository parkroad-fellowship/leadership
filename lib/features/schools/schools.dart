import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/schools/_handset.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class SchoolsPage extends StatelessWidget {
  const SchoolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => const SchoolsPageHandset(),
      builder: (_, _) => const SchoolsPageHandset(),
    );
  }
}
