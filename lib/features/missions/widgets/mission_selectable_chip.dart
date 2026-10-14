import 'package:flutter/material.dart';
import 'package:prf_design/prf_design.dart';

/// Single-choice chip with a 48dp touch target, ripple and selected
/// semantics, used by the soul and subscriber forms.
class MissionSelectableChip extends StatelessWidget {
  const MissionSelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.maxWidth,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(PRFRadiusTokens.xl);

    return Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: PRFMotionTokens.resolve(
              context,
              PRFMotionTokens.standard,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: PRFSpacingTokens.lg,
              vertical: PRFSpacingTokens.sm,
            ),
            constraints: BoxConstraints(
              minHeight: PRFSizeTokens.minTouchTarget,
              maxWidth: maxWidth ?? double.infinity,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: PRFOpacities.half,
                    ),
              borderRadius: radius,
              border: Border.all(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(
                        alpha: PRFOpacities.glow,
                      ),
              ),
            ),
            child: Text(
              label,
              maxLines: 2,
              softWrap: true,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
