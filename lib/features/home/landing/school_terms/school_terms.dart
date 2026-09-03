import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/school_terms/_handset.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class SchoolTermsPage extends StatelessWidget {
  const SchoolTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => const SchoolTermsPageHandset(),
      builder: (_, _) => const SchoolTermsPageHandset(),
    );
  }
}
