import 'package:flutter/material.dart';
import '../models/service_category.dart';
import '../theme/app_theme.dart';
import '../widgets/photographic_card.dart';

class HomeScreen extends StatelessWidget {
  final bool hasActiveTrip;
  final bool isHotelConfirmed;
  final VoidCallback onNavigateToPlan;
  final Function(ServiceCategoryItem) onCategorySelected;
  final VoidCallback onNavigateToSafety;
  final VoidCallback onNavigateToCatalogue;

  const HomeScreen({
    super.key,
    required this.hasActiveTrip,
    required this.isHotelConfirmed,
    required this.onNavigateToPlan,
    required this.onCategorySelected,
    required this.onNavigateToSafety,
    required this.onNavigateToCatalogue,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Welcome Headline
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: TraverzaColors.lagoonTeal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'YOUR JOURNEY, CONNECTED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: TraverzaColors.lagoonTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your Sri Lanka story starts here.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Discover places, find experiences and organise every part of your journey.',
                  style: TextStyle(
                    fontSize: 13,
                    color: TraverzaColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2. Search & Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: TraverzaColors.surfaceNavy,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.09)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: TraverzaColors.lagoonTeal, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Where would you like to go?',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: TraverzaColors.warmSand,
                          ),
                        ),
                        Text(
                          'Search destinations, stays and experiences',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: TraverzaColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Icon(Icons.tune_rounded, size: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 3. Cinematic Hero Photograph (Style A)
          StyleAHeroCard(
            onPlanPressed: onNavigateToPlan,
          ),

          // 4. Conditional "Continue your journey" Card
          if (hasActiveTrip)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10283E), Color(0xFF0A1828)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: TraverzaColors.lagoonTeal.withOpacity(0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: TraverzaColors.oceanBlue.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.alt_route_rounded,
                                size: 16,
                                color: TraverzaColors.lagoonTeal,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'CONTINUE YOUR JOURNEY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: TraverzaColors.lagoonTeal,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isHotelConfirmed
                                ? const Color(0x2610B981)
                                : const Color(0x26F59E0B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isHotelConfirmed
                                  ? TraverzaColors.emeraldSuccess
                                  : TraverzaColors.amberWarning,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            isHotelConfirmed
                                ? 'Fully Confirmed (3/3)'
                                : 'Partially Confirmed (2/3)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isHotelConfirmed
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFFFBBF24),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'ID: TRIP-LK-2026-9041',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: TraverzaColors.lagoonTeal,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Colombo - Sigiriya - Kandy - Nuwara Eliya',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: TraverzaColors.warmSand),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isHotelConfirmed
                                ? 'Next: Day 1 · 18:30 Check-in at Sigiriya Water Garden Eco Villa'
                                : 'Awaiting confirmation: Sigiriya Water Garden Eco Villa (12h SLA)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '2 Travellers • LKR 68,500 Committed',
                          style: TextStyle(fontSize: 11, color: Colors.white54),
                        ),
                        InkWell(
                          onTap: onNavigateToPlan,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: TraverzaColors.oceanBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Trip Timeline',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 12, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 14),

          // 5. "Explore services" Header & 2-Column Photographic Bento Grid (Style B)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Explore services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'All curated providers across the island',
                      style: TextStyle(fontSize: 11, color: TraverzaColors.textSecondary),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onNavigateToCatalogue,
                  style: TextButton.styleFrom(
                    foregroundColor: TraverzaColors.lagoonTeal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'See all (8)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 11),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 2-Column Responsive Bento Grid of the 8 Service Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemCount: CategoryRepository.categories.length,
              itemBuilder: (context, index) {
                final cat = CategoryRepository.categories[index];
                return StyleBServiceTile(
                  item: cat,
                  onTap: () => onCategorySelected(cat),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // 6. Curated Sri Lanka Journeys (Style C)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Curated Sri Lanka Journeys',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  'Expertly paced multi-day corridors with verified drivers',
                  style: TextStyle(fontSize: 11, color: TraverzaColors.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Horizontal scrolling journey cards
          SizedBox(
            height: 235,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: CategoryRepository.curatedRoutes.length,
              itemBuilder: (context, index) {
                final route = CategoryRepository.curatedRoutes[index];
                return StyleCJourneyCard(
                  item: route,
                  onTap: onNavigateToPlan,
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // 7. "Manage your journey" Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage your journey',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const Text(
                  'Intelligent trip coordination & safety utilities',
                  style: TextStyle(fontSize: 11, color: TraverzaColors.textSecondary),
                ),
                const SizedBox(height: 12),
                ManageJourneyShortcut(
                  icon: Icons.alt_route_rounded,
                  title: 'Trip Canvas',
                  description: 'Build and organise every day of the trip.',
                  onTap: onNavigateToPlan,
                  iconColor: TraverzaColors.lagoonTeal,
                ),
                const SizedBox(height: 8),
                ManageJourneyShortcut(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Trip budget',
                  description: 'Estimate and track committed costs (LKR 68,500 total).',
                  onTap: onNavigateToPlan,
                  iconColor: TraverzaColors.emeraldSuccess,
                ),
                const SizedBox(height: 8),
                ManageJourneyShortcut(
                  icon: Icons.explore_outlined,
                  title: 'Routes & nearby',
                  description: 'Explore stops, highland transit buffers and services.',
                  onTap: onNavigateToPlan,
                  iconColor: TraverzaColors.warmSand,
                ),
                const SizedBox(height: 8),
                ManageJourneyShortcut(
                  icon: Icons.shield_outlined,
                  title: 'Travel safety',
                  description: 'Access 1912 Tourist Police, 1990 Ambulance & SOS Vault.',
                  onTap: onNavigateToSafety,
                  iconColor: TraverzaColors.roseEmergency,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 8. Compact Action Needed / Support Banner
          if (!isHotelConfirmed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: TraverzaColors.amberWarning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: TraverzaColors.amberWarning.withOpacity(0.35),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: TraverzaColors.amberWarning,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Action Needed: Provider Response Pending',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Sigiriya Eco Villa requested. Response guaranteed within 12h SLA. Operations Rescue Desk is active.',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
