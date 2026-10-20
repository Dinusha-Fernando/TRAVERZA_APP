import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'features/plan/plan_tab_screen.dart';
import 'features/bookings/presentation/bookings_tab_screen.dart';
import 'features/saved/presentation/saved_tab_screen.dart';
import 'features/profile/presentation/profile_tab_screen.dart';

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
      const ProfileTabScreen(),
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
}

