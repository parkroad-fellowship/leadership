import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/events/desk_activity_details/_handset.dart';
import 'package:leadership/models/remote/prf_event.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class DeskEventDetailsPage extends StatelessWidget {
  const DeskEventDetailsPage({required this.event, super.key});

  final PRFEvent event;

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => DeskEventDetailsPageHandset(event: event),
      builder: (_, _) => DeskEventDetailsPageHandset(event: event),
    );
  }
}
