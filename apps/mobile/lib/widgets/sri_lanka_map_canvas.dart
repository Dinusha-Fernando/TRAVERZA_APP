import 'package:flutter/material.dart';
import '../models/route_waypoint.dart';
import '../theme/app_theme.dart';
import '../utils/maps_launcher.dart';

/// Creative Sri Lanka Interactive Route Map Widget
/// Visualizes tourist itineraries with real GPS coordinates, elevation gradients,
/// interactive stop markers, and deep integration with Google Maps.
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
  int _selectedWaypointIndex = 2; // Default to Sigiriya Rock Fortress
  String _activeMode = 'Day 1'; // 'Day 1', '3 Days', 'Elevation'

  List<RouteWaypoint> get _visibleWaypoints {
    if (_activeMode == 'Day 1') {
      return widget.waypoints.where((w) => w.day == 1).toList();
    }
    return widget.waypoints;
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

    return Container(
      decoration: BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TraverzaColors.border),
        boxShadow: [
          BoxShadow(
            color: TraverzaColors.primary.withValues(alpha: 0.06),
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

          // Map View Mode Selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _buildModePill('Day 1', 'Day 1 Route'),
                const SizedBox(width: 8),
                _buildModePill('3 Days', 'Full 3-Day Corridor'),
                const SizedBox(width: 8),
                _buildModePill('Elevation', 'Highland Terrain'),
              ],
            ),
          ),

          // Map Canvas Area
          SizedBox(
            height: widget.isCompact ? 220 : 280,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                return Stack(
                  children: [
                    // Base Sri Lanka island & route lines painter
                    CustomPaint(
                      size: canvasSize,
                      painter: _SriLankaMapPainter(
                        waypoints: _visibleWaypoints,
                        selectedWaypoint: selectedWp,
                        showElevationGradients: _activeMode == 'Elevation',
                      ),
                    ),

                    // Interactive Waypoint Markers
                    ..._visibleWaypoints.map((wp) {
                      final pos = wp.getNormalizedPosition(canvasSize);
                      final isSelected = wp.id == selectedWp.id;

                      return Positioned(
                        left: pos.dx - 18,
                        top: pos.dy - 18,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedWaypointIndex = widget.waypoints.indexOf(wp);
                            });
                            widget.onWaypointSelected?.call(wp);
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Selected Halo
                              if (isSelected)
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: wp.pinColor.withValues(alpha: 0.22),
                                    border: Border.all(
                                      color: wp.pinColor.withValues(alpha: 0.45),
                                      width: 1.5,
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
                                      color: Colors.black.withValues(alpha: 0.25),
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
                    }),

                    // Map Watermark & Scale Badge
                    Positioned(
                      bottom: 8,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: TraverzaColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.satellite_alt_rounded, size: 10, color: TraverzaColors.textMuted),
                            SizedBox(width: 4),
                            Text(
                              'Sri Lanka Terrain Grid',
                              style: TextStyle(fontSize: 9, color: TraverzaColors.textMuted, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
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
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: selectedWp.pinColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selectedWp.pinColor.withValues(alpha: 0.3)),
                      ),
                      child: Icon(selectedWp.icon, color: selectedWp.pinColor, size: 22),
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

  Widget _buildModePill(String mode, String label) {
    final isActive = _activeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeMode = mode),
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
}

/// Custom painter for Sri Lanka map contours, central highlands, and route paths
class _SriLankaMapPainter extends CustomPainter {
  final List<RouteWaypoint> waypoints;
  final RouteWaypoint selectedWaypoint;
  final bool showElevationGradients;

  _SriLankaMapPainter({
    required this.waypoints,
    required this.selectedWaypoint,
    required this.showElevationGradients,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = const Color(0xFFF0F7FB)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Island Outline (approximated teardrop shape of Sri Lanka)
    final islandPath = Path();
    final w = size.width;
    final h = size.height;

    islandPath.moveTo(w * 0.44, h * 0.08); // Point Pedro / Jaffna
    islandPath.quadraticBezierTo(w * 0.36, h * 0.20, w * 0.30, h * 0.35); // Mannar / North West
    islandPath.quadraticBezierTo(w * 0.24, h * 0.50, w * 0.26, h * 0.65); // Colombo coast
    islandPath.quadraticBezierTo(w * 0.30, h * 0.82, w * 0.45, h * 0.92); // Galle / Dondra Head (South)
    islandPath.quadraticBezierTo(w * 0.65, h * 0.88, w * 0.74, h * 0.70); // Yala / Hambantota
    islandPath.quadraticBezierTo(w * 0.80, h * 0.52, w * 0.70, h * 0.32); // Batticaloa / Trincomalee
    islandPath.quadraticBezierTo(w * 0.58, h * 0.16, w * 0.44, h * 0.08); // Back to Jaffna
    islandPath.close();

    // Fill Island with landmass gradient
    final landGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFE2EFF5),
        showElevationGradients ? const Color(0xFFD3E7DC) : const Color(0xFFE8F1F5),
        const Color(0xFFE2EFF5),
      ],
    );

    final landPaint = Paint()
      ..shader = landGradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;
    canvas.drawPath(islandPath, landPaint);

    // Island Coastline Border
    final coastBorderPaint = Paint()
      ..color = const Color(0xFF90C2DE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(islandPath, coastBorderPaint);

    // Central Highlands Hill Country Contour
    if (showElevationGradients) {
      final highlandPaint = Paint()
        ..color = const Color(0xFF087E8B).withValues(alpha: 0.18)
        ..style = PaintingStyle.fill;

      final highlandRect = Rect.fromCenter(
        center: Offset(w * 0.48, h * 0.66),
        width: w * 0.28,
        height: h * 0.26,
      );
      canvas.drawOval(highlandRect, highlandPaint);

      final peakPaint = Paint()
        ..color = const Color(0xFF073B5C).withValues(alpha: 0.22)
        ..style = PaintingStyle.fill;
      final peakRect = Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.70),
        width: w * 0.16,
        height: h * 0.14,
      );
      canvas.drawOval(peakRect, peakPaint);
    }

    // Connect Waypoints with glowing Route Polylines
    if (waypoints.length >= 2) {
      final routePath = Path();
      for (int i = 0; i < waypoints.length; i++) {
        final pt = waypoints[i].getNormalizedPosition(size);
        if (i == 0) {
          routePath.moveTo(pt.dx, pt.dy);
        } else {
          // Smooth curve to next point
          final prevPt = waypoints[i - 1].getNormalizedPosition(size);
          final midX = (prevPt.dx + pt.dx) / 2;
          final midY = (prevPt.dy + pt.dy) / 2;
          routePath.quadraticBezierTo(prevPt.dx, prevPt.dy, midX, midY);
          routePath.lineTo(pt.dx, pt.dy);
        }
      }

      // Outer glow line
      final glowPaint = Paint()
        ..color = TraverzaColors.accent.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(routePath, glowPaint);

      // Core route line
      final coreRoutePaint = Paint()
        ..color = TraverzaColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(routePath, coreRoutePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SriLankaMapPainter oldDelegate) {
    return oldDelegate.waypoints != waypoints ||
        oldDelegate.selectedWaypoint != selectedWaypoint ||
        oldDelegate.showElevationGradients != showElevationGradients;
  }
}
