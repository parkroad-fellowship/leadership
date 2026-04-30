import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/features/home/landing/churches/_handset.dart';

@RoutePage()
class ChurchesPage extends StatelessWidget {
  const ChurchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => const ChurchesPageHandset(),
    );
  }
}
