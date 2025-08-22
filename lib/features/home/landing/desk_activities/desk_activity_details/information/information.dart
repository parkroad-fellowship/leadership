import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/desk_activities/desk_activity_details/information/_handset.dart';
import 'package:leadership/models/remote/prf_event.dart';

class InformationView extends StatelessWidget {
  const InformationView({required this.event, super.key});

  final PRFEvent event;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => InformationViewHandset(event: event),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => InformationViewHandset(event: event),
      ),
    );
  }
}
