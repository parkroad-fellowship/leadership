import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/shared_widgets/map/map_attribution.dart';
import 'package:prf_design/prf_design.dart';

/// A widget that allows users to pick a location on a map.
/// Tapping on the map will place a marker and return the coordinates.
class LocationPicker extends StatefulWidget {
  const LocationPicker({
    required this.onLocationSelected,
    this.initialLatitude,
    this.initialLongitude,
    this.height = 300,
    super.key,
  });

  /// Callback when a location is selected on the map.
  final void Function(double latitude, double longitude) onLocationSelected;

  /// Initial latitude to center the map on.
  final double? initialLatitude;

  /// Initial longitude to center the map on.
  final double? initialLongitude;

  /// Height of the map widget.
  final double height;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late final MapController _mapController;
  LatLng? _selectedLocation;

  // Default center (can be customized for your region)
  static const _defaultCenter = LatLng(-1.2921, 36.8219); // Nairobi, Kenya
  static const _defaultZoom = 14.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Set initial selected location if provided
    if (widget.initialLatitude != null &&
        widget.initialLongitude != null &&
        widget.initialLatitude != 0.0 &&
        widget.initialLongitude != 0.0) {
      _selectedLocation = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  LatLng get _initialCenter {
    if (widget.initialLatitude != null &&
        widget.initialLongitude != null &&
        widget.initialLatitude != 0.0 &&
        widget.initialLongitude != 0.0) {
      return LatLng(widget.initialLatitude!, widget.initialLongitude!);
    }
    return _defaultCenter;
  }

  void _onTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
    widget.onLocationSelected(point.latitude, point.longitude);
  }

  void _zoomBy(double delta) {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom + delta,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final selected = _selectedLocation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PRFRadiusTokens.smd),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(
                alpha: PRFOpacities.glow,
              ),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Semantics(
                label: l10n.mapLocationLabel,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialCenter,
                    initialZoom: _defaultZoom,
                    onTap: _onTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'org.parkroadfellowship.leadership',
                    ),
                    if (selected != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selected,
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
              // Zoom controls
              Positioned(
                right: PRFSpacingTokens.sm,
                bottom: PRFSpacingTokens.xxl,
                child: Column(
                  children: [
                    MapControlButton(
                      icon: Icons.add,
                      label: l10n.mapZoomIn,
                      onPressed: () => _zoomBy(1),
                    ),
                    const SizedBox(height: PRFSpacingTokens.sm),
                    MapControlButton(
                      icon: Icons.remove,
                      label: l10n.mapZoomOut,
                      onPressed: () => _zoomBy(-1),
                    ),
                  ],
                ),
              ),
              // Center on selected location button
              if (selected != null)
                Positioned(
                  left: PRFSpacingTokens.sm,
                  bottom: PRFSpacingTokens.sm,
                  child: MapControlButton(
                    icon: Icons.my_location,
                    label: l10n.mapGoToPin,
                    onPressed: () =>
                        _mapController.move(selected, _defaultZoom),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: PRFSpacingTokens.sm),
        if (selected != null)
          Semantics(
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PRFSpacingTokens.md,
                vertical: PRFSpacingTokens.sm,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: PRFOpacities.glow,
                ),
                borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: PRFSizeTokens.iconSm,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: PRFSpacingTokens.sm),
                  Expanded(
                    child: Text(
                      l10n.mapSelectedLocation(
                        selected.latitude.toStringAsFixed(6),
                        selected.longitude.toStringAsFixed(6),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Text(
            l10n.mapTapToSelect,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
