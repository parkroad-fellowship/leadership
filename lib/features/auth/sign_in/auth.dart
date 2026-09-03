import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:leadership/features/auth/sign_in/_handset.dart';
import 'package:leadership/features/auth/sign_in/_tablet.dart';
import 'package:prf_design/prf_design.dart';

@RoutePage()
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PRFAdaptive(
      handset: (_) => const SignInHandset(),
      builder: (_, _) => const SignInTablet(),
    );
  }
}
