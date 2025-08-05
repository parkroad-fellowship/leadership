import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/shared_widgets/home_action_card/_handset.dart';
import 'package:leadership/shared_widgets/home_action_card/_tablet.dart';

class HomeActionCard extends StatelessWidget {
  const HomeActionCard({
    required this.title,
    required this.assetPath,
    super.key,
    this.onTap,
  });

  final String title;
  final String assetPath;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => HomeActionCardTablet(
        title: title,
        assetPath: assetPath,
        onTap: onTap,
      ),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => HomeActionCardHandset(
          title: title,
          assetPath: assetPath,
          onTap: onTap,
        ),
        tablet: (_, _) => HomeActionCardTablet(
          title: title,
          assetPath: assetPath,
          onTap: onTap,
        ),
      ),
    );
  }
}
