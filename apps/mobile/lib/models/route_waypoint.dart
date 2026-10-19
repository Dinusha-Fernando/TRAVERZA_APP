import 'package:flutter/material.dart';

/// Represents a geographically mapped point on the Sri Lanka tourist route
class RouteWaypoint {
  final String id;
  final String title;
  final String location;
  final double latitude;
  final double longitude;
  final int altitudeMeters;
  final String category;
  final String time;
  final int day;
  final String provider;
  final String status;
  final String? transitBufferNote;
  final String? driveTimeFromPrev;
  final IconData icon;
  final Color pinColor;

  const RouteWaypoint({
    required this.id,
    required this.title,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.altitudeMeters,
    required this.category,
    required this.time,
    required this.day,
    required this.provider,
    required this.status,
    this.transitBufferNote,
    this.driveTimeFromPrev,
    required this.icon,
    required this.pinColor,
  });

  /// Approximate pixel offset on a 300x420 normalized Sri Lanka coordinate plane
  /// Sri Lanka bounding box approx: Lat 5.9 to 9.9 N, Lng 79.5 to 81.9 E
  Offset getNormalizedPosition(Size canvasSize) {
    // Map latitude (9.9 north -> 5.9 south) to Y (0 -> height)
    // Map longitude (79.5 west -> 81.9 east) to X (0 -> width)
    const minLat = 5.8;
    const maxLat = 9.9;
    const minLng = 79.5;
    const maxLng = 82.0;

    final xPercent = (longitude - minLng) / (maxLng - minLng);
    final yPercent = 1.0 - ((latitude - minLat) / (maxLat - minLat));

    return Offset(
      canvasSize.width * (0.08 + xPercent * 0.84),
      canvasSize.height * (0.06 + yPercent * 0.88),
    );
  }
}

/// Official Sri Lanka Itinerary Waypoints for TRIP-LK-2026-9041
class TraverzaWaypoints {
  static const List<RouteWaypoint> pilotTripWaypoints = [
    RouteWaypoint(
      id: 'cmb-airport',
      title: 'Bandaranaike Intl Airport (CMB)',
      location: 'Katunayake, Western Province',
      latitude: 7.1808,
      longitude: 79.8841,
      altitudeMeters: 8,
      category: 'FLIGHT',
      time: '09:00 - 10:00',
      day: 1,
      provider: 'SriLankan Airlines • UL-504',
      status: 'CONFIRMED',
      transitBufferNote: '30m customs buffer included',
      driveTimeFromPrev: null,
      icon: Icons.flight_land,
      pinColor: Color(0xFF22B8CF),
    ),
    RouteWaypoint(
      id: 'chauffeur-transfer',
      title: 'Chauffeur Highway Leg',
      location: 'Ambepussa / Kurunegala Corridor',
      latitude: 7.4863,
      longitude: 80.3623,
      altitudeMeters: 116,
      category: 'TRANSFER',
      time: '10:30 - 14:00',
      day: 1,
      provider: 'Ceylon Chauffeurs Guild (Fleet #LK-402)',
      status: 'CONFIRMED',
      transitBufferNote: 'Central highway speed: 65 km/h',
      driveTimeFromPrev: '148 km • 3h 30m',
      icon: Icons.directions_car,
      pinColor: Color(0xFF087E8B),
    ),
    RouteWaypoint(
      id: 'sigiriya-rock',
      title: 'Sigiriya Rock Fortress',
      location: 'Sigiriya, Matale District',
      latitude: 7.9570,
      longitude: 80.7603,
      altitudeMeters: 349,
      category: 'ACTIVITY',
      time: '15:00 - 17:30',
      day: 1,
      provider: 'Cultural Heritage Guide Guild (SLTDA Lic #044)',
      status: 'CONFIRMED',
      transitBufferNote: '45m rest buffer before climb',
      driveTimeFromPrev: '22 km • 35m',
      icon: Icons.landscape,
      pinColor: Color(0xFFF59E0B),
    ),
    RouteWaypoint(
      id: 'sigiriya-villa',
      title: 'Sigiriya Water Garden Eco Villa',
      location: 'Sigiriya, Central Province',
      latitude: 7.9525,
      longitude: 80.7480,
      altitudeMeters: 195,
      category: 'STAY',
      time: '18:30 Check-in',
      day: 1,
      provider: 'Water Garden Eco Resorts (SLTDA Reg #HOT-891)',
      status: 'REQUEST_SUBMITTED',
      transitBufferNote: 'Overnight eco sanctuary',
      driveTimeFromPrev: '4 km • 10m',
      icon: Icons.hotel,
      pinColor: Color(0xFF10B981),
    ),
    RouteWaypoint(
      id: 'kandy-temple',
      title: 'Temple of the Sacred Tooth Relic',
      location: 'Kandy, Central Highlands',
      latitude: 7.2936,
      longitude: 80.6413,
      altitudeMeters: 500,
      category: 'ACTIVITY',
      time: '10:00 - 12:30',
      day: 2,
      provider: 'Kandy Heritage Walks',
      status: 'CONFIRMED',
      transitBufferNote: 'Winding road speed limit 40 km/h',
      driveTimeFromPrev: '91 km • 2h 20m',
      icon: Icons.temple_buddhist,
      pinColor: Color(0xFFF59E0B),
    ),
    RouteWaypoint(
      id: 'nuwara-eliya-tea',
      title: 'Pedro Tea Estate & Highlands',
      location: 'Nuwara Eliya, High Country',
      latitude: 6.9497,
      longitude: 80.7891,
      altitudeMeters: 1868,
      category: 'ACTIVITY',
      time: '14:30 - 17:00',
      day: 3,
      provider: 'Ceylon Tea Trails Concierge',
      status: 'CONFIRMED',
      transitBufferNote: 'Extreme highland winding roads: 32 km/h limit',
      driveTimeFromPrev: '76 km • 2h 45m',
      icon: Icons.local_florist,
      pinColor: Color(0xFF073B5C),
    ),
  ];

  /// Emergency hospital & police posts for the active corridor
  static const List<Map<String, dynamic>> emergencyFacilities = [
    {
      'title': 'Sigiriya Tourist Police Station',
      'type': 'POLICE',
      'location': 'Sigiriya Main Road, Sigiriya',
      'lat': 7.9542,
      'lng': 80.7554,
      'distance': '2.1 km • 5 min drive',
      'phone': '066-2286333',
    },
    {
      'title': 'Dambulla Base General Hospital (24/7 ER)',
      'type': 'HOSPITAL',
      'location': 'Kurunegala-Dambulla Hwy, Dambulla',
      'lat': 7.8731,
      'lng': 80.6517,
      'distance': '16.4 km • 22 min drive',
      'phone': '066-2284761',
    },
    {
      'title': 'Suwa Seriya 1990 Ambulance Dispatch Point',
      'type': 'AMBULANCE',
      'location': 'Inamaluwa Junction, Sigiriya',
      'lat': 7.9210,
      'lng': 80.6840,
      'distance': '8.2 km • 11 min dispatch',
      'phone': '1990',
    },
  ];
}
