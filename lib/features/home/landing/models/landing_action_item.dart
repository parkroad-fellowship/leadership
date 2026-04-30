import 'package:flutter/foundation.dart';

class LandingActionItem {
  const LandingActionItem({
    required this.title,
    required this.assetPath,
    required this.onTap,
    required this.animationDelay,
    required this.isVisible,
    this.isNeutralCard = false,
    this.isSettings = false,
    this.deskGroup,
  });

  final String title;
  final String assetPath;
  final VoidCallback onTap;
  final int animationDelay;
  final bool isVisible;
  final bool isNeutralCard;
  final bool isSettings;
  final String? deskGroup;
}
