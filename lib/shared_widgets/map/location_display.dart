import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

    if (!_hasValidCoordinates) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No location set',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              FlutterMap(
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
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_pin,
                          color: theme.colorScheme.primary,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Attribution badge (required by OSM tile policy)
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: '© ',
                      style: theme.textTheme.labelSmall,
                      children: [
                        TextSpan(
                          text: 'OpenStreetMap',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.blue.shade700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(
                          text: ' contributors',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Coordinates badge
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${latitude.toStringAsFixed(4)}, '
                    '${longitude.toStringAsFixed(4)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showOpenInMapsButton && onOpenInMaps != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onOpenInMaps,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Open in Maps'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
