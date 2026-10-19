import 'package:flutter/material.dart';
import 'models/route_waypoint.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'utils/maps_launcher.dart';
import 'widgets/sri_lanka_map_canvas.dart';

void main() {
  runApp(const TraverzaApp());
}

class TraverzaApp extends StatelessWidget {
  final bool showSplash;

  const TraverzaApp({
    super.key,
    this.showSplash = true,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRAVERZA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: showSplash ? const SplashScreen() : const MainTripScreen(),
    );
  }
}

class MainTripScreen extends StatefulWidget {
  const MainTripScreen({super.key});

  @override
  State<MainTripScreen> createState() => _MainTripScreenState();
}

class _MainTripScreenState extends State<MainTripScreen> {
  int _currentIndex = 0;

  // State for interactive confirmation & filter
  bool _hotelConfirmed = false;
  String? _selectedCategory;
  String? _searchQuery;

  void _navigateToPlan() {
    setState(() => _currentIndex = 1);
  }

  void _navigateToBookings({String? category, String? searchQuery}) {
    setState(() {
      _selectedCategory = category;
      _searchQuery = searchQuery;
      _currentIndex = 2;
    });
  }

  void _navigateToSafety() {
    setState(() => _currentIndex = 4);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        hasActiveTrip: true,
        isHotelConfirmed: _hotelConfirmed,
        onNavigateToPlan: _navigateToPlan,
        onCategorySelected: (cat) => _navigateToBookings(category: cat.categoryTag),
        onNavigateToSafety: _navigateToSafety,
        onNavigateToCatalogue: () => _navigateToBookings(),
        onSearchSubmitted: (query) => _navigateToBookings(searchQuery: query),
      ),
      _buildTimelineView(),
      _buildFitToTripCatalogue(),
      _buildReadinessView(),
      _buildProfileAndEmergencyVault(),
    ];

    return Scaffold(
      appBar: _buildAppBar(),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: TraverzaColors.surface,
        selectedItemColor: TraverzaColors.secondary,
        unselectedItemColor: TraverzaColors.textMuted,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alt_route_outlined),
            activeIcon: Icon(Icons.alt_route),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline_rounded),
            activeIcon: Icon(Icons.bookmark_rounded),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_outlined),
            activeIcon: Icon(Icons.shield),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/traverza_logo.jpg',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [TraverzaColors.oceanBlue, TraverzaColors.lagoonTeal],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'T',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TRAVERZA',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                  fontSize: 15,
                  color: TraverzaColors.primary,
                ),
              ),
              Row(
                children: const [
                  Icon(Icons.location_on, size: 10, color: TraverzaColors.secondary),
                  SizedBox(width: 2),
                  Text(
                    'SRI LANKA · CULTURAL TRIANGLE',
                    style: TextStyle(
                      fontSize: 8.5,
                      color: TraverzaColors.secondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_none_rounded, color: TraverzaColors.primary),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: TraverzaColors.amberWarning,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, color: TraverzaColors.primary),
          onPressed: () => setState(() => _currentIndex = 4),
        ),
      ],
    );
  }

  // --- TAB 1: Plan / Trip Canvas Timeline ---
  Widget _buildTimelineView() {
    final statusText = _hotelConfirmed
        ? 'Fully Confirmed (3/3)'
        : 'Partially Confirmed (2/3)';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TraverzaColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: TraverzaColors.border),
              boxShadow: [
                BoxShadow(
                  color: TraverzaColors.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trip Timeline',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: TraverzaColors.text,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _hotelConfirmed
                            ? const Color(0x2610B981)
                            : const Color(0x26F59E0B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _hotelConfirmed
                              ? TraverzaColors.emeraldSuccess
                              : TraverzaColors.amberWarning,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: _hotelConfirmed
                              ? const Color(0xFF34D399)
                              : const Color(0xFFFBBF24),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'ID: TRIP-LK-2026-9041',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: TraverzaColors.secondary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Colombo - Sigiriya - Kandy - Nuwara Eliya (3 Days)',
                  style: TextStyle(color: TraverzaColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 14),
                Row(
                  children: const [
                    Icon(Icons.people_alt_outlined, size: 16, color: TraverzaColors.secondary),
                    SizedBox(width: 6),
                    Text('2 Travellers', style: TextStyle(color: TraverzaColors.textMuted, fontSize: 12)),
                    SizedBox(width: 16),
                    Icon(Icons.payments_outlined, size: 16, color: TraverzaColors.secondary),
                    SizedBox(width: 6),
                    Text('LKR 68,500 Total', style: TextStyle(color: TraverzaColors.textMuted, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // Creative Interactive Route Map Canvas with Google Maps Integration
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SriLankaMapCanvas(),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Day 1: Cultural Gateway',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: TraverzaColors.text,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _hotelConfirmed = !_hotelConfirmed;
                    });
                  },
                  child: Text(
                    _hotelConfirmed ? 'Simulate Unconfirmed' : 'Simulate Provider Accept',
                    style: const TextStyle(color: TraverzaColors.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Stop 1: Flight Arrival
          _buildStopCard(
            time: '09:00 - 10:00',
            title: 'Bandaranaike Intl Airport (CMB) Arrival',
            subtitle: 'Flight UL-504 • Customs & Immigration',
            category: 'FLIGHT',
            status: 'NONE',
            icon: Icons.flight_land,
            iconColor: Colors.blueAccent,
            price: null,
            latitude: 7.1808,
            longitude: 79.8841,
          ),

          // Transit buffer connector
          _buildTransitConnector(
            duration: '30m customs buffer',
            note: 'Highland transit calculator verified',
          ),

          // Stop 2: Chauffeur Transfer
          _buildStopCard(
            time: '10:30 - 14:00',
            title: 'Chauffeur Transfer to Sigiriya Cultural Triangle',
            subtitle: 'Ceylon Chauffeurs Guild • Fleet #LK-402 (Toyota Prado)',
            category: 'TRANSFER',
            status: 'CONFIRMED',
            icon: Icons.directions_car,
            iconColor: TraverzaColors.emeraldSuccess,
            price: 'LKR 18,500',
            latitude: 7.4863,
            longitude: 80.3623,
          ),

          // Transit buffer connector
          _buildTransitConnector(
            duration: '45m check-in buffer',
            note: 'Rest period before ascent',
          ),

          // Stop 3: Sigiriya Rock Fortress Ascent
          _buildStopCard(
            time: '15:00 - 17:30',
            title: 'Sigiriya Rock Fortress Guided Ascent',
            subtitle: 'Cultural Heritage Guide Guild • SLTDA Lic #044',
            category: 'ACTIVITY',
            status: 'CONFIRMED',
            icon: Icons.landscape,
            iconColor: Colors.amberAccent,
            price: 'LKR 12,000',
            latitude: 7.9570,
            longitude: 80.7603,
          ),

          // Stop 4: Eco Villa
          _buildStopCard(
            time: '18:30 Check-in',
            title: 'Sigiriya Water Garden Eco Villa',
            subtitle: 'Deluxe Chalet with Private Plunge Pool',
            category: 'STAY',
            status: _hotelConfirmed ? 'CONFIRMED' : 'REQUEST_SUBMITTED',
            icon: Icons.hotel,
            iconColor: _hotelConfirmed ? TraverzaColors.emeraldSuccess : Colors.orangeAccent,
            price: 'LKR 38,000',
            latitude: 7.9525,
            longitude: 80.7480,
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStopCard({
    required String time,
    required String title,
    required String subtitle,
    required String category,
    required String status,
    required IconData icon,
    required Color iconColor,
    String? price,
    double? latitude,
    double? longitude,
  }) {
    Color badgeColor = Colors.grey;
    String badgeText = status;
    if (status == 'CONFIRMED') {
      badgeColor = TraverzaColors.emeraldSuccess;
      badgeText = 'Confirmed';
    } else if (status == 'REQUEST_SUBMITTED') {
      badgeColor = TraverzaColors.amberWarning;
      badgeText = 'Request Pending';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: iconColor.withOpacity(0.15),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          color: TraverzaColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: const TextStyle(
                          color: TraverzaColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (status != 'NONE')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: badgeColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(color: TraverzaColors.textMuted, fontSize: 12),
            ),
            if (price != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fixed Price Basis (Taxes Included)',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  Text(
                    price,
                    style: const TextStyle(
                      color: TraverzaColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            if (latitude != null && longitude != null) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      TraverzaMapsLauncher.openDirections(
                        destinationLat: latitude,
                        destinationLng: longitude,
                        destinationName: title,
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: TraverzaColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: TraverzaColors.secondary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.directions_rounded, size: 14, color: TraverzaColors.secondary),
                          SizedBox(width: 4),
                          Text(
                            'Google Maps Navigation',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: TraverzaColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransitConnector({required String duration, required String note}) {
    return Padding(
      padding: const EdgeInsets.only(left: 34, top: 4, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 28,
            color: TraverzaColors.secondary.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 16),
          Icon(Icons.directions_car_outlined, size: 14, color: TraverzaColors.textMuted),
          const SizedBox(width: 6),
          Text(
            '$duration • $note',
            style: TextStyle(
              fontSize: 11,
              color: TraverzaColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: Bookings / Fit-to-Trip Catalogue ---
  Widget _buildFitToTripCatalogue() {
    final allItems = [
      {
        'category': 'TRANSFER',
        'title': 'Airport to Sigiriya Luxury Transfer',
        'provider': 'Ceylon Chauffeurs Guild (Pvt) Ltd',
        'license': 'SLTDA/CG/2026/102',
        'price': 'LKR 18,500',
        'policy': 'Free cancellation up to 24h before pickup',
        'rating': '4.98 (124 reviews)',
      },
      {
        'category': 'STAY',
        'title': 'Sigiriya Water Garden Eco Villa',
        'provider': 'Boutique Heritage Stays (Pvt) Ltd',
        'license': 'SLTDA/SQ/2026/089',
        'price': 'LKR 38,000 / night',
        'policy': 'Standard 48h cancellation',
        'rating': '4.95 (88 reviews)',
      },
      {
        'category': 'GUIDE',
        'title': 'Sacred City of Kandy Walking Tour',
        'provider': 'Cultural Heritage Guide Guild',
        'license': 'SLTDA/GD/2026/044',
        'price': 'LKR 9,500',
        'policy': 'Free cancellation up to 24h',
        'rating': '4.92 (54 reviews)',
      },
      {
        'category': 'ACTIVITY',
        'title': 'Pedro Tea Estate Heritage Factory Walk',
        'provider': 'Highland Tea Excursions (Pvt) Ltd',
        'license': 'SLTDA/AC/2026/015',
        'price': 'LKR 8,000',
        'policy': 'Standard 24h policy',
        'rating': '4.89 (42 reviews)',
      },
    ];

    final filteredItems = allItems.where((item) {
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        if (item['category'] != _selectedCategory &&
            !(_selectedCategory == 'ACCOMMODATION' && item['category'] == 'STAY')) {
          return false;
        }
      }
      if (_searchQuery != null && _searchQuery!.trim().isNotEmpty) {
        final q = _searchQuery!.toLowerCase();
        final matches = item['title']!.toLowerCase().contains(q) ||
            item['provider']!.toLowerCase().contains(q) ||
            item['category']!.toLowerCase().contains(q) ||
            item['license']!.toLowerCase().contains(q);
        if (!matches) return false;
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Fit-to-Trip Verified Services',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                ),
                SizedBox(height: 4),
                Text(
                  'Services matched against corridor route, dates, and party size.',
                  style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
                ),
              ],
            ),
          ],
        ),
        if (_selectedCategory != null || _searchQuery != null) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_selectedCategory != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: TraverzaColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TraverzaColors.secondary),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Filtered: $_selectedCategory',
                        style: const TextStyle(fontSize: 11, color: TraverzaColors.primary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => setState(() => _selectedCategory = null),
                        child: const Icon(Icons.close, size: 14, color: TraverzaColors.primary),
                      ),
                    ],
                  ),
                ),
              if (_searchQuery != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: TraverzaColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TraverzaColors.accent),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Search: "$_searchQuery"',
                        style: const TextStyle(fontSize: 11, color: TraverzaColors.primary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => setState(() => _searchQuery = null),
                        child: const Icon(Icons.close, size: 14, color: TraverzaColors.primary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 16),

        if (filteredItems.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.search_off_rounded, size: 48, color: TraverzaColors.textMuted),
                  const SizedBox(height: 12),
                  const Text(
                    'No services match your filters',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: TraverzaColors.text),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Try resetting your search query or category filter.',
                    style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _selectedCategory = null;
                      _searchQuery = null;
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TraverzaColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Reset All Filters', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            ),
          )
        else
          ...filteredItems.map(
            (item) => _buildCatalogueItem(
              category: item['category']!,
              title: item['title']!,
              provider: item['provider']!,
              license: item['license']!,
              price: item['price']!,
              policy: item['policy']!,
              rating: item['rating']!,
            ),
          ),
      ],
    );
  }

  Widget _buildCatalogueItem({
    required String category,
    required String title,
    required String provider,
    required String license,
    required String price,
    required String policy,
    required String rating,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: TraverzaColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: TraverzaColors.secondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  rating,
                  style: const TextStyle(color: TraverzaColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: TraverzaColors.text),
            ),
            const SizedBox(height: 4),
            Text(
              '$provider • $license',
              style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  policy,
                  style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: TraverzaColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 3: Saved / Trip Readiness Audit ---
  Widget _buildReadinessView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Trip Readiness Check',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TraverzaColors.text),
        ),
        const SizedBox(height: 6),
        const Text(
          'Authoritative audit of booking statuses, highland transit feasibility, and compliance.',
          style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
        ),
        const SizedBox(height: 16),

        _buildCheckItem(
          title: 'Transit Buffer Feasibility',
          subtitle: 'All travel gaps exceed Sri Lanka terrain transit calculator requirements.',
          isOk: true,
        ),
        _buildCheckItem(
          title: 'SLTDA Provider Verification',
          subtitle: 'All 3 booked providers hold active, audited SLTDA licenses.',
          isOk: true,
        ),
        _buildCheckItem(
          title: 'Booking Confirmation Coverage',
          subtitle: _hotelConfirmed
              ? '3 of 3 services fully confirmed.'
              : '2 of 3 confirmed. Sigiriya Eco Villa is in REQUEST_SUBMITTED status.',
          isOk: _hotelConfirmed,
        ),
        _buildCheckItem(
          title: 'Opening Hours & Schedule Invariants',
          subtitle: 'Zero overlapping activities detected by TripGraph.',
          isOk: true,
        ),
      ],
    );
  }

  Widget _buildCheckItem({required String title, required String subtitle, required bool isOk}) {
    return Card(
      child: ListTile(
        leading: Icon(
          isOk ? Icons.check_circle : Icons.warning_amber_rounded,
          color: isOk ? TraverzaColors.emeraldSuccess : TraverzaColors.amberWarning,
          size: 28,
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TraverzaColors.text),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
        ),
      ),
    );
  }

  // --- TAB 4: Profile & Offline Emergency Vault ---
  Widget _buildProfileAndEmergencyVault() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Traveler Profile Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TraverzaColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TraverzaColors.border),
            boxShadow: [
              BoxShadow(
                color: TraverzaColors.primary.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: TraverzaColors.primary,
                child: Text('D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Dinusha Wijesinghe',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: TraverzaColors.text),
                    ),
                    Text(
                      'Independent International Traveller • Pilot Member',
                      style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Offline SOS & Emergency Vault',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TraverzaColors.text),
        ),
        const SizedBox(height: 6),
        const Text(
          'Available 100% offline during low-connectivity travel across mountain tea routes.',
          style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
        ),
        const SizedBox(height: 16),

        // Creative Emergency Map Locator Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TraverzaColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TraverzaColors.border),
            boxShadow: [
              BoxShadow(
                color: TraverzaColors.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.near_me_rounded, color: TraverzaColors.roseEmergency, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Nearest Emergency Facilities',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: TraverzaColors.text,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: TraverzaColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Sigiriya Sector',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: TraverzaColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Instant Google Maps routing with pre-calculated off-grid coordinates.',
                style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
              ),
              const SizedBox(height: 14),

              ...TraverzaWaypoints.emergencyFacilities.map((facility) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TraverzaColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TraverzaColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: facility['type'] == 'POLICE'
                              ? Colors.blue.withValues(alpha: 0.12)
                              : TraverzaColors.roseEmergency.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          facility['type'] == 'POLICE'
                              ? Icons.local_police_rounded
                              : Icons.local_hospital_rounded,
                          color: facility['type'] == 'POLICE'
                              ? Colors.blue
                              : TraverzaColors.roseEmergency,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              facility['title'] as String,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: TraverzaColors.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              facility['distance'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                color: TraverzaColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          TraverzaMapsLauncher.openEmergencyRoute(
                            lat: facility['lat'] as double,
                            lng: facility['lng'] as double,
                            facilityName: facility['title'] as String,
                          );
                        },
                        icon: const Icon(Icons.directions_rounded, size: 13),
                        label: const Text('Map', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TraverzaColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: const Size(64, 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 18),

        const Text(
          'Emergency Helplines & Desks',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TraverzaColors.text),
        ),
        const SizedBox(height: 8),

        _buildEmergencyContact(
          title: 'Sri Lanka Tourist Police Hotline',
          number: '1912',
          description: 'Official SLTDA emergency tourist assistance desk',
          icon: Icons.local_police_outlined,
          latitude: 7.9542,
          longitude: 80.7554,
        ),
        _buildEmergencyContact(
          title: 'Suwa Seriya Emergency Ambulance',
          number: '1990',
          description: 'Free nationwide medical paramedic dispatch',
          icon: Icons.medical_services_outlined,
          latitude: 7.9210,
          longitude: 80.6840,
        ),
        _buildEmergencyContact(
          title: 'TRAVERZA 24/7 Operations Rescue Desk',
          number: '+94 11 289 0123',
          description: 'Emergency vehicle dispatch and supplier re-routing',
          icon: Icons.headset_mic_outlined,
        ),
        _buildEmergencyContact(
          title: 'Assigned Chauffeur (Lalith J.)',
          number: '+94 71 234 8899',
          description: 'Fleet #LK-402 • Direct vehicle mobile',
          icon: Icons.phone_android_outlined,
        ),
      ],
    );
  }

  Widget _buildEmergencyContact({
    required String title,
    required String number,
    required String description,
    required IconData icon,
    double? latitude,
    double? longitude,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: TraverzaColors.roseEmergency.withOpacity(0.15),
          child: Icon(icon, color: TraverzaColors.roseEmergency),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TraverzaColors.text),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(fontSize: 11, color: Colors.white60),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (latitude != null && longitude != null) ...[
              IconButton(
                icon: const Icon(Icons.directions_outlined, color: TraverzaColors.secondary, size: 20),
                tooltip: 'Open in Google Maps',
                onPressed: () {
                  TraverzaMapsLauncher.openEmergencyRoute(
                    lat: latitude,
                    lng: longitude,
                    facilityName: title,
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: TraverzaColors.roseEmergency.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                number,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: TraverzaColors.roseEmergency,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
