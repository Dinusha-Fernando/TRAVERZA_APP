import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/route_waypoint.dart';
import '../theme/app_theme.dart';
import '../utils/maps_launcher.dart';

/// Real Google Map Widget for TRAVERZA Sri Lanka
/// Uses real Google Maps tiles (Satellite Hybrid, Terrain, and Road) with real GPS
/// coordinates, interactive markers, polyline routing, and deep navigation links.
class SriLankaMapCanvas extends StatefulWidget {
  final List<RouteWaypoint> waypoints;
  final Function(RouteWaypoint)? onWaypointSelected;
  final bool isCompact;

  const SriLankaMapCanvas({
    super.key,
    this.waypoints = TraverzaWaypoints.pilotTripWaypoints,
    this.onWaypointSelected,
    this.isCompact = false,
  });

  @override
  State<SriLankaMapCanvas> createState() => _SriLankaMapCanvasState();
}

class _SriLankaMapCanvasState extends State<SriLankaMapCanvas> {
  final MapController _mapController = MapController();
  int _selectedWaypointIndex = 2; // Default to Sigiriya Rock Fortress
  String _activeRouteFilter = 'Day 1'; // 'Day 1', '3 Days', 'Elevation'
  String _mapLayerType = 'satellite'; // 'satellite', 'terrain', 'roadmap'

  // Detect automated widget testing environment to prevent network tile errors
  bool get _isTestingMode {
    return WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding');
  }

  List<RouteWaypoint> get _visibleWaypoints {
    if (_activeRouteFilter == 'Day 1') {
      return widget.waypoints.where((w) => w.day == 1).toList();
    }
    return widget.waypoints;
  }

