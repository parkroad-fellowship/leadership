import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/_handset.dart';
import 'package:leadership/models/remote/prf_event.dart';

@RoutePage()
class DeskEventDetailsPage extends StatelessWidget {
  const DeskEventDetailsPage({required this.event, super.key});

  final PRFEvent event;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => DeskEventDetailsPageHandset(event: event),
    );
  }
}
