import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:prf_design/prf_design.dart';

/// Shared building blocks for the requisition details page and its action
/// sheets (approve, recall, request review, create/edit requisition and
/// items, payment instructions).

/// Formats a whole-shilling amount as e.g. `KES 12,000`.
String formatKes(num amount) =>
    NumberFormat.currency(symbol: 'KES ', decimalDigits: 0).format(amount);

/// Soft primary-tinted backdrop used behind every action sheet.
BoxDecoration requisitionSheetBackground(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        scheme.primary.withValues(alpha: PRFOpacities.faint),
        scheme.surface,
      ],
    ),
  );
}

/// Coloured header card at the top of an action sheet.
///
/// Defaults to a primary fill with `onPrimary` content. Pass a status set's
/// `main` / `onColor` pair (or `secondary` / `onSecondary`) for other tones.
Widget requisitionActionHeader(
  BuildContext context, {
  required IconData icon,
  required String title,
  String? subtitle,
  Widget? footer,
  Color? background,
  Color? foreground,
}) {
  final theme = Theme.of(context);
  final fill = background ?? theme.colorScheme.primary;
  final onFill = foreground ?? theme.colorScheme.onPrimary;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(PRFSpacingTokens.xl),
    decoration: BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
      boxShadow: PRFShadowTokens.card(theme.colorScheme.shadow),
    ),
    child: Column(
      children: [
        ExcludeSemantics(
          child: Icon(icon, size: PRFSizeTokens.iconXl, color: onFill),
        ),
        const SizedBox(height: PRFSpacingTokens.sm),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: onFill,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: onFill),
          ),
        ],
        if (footer != null) ...[
          const SizedBox(height: PRFSpacingTokens.md),
          footer,
        ],
      ],
    ),
  );
}

/// Bordered surface card that holds a sheet's form fields.
Widget requisitionFormCard(BuildContext context, {required Widget child}) {
  final scheme = Theme.of(context).colorScheme;
  return Container(
    padding: const EdgeInsets.all(PRFSpacingTokens.xl),
    decoration: BoxDecoration(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
      border: Border.all(color: scheme.outlineVariant),
      boxShadow: PRFShadowTokens.card(scheme.shadow),
    ),
    child: child,
  );
}

/// Tinted banner that explains the current status (text on a status
/// `background` uses the set's `foreground`, which passes AA).
Widget requisitionStatusBanner(
  BuildContext context, {
  required StatusColorSet colors,
  required IconData icon,
  required String message,
  EdgeInsetsGeometry? margin,
}) {
  final theme = Theme.of(context);
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(PRFSpacingTokens.md),
    margin: margin,
    decoration: BoxDecoration(
      color: colors.background,
      borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
      border: Border.all(
        color: colors.main.withValues(alpha: PRFOpacities.glow),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Icon(
            icon,
            color: colors.foreground,
            size: PRFSizeTokens.iconMd,
          ),
        ),
        const SizedBox(width: PRFSpacingTokens.sm),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Large, labelled, selectable option (category chip / payment method row)
/// with ripple feedback, a 48 dp minimum target and selection semantics.
class RequisitionSelectableTile extends StatelessWidget {
  const RequisitionSelectableTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.expand = false,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  /// Full-width row (true) or wrapping chip (false).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(
      expand ? PRFRadiusTokens.md : PRFRadiusTokens.xl,
    );
    final Color fill;
    final Color onFill;
    if (expand) {
      fill = selected ? scheme.primaryContainer : scheme.surfaceContainerHigh;
      onFill = selected ? scheme.onPrimaryContainer : scheme.onSurface;
    } else {
      fill = selected ? scheme.primary : scheme.surfaceContainerHigh;
      onFill = selected ? scheme.onPrimary : scheme.onSurface;
    }

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: onFill, size: PRFSizeTokens.iconLg),
          const SizedBox(width: PRFSpacingTokens.lg),
        ],
        Flexible(
          fit: expand ? FlexFit.tight : FlexFit.loose,
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style:
                (expand
                        ? theme.textTheme.bodyLarge
                        : theme.textTheme.bodyMedium)
                    ?.copyWith(
                      color: onFill,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
          ),
        ),
        if (expand && selected) ...[
          const SizedBox(width: PRFSpacingTokens.sm),
          Icon(Icons.check_circle, color: onFill, size: PRFSizeTokens.iconLg),
        ],
      ],
    );

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: PRFMotionTokens.resolve(context, PRFMotionTokens.standard),
        constraints: BoxConstraints(
          minHeight: PRFSizeTokens.minTouchTarget,
          maxWidth: expand
              ? double.infinity
              : MediaQuery.sizeOf(context).width * 0.7,
        ),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: radius,
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: PRFSpacingTokens.lg,
                vertical: expand ? PRFSpacingTokens.lg : PRFSpacingTokens.md,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

/// Reduced-motion aware entrance (fade, optional slide).
extension RequisitionEntrance on Widget {
  Widget entrance(
    BuildContext context, {
    Duration delay = Duration.zero,
    Offset slide = Offset.zero,
  }) {
    final duration = PRFMotionTokens.resolve(
      context,
      PRFMotionTokens.enterShort,
    );
    final animated = animate(
      delay: PRFMotionTokens.resolve(context, delay),
    ).fadeIn(duration: duration, curve: PRFMotionTokens.entering);
    if (slide == Offset.zero) return animated;
    return animated.slide(
      begin: slide,
      end: Offset.zero,
      duration: duration,
      curve: PRFMotionTokens.entering,
    );
  }
}
