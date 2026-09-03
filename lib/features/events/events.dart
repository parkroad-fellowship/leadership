import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/events/_handset.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => const EventsHandset(),
      builder: (_, _) => const EventsHandset(),
    );
  }
}
