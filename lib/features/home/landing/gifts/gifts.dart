import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/gifts/_handset.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class GiftsPage extends StatelessWidget {
  const GiftsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => const GiftsPageHandset(),
      builder: (_, _) => const GiftsPageHandset(),
    );
  }
}
