import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/shared_widgets/map/map_attribution.dart';
import 'package:prf_design/prf_design.dart';

/// A widget that displays a location on a map with a marker.
/// This is a read-only view for displaying school locations.
class LocationDisplay extends StatelessWidget {
  const LocationDisplay({
    required this.latitude,
    required this.longitude,
    this.height = 200,
    this.schoolName,
    this.showOpenInMapsButton = true,
    this.onOpenInMaps,
    super.key,
  });

  /// The latitude of the location to display.
  final double latitude;

  /// The longitude of the location to display.
  final double longitude;

  /// Height of the map widget.
  final double height;

  /// Optional school name to display in the marker popup.
  final String? schoolName;

  /// Whether to show the "Open in Maps" button.
  final bool showOpenInMapsButton;

  /// Callback when "Open in Maps" is pressed.
  final VoidCallback? onOpenInMaps;

  bool get _hasValidCoordinates => latitude != 0.0 || longitude != 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final radius = BorderRadius.circular(PRFRadiusTokens.smd);
    final border = Border.all(
      color: theme.colorScheme.outline.withValues(alpha: PRFOpacities.muted),
    );

    if (!_hasValidCoordinates) {
      return Container(
        constraints: BoxConstraints(minHeight: height),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: radius,
          border: border,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off_outlined,
                size: PRFSizeTokens.iconXxxl,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: PRFSpacingTokens.sm),
              Text(
                l10n.mapNoLocation,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final location = LatLng(latitude, longitude);
    final coordinates =
        '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(borderRadius: radius, border: border),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Semantics(
                label: '${schoolName ?? l10n.mapLocationLabel}. $coordinates',
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: location,
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'org.parkroadfellowship.leadership',
                      maxZoom: 19,
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: location,
                          width: PRFSizeTokens.iconXxl,
                          height: PRFSizeTokens.iconXxl,
                          child: Icon(
                            Icons.location_pin,
                            color: theme.colorScheme.primary,
                            size: PRFSizeTokens.iconXxl,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Attribution badge (required by OSM tile policy)
              const Positioned(
                right: PRFSpacingTokens.sm,
                bottom: PRFSpacingTokens.sm,
                child: MapAttribution(),
              ),
              // Coordinates badge
              Positioned(
                left: PRFSpacingTokens.sm,
                bottom: PRFSpacingTokens.sm,
                child: ExcludeSemantics(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PRFSpacingTokens.sm,
                      vertical: PRFSpacingTokens.xs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(
                        alpha: PRFOpacities.nearOpaque,
                      ),
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.xs),
                      boxShadow: PRFShadowTokens.card(theme.colorScheme.shadow),
                    ),
                    child: Text(
                      coordinates,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showOpenInMapsButton && onOpenInMaps != null) ...[
          const SizedBox(height: PRFSpacingTokens.sm),
          PRFButton(
            onPressed: onOpenInMaps!,
            title: l10n.mapOpenInMaps,
            icon: Icons.open_in_new,
            variant: PRFButtonVariant.outlined,
          ),
        ],
      ],
    );
  }
}
