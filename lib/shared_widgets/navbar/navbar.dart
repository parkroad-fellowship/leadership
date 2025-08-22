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
    this.isSliver = true,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final IconData? backIcon;
  final Color? backgroundColor;
  final bool centerTitle;
  final bool isSliver;

  @override
  Widget build(BuildContext context) {
    final navBar = AdaptiveBuilder(
      defaultBuilder: (_, _) => PRFNavBarTablet(
        title: title,
        onBack: onBack,
        actions: actions,
        backIcon: backIcon,
        backgroundColor: backgroundColor,
        centerTitle: centerTitle,
        isSliver: isSliver,
      ),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (_, _) => PRFNavBarHandset(
          title: title,
          onBack: onBack,
          actions: actions,
          backIcon: backIcon,
          backgroundColor: backgroundColor,
          centerTitle: centerTitle,
          isSliver: isSliver,
        ),
        tablet: (_, _) => PRFNavBarTablet(
          title: title,
          onBack: onBack,
          actions: actions,
          backIcon: backIcon,
          backgroundColor: backgroundColor,
          centerTitle: centerTitle,
          isSliver: isSliver,
        ),
      ),
    );

    // If not used as sliver, wrap in SafeArea for normal AppBar usage
    if (!isSliver) {
      return SafeArea(child: navBar);
    }

    return navBar;
  }
}

// Create a separate class for normal AppBar usage
class PRFAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PRFAppBar({
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
    return PRFNavBar(
      title: title,
      onBack: onBack,
      actions: actions,
      backIcon: backIcon,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      isSliver: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
