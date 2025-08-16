import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/desk_events/_handset.dart';
import 'package:leadership/features/home/landing/desk_events/_tablet.dart';

@RoutePage()
class DeskEventsPage extends StatelessWidget {
  const DeskEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => const DeskEventsTablet(),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => const DeskEventsHandset(),
        tablet: (_, _) => const DeskEventsTablet(),
      ),
    );
  }
}
