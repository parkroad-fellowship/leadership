import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/desk_activities/actions/create_event/_handset.dart';
import 'package:prf_design/prf_design.dart';

class CreateEventView extends StatelessWidget {
  const CreateEventView({super.key});

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => const CreateEventViewHandset(),
      builder: (_, _) => const CreateEventViewHandset(),
    );
  }
}
