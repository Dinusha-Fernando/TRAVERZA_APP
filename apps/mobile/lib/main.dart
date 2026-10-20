import 'package:flutter/material.dart';
import 'models/route_waypoint.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'utils/maps_launcher.dart';
import 'features/plan/plan_tab_screen.dart';
import 'features/bookings/presentation/bookings_tab_screen.dart';
import 'features/saved/presentation/saved_tab_screen.dart';

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
      PlanTabScreen(
        isHotelConfirmed: _hotelConfirmed,
        onToggleSimulation: () {
          setState(() {
            _hotelConfirmed = !_hotelConfirmed;
          });
        },
      ),
      BookingsTabScreen(
        initialCategory: _selectedCategory,
        initialSearchQuery: _searchQuery,
      ),
      SavedTabScreen(
        isHotelConfirmed: _hotelConfirmed,
        onToggleHotelConfirmation: () {
          setState(() {
            _hotelConfirmed = !_hotelConfirmed;
          });
        },
      ),
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
