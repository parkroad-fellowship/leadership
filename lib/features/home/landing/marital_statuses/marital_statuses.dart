import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/marital_statuses/_handset.dart';

@RoutePage()
class MaritalStatusesPage extends StatelessWidget {
  const MaritalStatusesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => const MaritalStatusesPageHandset(),
    );
  }
}
