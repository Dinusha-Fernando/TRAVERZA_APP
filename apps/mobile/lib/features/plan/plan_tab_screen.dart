import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/sri_lanka_map_canvas.dart';
import 'custom_trip_builder_screen.dart';
import 'data/package_model.dart';
import 'package_details_screen.dart';
import 'package_explorer_screen.dart';
import 'trip_canvas_screen.dart';
import 'widgets/active_trip_summary_card.dart';
import 'widgets/package_offer_card.dart';
import 'widgets/planning_path_card.dart';
import 'widgets/transit_buffer_connector.dart';
import 'widgets/trip_stop_card.dart';

enum PlanSubView {
  hub,
  canvas,
  packages,
  customBuilder,
}

class PlanTabScreen extends StatefulWidget {
  final bool isHotelConfirmed;
  final VoidCallback onToggleSimulation;
  final PlanSubView initialSubView;

  const PlanTabScreen({
    super.key,
    required this.isHotelConfirmed,
    required this.onToggleSimulation,
    this.initialSubView = PlanSubView.hub,
  });

  @override
  State<PlanTabScreen> createState() => _PlanTabScreenState();
}

class _PlanTabScreenState extends State<PlanTabScreen> {
  late PlanSubView _currentSubView;
  final List<TraverzaPackage> _curatedPackages = TraverzaPackage.getCuratedPackages();

  @override
  void initState() {
    super.initState();
    _currentSubView = widget.initialSubView;
  }

  void _navigateToSubView(PlanSubView view) {
    setState(() => _currentSubView = view);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentSubView == PlanSubView.canvas) {
      return TripCanvasScreen(
        isHotelConfirmed: widget.isHotelConfirmed,
        onToggleSimulation: widget.onToggleSimulation,
        onBackToHub: () => _navigateToSubView(PlanSubView.hub),
      );
    } else if (_currentSubView == PlanSubView.packages) {
      return PackageExplorerScreen(
        onBackToHub: () => _navigateToSubView(PlanSubView.hub),
        onCustomizePackage: (pkg) {
          _navigateToSubView(PlanSubView.customBuilder);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Copied "${pkg.title}" into your custom draft!'),
              backgroundColor: TraverzaColors.secondary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    } else if (_currentSubView == PlanSubView.customBuilder) {
      return CustomTripBuilderScreen(
        onBackToHub: () => _navigateToSubView(PlanSubView.hub),
        onTripSaved: () {
          _navigateToSubView(PlanSubView.canvas);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Custom trip draft saved and opened in Trip Canvas!'),
              backgroundColor: TraverzaColors.emeraldSuccess,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    }

    // Default: Planning Hub Landing Page
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-navigation mode bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: TraverzaColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: TraverzaColors.border),
            ),
            child: Row(
              children: [
                _buildModeTab('Plan Hub', PlanSubView.hub, Icons.hub_outlined),
                _buildModeTab('Trip Canvas', PlanSubView.canvas, Icons.alt_route),
                _buildModeTab('Packages', PlanSubView.packages, Icons.card_travel_outlined),
                _buildModeTab('Custom Builder', PlanSubView.customBuilder, Icons.edit_note_outlined),
              ],
            ),
          ),

          // Planning Hub Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Plan your Sri Lanka journey',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: TraverzaColors.text,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Connected corridor: Colombo (CMB) → Sigiriya → Kandy → Nuwara Eliya',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: TraverzaColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 1. Active Trip Card (Features "Trip Timeline", "ID: TRIP-LK-2026-9041", status, and "Simulate Provider Accept")
          ActiveTripSummaryCard(
            isHotelConfirmed: widget.isHotelConfirmed,
            onToggleSimulation: widget.onToggleSimulation,
            onOpenCanvas: () => _navigateToSubView(PlanSubView.canvas),
            onOpenReadiness: () => _navigateToSubView(PlanSubView.canvas),
          ),

          // 2. Interactive Route Map Canvas with Google Maps Integration
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SriLankaMapCanvas(),
          ),
          const SizedBox(height: 16),