  String _getGoogleMapTileUrl() {
    switch (_mapLayerType) {
      case 'terrain':
        return 'https://mt1.google.com/vt/lyrs=p&x={x}&y={y}&z={z}';
      case 'roadmap':
        return 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}';
      case 'satellite':
      default:
        // Google Hybrid: Satellite imagery + Roads & Labels
        return 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}';
    }
  }

  void _selectWaypoint(RouteWaypoint wp) {
    setState(() {
      _selectedWaypointIndex = widget.waypoints.indexOf(wp);
    });
    _mapController.move(LatLng(wp.latitude, wp.longitude), 12.5);
    widget.onWaypointSelected?.call(wp);
  }

  void _recenterCorridor() {
    // Center between Colombo, Kandy, and Sigiriya
    _mapController.move(const LatLng(7.5500, 80.5000), 8.8);
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1.0);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1.0);
  }

  void _openGoogleMapsForWaypoint(RouteWaypoint wp) {
    TraverzaMapsLauncher.openDirections(
      destinationLat: wp.latitude,
      destinationLng: wp.longitude,
      destinationName: wp.title,
    );
  }

  void _openFullDayRouteInGoogleMaps() {
    TraverzaMapsLauncher.openFullTripRoute(
      origin: 'Bandaranaike International Airport, Katunayake',
      destination: 'Sigiriya Water Garden, Sigiriya',
      waypoints: ['Sigiriya Rock Fortress, Sigiriya'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedWp = widget.waypoints[_selectedWaypointIndex];
    final routePoints = _visibleWaypoints.map((w) => LatLng(w.latitude, w.longitude)).toList();

    return Container(
      decoration: BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TraverzaColors.border),
        boxShadow: [
          BoxShadow(
            color: TraverzaColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar with Google Maps Branded Action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: TraverzaColors.primary,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.map_rounded, color: TraverzaColors.accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Interactive Route Map',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'GPS Corridor & Google Maps Navigation',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Quick Full Route Button
                InkWell(
                  onTap: _openFullDayRouteInGoogleMaps,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: TraverzaColors.secondary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.directions_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Google Maps',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Itinerary Filter Mode Pills
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _buildRouteFilterPill('Day 1', 'Day 1 Route'),
                const SizedBox(width: 8),
                _buildRouteFilterPill('3 Days', 'Full 3-Day Corridor'),
                const SizedBox(width: 8),
                _buildRouteFilterPill('Elevation', 'Highland Terrain'),
              ],
            ),
          ),

          // Real Google Map Viewport
          SizedBox(
            height: widget.isCompact ? 240 : 320,
            child: Stack(
              children: [
                // Real Google Map with FlutterMap
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(7.5500, 80.5000),
                    initialZoom: 8.8,
                    minZoom: 6.5,
                    maxZoom: 18.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    // Real Google Maps Tile Layer (Satellite Hybrid, Terrain, or Street)
                    if (!_isTestingMode)
                      TileLayer(
                        urlTemplate: _getGoogleMapTileUrl(),
                        userAgentPackageName: 'com.traverza.mobile',
                        maxZoom: 19,
                      )
                    else
                      // Test-safe container to avoid network calls during widget testing
                      Container(color: const Color(0xFFE2EFF5)),

                    // Itinerary Route Polyline
                    PolylineLayer(
                      polylines: [
                        // Outer glow border
                        Polyline(
                          points: routePoints,
                          strokeWidth: 6.0,
                          color: TraverzaColors.accent.withValues(alpha: 0.6),
                        ),
                        // Core solid route line
                        Polyline(
                          points: routePoints,
                          strokeWidth: 3.0,
                          color: TraverzaColors.primary,
                        ),
                      ],
                    ),

                    // Interactive Waypoint Markers
                    MarkerLayer(
                      markers: _visibleWaypoints.map((wp) {
                        final isSelected = wp.id == selectedWp.id;
                        return Marker(
                          point: LatLng(wp.latitude, wp.longitude),
                          width: isSelected ? 48 : 36,
                          height: isSelected ? 48 : 36,
                          child: GestureDetector(
                            onTap: () => _selectWaypoint(wp),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Selected Pulse Halo
                                if (isSelected)
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: wp.pinColor.withValues(alpha: 0.35),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),

                                // Marker Pin Body
                                Container(
                                  width: isSelected ? 34 : 28,
                                  height: isSelected ? 34 : 28,
                                  decoration: BoxDecoration(
                                    color: wp.pinColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: isSelected ? 2.5 : 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.35),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      wp.icon,
                                      size: isSelected ? 18 : 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                                // Day Badge
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: TraverzaColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.white, width: 1),
                                    ),
                                    child: Text(
                                      'D${wp.day}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // Floating Google Map Layer Switcher (Top Left)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLayerToggle('satellite', 'Satellite'),
                        _buildLayerToggle('terrain', 'Terrain'),
                        _buildLayerToggle('roadmap', 'Roads'),
                      ],
                    ),
                  ),
                ),

                // Floating Map Controls (Zoom & Recenter) (Top Right)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Column(
                    children: [
                      _buildFloatingMapButton(
                        icon: Icons.add,
                        onTap: _zoomIn,
                        tooltip: 'Zoom In',
                      ),
                      const SizedBox(height: 6),
                      _buildFloatingMapButton(
                        icon: Icons.remove,
                        onTap: _zoomOut,
                        tooltip: 'Zoom Out',
                      ),
                      const SizedBox(height: 6),
                      _buildFloatingMapButton(
                        icon: Icons.my_location_rounded,
                        onTap: _recenterCorridor,
                        tooltip: 'Recenter Sri Lanka',
                      ),
                    ],
                  ),
                ),

                // Official Google Watermark / Attribution Badge (Bottom Left)
                Positioned(
                  bottom: 8,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.public_rounded, size: 12, color: TraverzaColors.secondary),
                        SizedBox(width: 4),
                        Text(
                          'Google Maps Live Engine',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: TraverzaColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Selected Waypoint Details & Google Maps Action Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: TraverzaColors.background,
              border: Border(top: BorderSide(color: TraverzaColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: selectedWp.pinColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selectedWp.pinColor.withValues(alpha: 0.3)),
                      ),
                      child: Icon(selectedWp.icon, color: selectedWp.pinColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: selectedWp.pinColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'DAY ${selectedWp.day} • ${selectedWp.category}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                selectedWp.time,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: TraverzaColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedWp.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: TraverzaColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 12, color: TraverzaColors.secondary),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  selectedWp.location,
                                  style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Elevation & Transit Buffer Callout
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: TraverzaColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: TraverzaColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.terrain_rounded, size: 14, color: TraverzaColors.secondary),
                          const SizedBox(width: 4),
                          Text(
                            'Elevation: ${selectedWp.altitudeMeters}m',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: TraverzaColors.text,
                            ),
                          ),
                        ],
                      ),
                      if (selectedWp.driveTimeFromPrev != null)
                        Text(
                          selectedWp.driveTimeFromPrev!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: TraverzaColors.secondary,
                          ),
                        ),
                    ],
                  ),
                ),

                if (selectedWp.transitBufferNote != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 12, color: TraverzaColors.amberWarning),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          selectedWp.transitBufferNote!,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: TraverzaColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // Action Buttons: Navigate on Google Maps
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openGoogleMapsForWaypoint(selectedWp),
                        icon: const Icon(Icons.directions, size: 16),
                        label: const Text(
                          'Navigate in Google Maps',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TraverzaColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        TraverzaMapsLauncher.openLocation(
                          latitude: selectedWp.latitude,
                          longitude: selectedWp.longitude,
                          label: selectedWp.title,
                        );
                      },
                      icon: const Icon(Icons.place_outlined, size: 16),
                      label: const Text('View Place', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TraverzaColors.secondary,
                        side: const BorderSide(color: TraverzaColors.secondary),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteFilterPill(String filter, String label) {
    final isActive = _activeRouteFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _activeRouteFilter = filter);
          if (filter == 'Elevation') {
            setState(() => _mapLayerType = 'terrain');
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? TraverzaColors.secondary : TraverzaColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? TraverzaColors.secondary : TraverzaColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? Colors.white : TraverzaColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayerToggle(String type, String label) {
    final isSelected = _mapLayerType == type;
    return GestureDetector(
      onTap: () => setState(() => _mapLayerType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? TraverzaColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : TraverzaColors.text,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingMapButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: TraverzaColors.primary),
      ),
    );
  }
}
