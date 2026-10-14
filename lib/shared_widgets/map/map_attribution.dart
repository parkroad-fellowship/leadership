import 'package:flutter/material.dart';
import 'package:prf_design/prf_design.dart';

/// "© OpenStreetMap contributors" badge required by the OSM tile policy.
///
/// The wording is a licence notice, so it is not translated.
class MapAttribution extends StatelessWidget {
  const MapAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurface,
    );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PRFSpacingTokens.sm,
        vertical: PRFSpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(
          alpha: PRFOpacities.nearOpaque,
        ),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.xs),
      ),
      child: Text.rich(
        TextSpan(
          text: '© ',
          style: style,
          children: [
            TextSpan(
              text: 'OpenStreetMap',
              style: style?.copyWith(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(text: ' contributors', style: style),
          ],
        ),
      ),
    );
  }
}

/// Square 48 dp map control with a tooltip and screen-reader label.
class MapControlButton extends StatelessWidget {
  const MapControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(PRFRadiusTokens.sm);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: Material(
          color: scheme.surface,
          borderRadius: radius,
          elevation: PRFElevationTokens.sm,
          shadowColor: scheme.shadow,
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: SizedBox(
              width: PRFSizeTokens.minTouchTarget,
              height: PRFSizeTokens.minTouchTarget,
              child: Icon(
                icon,
                size: PRFSizeTokens.iconMd,
                color: scheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
