import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              FlutterMap(
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
                  if (_selectedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation!,
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
              // Zoom controls
              Positioned(
                right: 8,
                bottom: 32,
                child: Column(
                  children: [
                    _buildMapButton(
                      icon: Icons.add,
                      onPressed: () {
                        final currentZoom = _mapController.camera.zoom;
                        _mapController.move(
                          _mapController.camera.center,
                          currentZoom + 1,
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    _buildMapButton(
                      icon: Icons.remove,
                      onPressed: () {
                        final currentZoom = _mapController.camera.zoom;
                        _mapController.move(
                          _mapController.camera.center,
                          currentZoom - 1,
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Center on selected location button
              if (_selectedLocation != null)
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: _buildMapButton(
                    icon: Icons.my_location,
                    onPressed: () {
                      _mapController.move(_selectedLocation!, _defaultZoom);
                    },
                  ),
                ),
            ],
          ),
        ),
        if (_selectedLocation != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selected: '
                    '${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                    '${_selectedLocation!.longitude.toStringAsFixed(6)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            'Tap on the map to select a location',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
