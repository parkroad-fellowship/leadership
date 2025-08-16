import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/desk_events/event_details/event_details/_handset.dart';
import 'package:leadership/models/remote/prf_event.dart';

class DeskEventDetailsView extends StatelessWidget {
  const DeskEventDetailsView({required this.event, super.key});

  final PRFEvent event;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => DeskEventDetailsViewHandset(event: event),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => DeskEventDetailsViewHandset(event: event),
      ),
    );
  }
}
