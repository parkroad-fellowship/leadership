import 'package:flutter/material.dart';
import 'package:prf_design/prf_design.dart';

enum PRFHeaderActionButtonVariant {
  primary,
  neutral,
}

class PRFHeaderActionButton extends StatelessWidget {
  const PRFHeaderActionButton({
    required this.label,
    required this.onTap,
    super.key,
    this.icon,
    this.variant = PRFHeaderActionButtonVariant.primary,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final PRFHeaderActionButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPrimary = variant == PRFHeaderActionButtonVariant.primary;
    final backgroundColor = isPrimary
        ? theme.colorScheme.secondary
        : theme.colorScheme.onPrimary.withValues(alpha: 0.14);
    final foregroundColor = isPrimary
        ? theme.colorScheme.primary
        : theme.colorScheme.onPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PRFSpacingTokens.md,
          vertical: PRFSpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
          border: isPrimary
              ? null
              : Border.all(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.18),
                ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: foregroundColor,
              ),
              const SizedBox(width: PRFSpacingTokens.xs),
            ],
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
