import 'package:flutter/material.dart';
import 'package:prf_design/prf_design.dart';

/// A large, labelled, single-select option used by the expense forms
/// (expense category, payment method).
///
/// At least 48dp tall, announces itself as a selectable button and gives
/// ripple feedback. The selection colour change respects reduced motion.
class ExpenseChoiceChip extends StatelessWidget {
  const ExpenseChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.enabled = true,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = selected ? scheme.onPrimary : scheme.onSurface;
    final radius = BorderRadius.circular(PRFRadiusTokens.md);

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: PRFSizeTokens.minTouchTarget,
          maxWidth: MediaQuery.sizeOf(context).width * 0.7,
        ),
        child: AnimatedContainer(
          duration: PRFMotionTokens.resolve(context, PRFMotionTokens.standard),
          decoration: BoxDecoration(
            color: selected ? scheme.primary : scheme.surfaceContainerHighest,
            borderRadius: radius,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: radius,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: PRFSizeTokens.minTouchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PRFSpacingTokens.lg,
                    vertical: PRFSpacingTokens.sm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: PRFSizeTokens.iconSm,
                          color: selected
                              ? scheme.onPrimary
                              : scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: PRFSpacingTokens.sm),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: foreground,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
