import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/members/_handset.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class MembersPage extends StatelessWidget {
  const MembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => const MembersPageHandset(),
      builder: (_, _) => const MembersPageHandset(),
    );
  }
}