          // 3. Three Primary Planning Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Three Ways to Plan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TraverzaColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose a verified package, customize one, or build from scratch',
                  style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
                ),
                const SizedBox(height: 12),
                PlanningPathCard(
                  title: 'Continue My Trip',
                  subtitle: 'Manage live route geometry, day timeline, bookings & buffers',
                  badgeText: 'Active Canvas',
                  icon: Icons.alt_route,
                  accentColor: TraverzaColors.secondary,
                  onTap: () => _navigateToSubView(PlanSubView.canvas),
                ),
                const SizedBox(height: 10),
                PlanningPathCard(
                  title: 'Explore Provider Packages',
                  subtitle: 'Discover verified journeys from approved agencies & route templates',
                  badgeText: 'Marketplace',
                  icon: Icons.card_travel_outlined,
                  accentColor: TraverzaColors.primary,
                  onTap: () => _navigateToSubView(PlanSubView.packages),
                ),
                const SizedBox(height: 10),
                PlanningPathCard(
                  title: 'Build a Custom Trip',
                  subtitle: 'Select destinations and services in any order with TripGraph schedule audit',
                  badgeText: '5-Stage Builder',
                  icon: Icons.auto_awesome_outlined,
                  accentColor: TraverzaColors.rating,
                  onTap: () => _navigateToSubView(PlanSubView.customBuilder),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Curated & Recommended Packages Carousel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Recommended Packages & Routes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TraverzaColors.text,
                      ),
                    ),
                    Text(
                      'Operator packages & itinerary templates for your dates',
                      style: TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _navigateToSubView(PlanSubView.packages),
                  child: const Text(
                    'View all',
                    style: TextStyle(color: TraverzaColors.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 290,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _curatedPackages.length,
              itemBuilder: (context, index) {
                final pkg = _curatedPackages[index];
                return PackageOfferCard(
                  package: pkg,
                  onTap: () {
                    PackageDetailsScreen.show(
                      context,
                      package: pkg,
                      onCustomize: () {
                        _navigateToSubView(PlanSubView.customBuilder);
                      },
                    );
                  },
                  onCustomize: () {
                    _navigateToSubView(PlanSubView.customBuilder);
                  },
                  onBook: pkg.isOperatorPackage
                      ? () {
                          PackageDetailsScreen.show(
                            context,
                            package: pkg,
                            onCustomize: () {
                              _navigateToSubView(PlanSubView.customBuilder);
                            },
                          );
                        }
                      : null,
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // 5. Build Around a Destination
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Build Around a Destination',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TraverzaColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Add must-see stops along the Sri Lanka Cultural corridor',
                  style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
                ),
                const SizedBox(height: 12),
                _buildDestinationRow(context),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 6. Day 1 Timeline Preview
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
                  onPressed: widget.onToggleSimulation,
                  child: Text(
                    widget.isHotelConfirmed ? 'Simulate Unconfirmed' : 'Simulate Provider Accept',
                    style: const TextStyle(color: TraverzaColors.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Stop 1: Flight Arrival
          const TripStopCard(
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
          const TransitBufferConnector(
            duration: '30m customs buffer',
            note: 'Highland transit calculator verified',
          ),

          // Stop 2: Chauffeur Transfer
          const TripStopCard(
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
          const TransitBufferConnector(
            duration: '45m check-in buffer',
            note: 'Rest period before ascent',
          ),

          // Stop 3: Sigiriya Rock Fortress
          const TripStopCard(
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
          TripStopCard(
            time: '18:30 Check-in',
            title: 'Sigiriya Water Garden Eco Villa',
            subtitle: 'Deluxe Chalet with Private Plunge Pool',
            category: 'STAY',
            status: widget.isHotelConfirmed ? 'CONFIRMED' : 'REQUEST_SUBMITTED',
            icon: Icons.hotel,
            iconColor: widget.isHotelConfirmed ? TraverzaColors.emeraldSuccess : Colors.orangeAccent,
            price: 'LKR 38,000',
            latitude: 7.9525,
            longitude: 80.7480,
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildModeTab(String title, PlanSubView view, IconData icon) {
    final isSelected = _currentSubView == view;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentSubView = view),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? TraverzaColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : TraverzaColors.textMuted,
              ),
              const SizedBox(height: 3),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : TraverzaColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationRow(BuildContext context) {
    final destinations = [
      {'name': 'Sigiriya', 'desc': 'Lion Rock & Caves', 'icon': Icons.castle_outlined},
      {'name': 'Kandy', 'desc': 'Sacred Tooth Temple', 'icon': Icons.account_balance_outlined},
      {'name': 'Nuwara Eliya', 'desc': 'Misty Tea Estates', 'icon': Icons.local_florist_outlined},
      {'name': 'Ella', 'desc': 'Nine Arch Bridge', 'icon': Icons.landscape_outlined},
    ];

    return SizedBox(
      height: 112,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: destinations.length,
        itemBuilder: (context, index) {
          final d = destinations[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 10, bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: TraverzaColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: TraverzaColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(d['icon'] as IconData, size: 18, color: TraverzaColors.secondary),
                    const Icon(Icons.add_circle_outline, size: 16, color: TraverzaColors.secondary),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: TraverzaColors.text),
                    ),
                    Text(
                      d['desc'] as String,
                      style: const TextStyle(fontSize: 10, color: TraverzaColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
