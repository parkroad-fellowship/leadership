import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:leadership/shared_widgets/navbar/_handset.dart';
import 'package:leadership/shared_widgets/navbar/_tablet.dart';

class PRFNavBar extends StatelessWidget {
  const PRFNavBar({
    required this.title,
    super.key,
    this.onBack,
    this.actions,
    this.backIcon,
    this.backgroundColor,
    this.centerTitle = true,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final IconData? backIcon;
  final Color? backgroundColor;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (_, _) => PRFNavBarTablet(
        title: title,
        onBack: onBack,
        actions: actions,
        backIcon: backIcon,
        backgroundColor: backgroundColor,
        centerTitle: centerTitle,
      ),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => PRFNavBarHandset(
          title: title,
          onBack: onBack,
          actions: actions,
          backIcon: backIcon,
          backgroundColor: backgroundColor,
          centerTitle: centerTitle,
        ),
        tablet: (_, _) => PRFNavBarTablet(
          title: title,
          onBack: onBack,
          actions: actions,
          backIcon: backIcon,
          backgroundColor: backgroundColor,
          centerTitle: centerTitle,
        ),
      ),
    );
  }
}
