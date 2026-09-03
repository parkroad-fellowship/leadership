import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:leadership/features/home/account/_handset.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => const AccountPageHandset(),
      builder: (_, _) => const AccountPageHandset(),
    );
  }
}
