import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'features/plan/plan_tab_screen.dart';
import 'features/bookings/presentation/bookings_tab_screen.dart';
import 'features/saved/presentation/saved_tab_screen.dart';
import 'features/profile/presentation/profile_tab_screen.dart';
import 'features/notifications/data/notification_model.dart';
import 'features/notifications/services/notification_service.dart';
import 'features/notifications/presentation/notification_center_sheet.dart';
import 'features/notifications/presentation/widgets/in_app_notification_banner.dart';
import 'features/command_center/presentation/journey_command_center_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/presentation/auth_sheet.dart';
import 'features/auth/presentation/account_quick_sheet.dart';
import 'features/messenger/presentation/widgets/creative_messenger_button.dart';

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

  void _handleNotificationNavigation(String route) {
    if (route == 'command_center') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const JourneyCommandCenterScreen(initialTab: CommandCenterTab.autopilot),
        ),
      );
      return;
    }
    setState(() {
      switch (route) {
        case 'plan':
          _currentIndex = 1;
          break;
        case 'bookings':
          _currentIndex = 2;
          break;
        case 'saved':
          _currentIndex = 3;
          break;
        case 'safety':
          _currentIndex = 4;
          break;
        default:
          _currentIndex = 0;
      }
    });
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
          if (_hotelConfirmed) {
            TraverzaNotificationService.instance.addNotification(
              TraverzaNotification(
                id: 'NOTIF-CONFIRM-${DateTime.now().millisecondsSinceEpoch}',
                title: 'Sigiriya Water Garden: Fully Confirmed',
                body: 'Eco Villa reservation confirmed by provider. Voucher #VOUCH-LK-9041 is ready.',
                category: NotificationCategory.booking,
                timestamp: DateTime.now(),
                isRead: false,
                actionRoute: 'bookings',
                actionLabel: 'View Voucher',
                priority: 'high',
              ),
            );
          }
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
      body: Stack(
        children: [
          screens[_currentIndex],
          InAppNotificationBanner(onNavigate: _handleNotificationNavigation),
        ],
      ),
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
      titleSpacing: 12,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/traverza_logo.jpg',
              width: 34,
              height: 34,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [TraverzaColors.oceanBlue, TraverzaColors.lagoonTeal],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'T',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'TRAVERZA',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontSize: 14.5,
                    color: TraverzaColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: const [
                    Icon(Icons.location_on, size: 10, color: TraverzaColors.secondary),
                    SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        'SRI LANKA · CULTURAL TRIANGLE',
                        style: TextStyle(
                          fontSize: 8.5,
                          color: TraverzaColors.secondary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
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
      actions: [
        const CreativeMessengerButton(compact: true),
        ListenableBuilder(
          listenable: TraverzaNotificationService.instance,
          builder: (context, _) {
            final unread = TraverzaNotificationService.instance.unreadCount;
            return IconButton(
              tooltip: 'Notifications ($unread unread)',
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none_rounded, color: TraverzaColors.primary),
                  if (unread > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        decoration: BoxDecoration(
                          color: TraverzaColors.roseEmergency,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          unread > 9 ? '9+' : '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                NotificationCenterSheet.show(
                  context,
                  onNavigate: _handleNotificationNavigation,
                );
              },
            );
          },
        ),
        ListenableBuilder(
          listenable: TraverzaAuthService.instance,
          builder: (context, _) {
            final auth = TraverzaAuthService.instance;
            final isAuth = auth.isAuthenticated;
            final profile = auth.currentProfile;
            final initial = profile.fullName.isNotEmpty ? profile.fullName.substring(0, 1).toUpperCase() : 'U';

            if (isAuth) {
              return IconButton(
                tooltip: '${profile.fullName} (Account Menu)',
                icon: CircleAvatar(
                  radius: 13,
                  backgroundColor: TraverzaColors.primary,
                  backgroundImage: (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  onBackgroundImageError: (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                      ? (e, s) {}
                      : null,
                  child: (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                      ? null
                      : Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                onPressed: () {
                  AccountQuickSheet.show(
                    context,
                    onNavigateToProfile: () => setState(() => _currentIndex = 4),
                  );
                },
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(right: 6, top: 10, bottom: 10),
                child: ElevatedButton.icon(
                  onPressed: () => AuthSheet.show(context),
                  icon: const Icon(Icons.login_rounded, size: 13),
                  label: const Text('Sign In', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TraverzaColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

