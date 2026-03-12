import 'package:flutter/foundation.dart';

class LandingActionItem {
  const LandingActionItem({
    required this.title,
    required this.assetPath,
    required this.onTap,
    required this.animationDelay,
    required this.isVisible,
  });

  final String title;
  final String assetPath;
  final VoidCallback onTap;
  final int animationDelay;
  final bool isVisible;
}
