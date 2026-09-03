import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/departments/_handset.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class DepartmentsPage extends StatelessWidget {
  const DepartmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => const DepartmentsPageHandset(),
      builder: (_, _) => const DepartmentsPageHandset(),
    );
  }
}
