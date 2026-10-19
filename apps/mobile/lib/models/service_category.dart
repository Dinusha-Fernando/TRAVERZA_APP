import 'package:flutter/material.dart';

class ServiceCategoryItem {
  final String id;
  final String title;
  final String subtitle;
  final String categoryTag;
  final String imageUrl;
  final IconData icon;
  final String? badgeText;
  final bool isBookable;
  final Color gradientStart;
  final Color gradientEnd;

  const ServiceCategoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.categoryTag,
    required this.imageUrl,
    required this.icon,
    this.badgeText,
    this.isBookable = true,
    required this.gradientStart,
    required this.gradientEnd,
  });
}

class JourneyRouteItem {
  final String id;
  final String title;
  final String corridor;
  final String duration;
  final String description;
  final String imageUrl;
  final String tag;
  final Color gradientStart;
  final Color gradientEnd;

  const JourneyRouteItem({
    required this.id,
    required this.title,
    required this.corridor,
    required this.duration,
    required this.description,
    required this.imageUrl,
    required this.tag,
    required this.gradientStart,
    required this.gradientEnd,
  });
}

class CategoryRepository {
  static const List<ServiceCategoryItem> categories = [
    ServiceCategoryItem(
      id: 'stays',
      title: 'Stays',
      subtitle: 'Hotels, villas, guesthouses',
      categoryTag: 'ACCOMMODATION',
      imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80',
      icon: Icons.hotel_rounded,
      badgeText: 'Verified Stays',
      isBookable: true,
      gradientStart: Color(0xFF1E3A8A),
      gradientEnd: Color(0xFF0F172A),
    ),
    ServiceCategoryItem(
      id: 'transport',
      title: 'Transport',
      subtitle: 'Transfers, drivers, taxis',
      categoryTag: 'TRANSFER',
      imageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=800&q=80',
      icon: Icons.directions_car_rounded,
      badgeText: 'SLTDA Chauffeurs',
      isBookable: true,
      gradientStart: Color(0xFF065F46),
      gradientEnd: Color(0xFF0F172A),
    ),
    ServiceCategoryItem(
      id: 'experiences',
      title: 'Tours & Experiences',
      subtitle: 'Safaris, hiking, adventures',
      categoryTag: 'ACTIVITY',
      imageUrl: 'https://images.unsplash.com/photo-1588598198321-9735fd52455b?auto=format&fit=crop&w=800&q=80',
      icon: Icons.terrain_rounded,
      badgeText: 'Top Rated',
      isBookable: true,
      gradientStart: Color(0xFF9A3412),
      gradientEnd: Color(0xFF0F172A),
    ),
    ServiceCategoryItem(
      id: 'guides',
      title: 'Local Guides',
      subtitle: 'Heritage & private experts',
      categoryTag: 'GUIDE',
      imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=800&q=80',
      icon: Icons.person_pin_circle_rounded,
      badgeText: 'Licensed',
      isBookable: true,
      gradientStart: Color(0xFF701A75),
      gradientEnd: Color(0xFF0F172A),
    ),
    ServiceCategoryItem(
      id: 'dining',
      title: 'Food & Dining',
      subtitle: 'Ceylon cuisine & tea trails',
      categoryTag: 'DINING',
      imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
      icon: Icons.restaurant_rounded,
      badgeText: 'Authentic',
      isBookable: false,
      gradientStart: Color(0xFF831843),
      gradientEnd: Color(0xFF0F172A),
    ),
    ServiceCategoryItem(
      id: 'places',
      title: 'Places & Tickets',
      subtitle: 'Attractions & hidden gems',
      categoryTag: 'ATTRACTION',
      imageUrl: 'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?auto=format&fit=crop&w=800&q=80',
      icon: Icons.confirmation_number_rounded,
      badgeText: 'Instant Entry',
      isBookable: true,
      gradientStart: Color(0xFF155E75),
      gradientEnd: Color(0xFF0F172A),
    ),
    ServiceCategoryItem(
      id: 'rentals',
      title: 'Vehicle Rentals',
      subtitle: 'Cars, scooters & tuk-tuks',
      categoryTag: 'RENTAL',
      imageUrl: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?auto=format&fit=crop&w=800&q=80',
      icon: Icons.electric_moped_rounded,
      badgeText: 'Self-Drive',
      isBookable: true,
      gradientStart: Color(0xFF1E293B),
      gradientEnd: Color(0xFF0F172A),
    ),
    ServiceCategoryItem(
      id: 'essentials',
      title: 'Travel Essentials',
      subtitle: 'ETA visa, maps & emergency',
      categoryTag: 'ESSENTIALS',
      imageUrl: 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?auto=format&fit=crop&w=800&q=80',
      icon: Icons.shield_rounded,
      badgeText: 'Official Tools',
      isBookable: false,
      gradientStart: Color(0xFF334155),
      gradientEnd: Color(0xFF0F172A),
    ),
  ];

  static const List<JourneyRouteItem> curatedRoutes = [
    JourneyRouteItem(
      id: 'cultural-triangle',
      title: 'The Cultural Triangle',
      corridor: 'Sigiriya · Dambulla · Polonnaruwa',
      duration: '3–4 Days',
      description: 'Explore UNESCO ancient royal citadels, rock water gardens, and cave frescoes with private chauffeur.',
      imageUrl: 'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?auto=format&fit=crop&w=800&q=80',
      tag: 'CULTURAL HERITAGE',
      gradientStart: Color(0xFF0C2A4A),
      gradientEnd: Color(0xFF061424),
    ),
    JourneyRouteItem(
      id: 'tea-country',
      title: 'Through the Tea Country',
      corridor: 'Kandy · Nuwara Eliya · Ella',
      duration: '4–5 Days',
      description: 'Misty highland plantations, scenic colonial railways, cascading waterfalls, and estate bungalow stays.',
      imageUrl: 'https://images.unsplash.com/photo-1588598198321-9735fd52455b?auto=format&fit=crop&w=800&q=80',
      tag: 'HIGHLAND SCENIC',
      gradientStart: Color(0xFF0E382B),
      gradientEnd: Color(0xFF051912),
    ),
    JourneyRouteItem(
      id: 'southern-coast',
      title: 'Discover the Southern Coast',
      corridor: 'Galle Fort · Mirissa · Yala',
      duration: '4 Days',
      description: 'Dutch colonial fortifications, golden Indian Ocean surfing beaches, and leopard safaris in Yala.',
      imageUrl: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?auto=format&fit=crop&w=800&q=80',
      tag: 'COASTAL & WILDLIFE',
      gradientStart: Color(0xFF281C3D),
      gradientEnd: Color(0xFF100B1A),
    ),
  ];
}
