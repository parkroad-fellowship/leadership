import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/desk_activities/_handset.dart';

@RoutePage()
class DeskActivitiesPage extends StatelessWidget {
  const DeskActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => const DeskActivitiesHandset(),
    );
  }
}
