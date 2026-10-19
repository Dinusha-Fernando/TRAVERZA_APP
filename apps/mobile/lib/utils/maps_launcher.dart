import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Creative Google Maps Launcher for TRAVERZA Sri Lanka
/// Provides deep-linking into Google Maps for navigation, corridor exploration, and emergency routing.
class TraverzaMapsLauncher {
  TraverzaMapsLauncher._();

  /// Opens Google Maps with a specific coordinate and search label
  static Future<bool> openLocation({
    required double latitude,
    required double longitude,
    required String label,
  }) async {
    final encodedLabel = Uri.encodeComponent(label);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$encodedLabel',
    );
    return _launch(uri);
  }

  /// Opens turn-by-turn driving directions in Google Maps
  static Future<bool> openDirections({
    required double destinationLat,
    required double destinationLng,
    String? destinationName,
    double? originLat,
    double? originLng,
    List<String>? waypoints,
    String travelMode = 'driving', // driving, walking, transit
  }) async {
    String url = 'https://www.google.com/maps/dir/?api=1'
        '&destination=$destinationLat,$destinationLng'
        '&travelmode=$travelMode';

    if (originLat != null && originLng != null) {
      url += '&origin=$originLat,$originLng';
    }

    if (waypoints != null && waypoints.isNotEmpty) {
      final encodedWaypoints = waypoints.map((w) => Uri.encodeComponent(w)).join('|');
      url += '&waypoints=$encodedWaypoints';
    }

    final uri = Uri.parse(url);
    return _launch(uri);
  }

  /// Opens Google Maps with a full Sri Lanka itinerary multi-stop route
  static Future<bool> openFullTripRoute({
    required String origin,
    required String destination,
    required List<String> waypoints,
  }) async {
    final encodedOrigin = Uri.encodeComponent(origin);
    final encodedDest = Uri.encodeComponent(destination);
    final encodedWaypoints = waypoints.map((w) => Uri.encodeComponent(w)).join('|');

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=$encodedOrigin'
      '&destination=$encodedDest'
      '&waypoints=$encodedWaypoints'
      '&travelmode=driving',
    );
    return _launch(uri);
  }

  /// Opens emergency directions to nearest hospital or tourist police
  static Future<bool> openEmergencyRoute({
    required double lat,
    required double lng,
    required String facilityName,
  }) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$lat,$lng'
      '&travelmode=driving',
    );
    return _launch(uri);
  }

  /// Helper to safely launch URLs
  static Future<bool> _launch(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to platform default
        return await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('TraverzaMapsLauncher error: $e');
      return false;
    }
  }
}
