import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/school_terms/_handset.dart';

@RoutePage()
class SchoolTermsPage extends StatelessWidget {
  const SchoolTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => const SchoolTermsPageHandset(),
    );
  }
}
