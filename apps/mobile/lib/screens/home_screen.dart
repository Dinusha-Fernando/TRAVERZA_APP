import 'package:flutter/material.dart';
import '../models/service_category.dart';
import '../theme/app_theme.dart';
import '../utils/maps_launcher.dart';
import '../widgets/photographic_card.dart';
import '../features/command_center/presentation/journey_command_center_screen.dart';
import '../features/atlas/presentation/island_atlas_screen.dart';
import '../features/community/presentation/community_pulse_screen.dart';
import '../features/community/models/community_models.dart';
import '../features/community/services/community_service.dart';
import '../features/community/presentation/create_post_sheet.dart';
import '../features/community/presentation/post_detail_screen.dart';

class SearchableTravelItem {
  final String title;
  final String category;
  final String location;
  final String price;
  final String rating;
  final String imageUrl;
  final String provider;

  const SearchableTravelItem({
    required this.title,
    required this.category,
    required this.location,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.provider,
  });
}

const List<SearchableTravelItem> kSearchableInventory = [
  SearchableTravelItem(
    title: 'Sigiriya Water Garden Eco Villa',
    category: 'STAY',
    location: 'Sigiriya / Dambulla',
    price: 'LKR 38,000 / night',
    rating: '4.95 (88 reviews)',
    imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80',
    provider: 'Boutique Heritage Stays (Pvt) Ltd',
  ),
  SearchableTravelItem(
    title: 'Airport to Sigiriya Luxury Transfer',
    category: 'TRANSFER',
    location: 'Katunayake → Sigiriya',
    price: 'LKR 18,500',
    rating: '4.98 (124 reviews)',
    imageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=800&q=80',
    provider: 'Ceylon Chauffeurs Guild (Fleet #LK-402)',
  ),
  SearchableTravelItem(
    title: 'Sigiriya Rock Fortress Guided Archaeological Ascent',
    category: 'ACTIVITY',
    location: 'Sigiriya Ancient Citadel',
    price: 'LKR 12,000',
    rating: '4.96 (142 reviews)',
    imageUrl: 'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?auto=format&fit=crop&w=800&q=80',
    provider: 'Cultural Heritage Guide Guild',
  ),
  SearchableTravelItem(
    title: 'Sacred City of Kandy Walking Tour',
    category: 'GUIDE',
    location: 'Kandy Sacred City',
    price: 'LKR 9,500',
    rating: '4.92 (54 reviews)',
    imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=800&q=80',
    provider: 'Kandyan Heritage Guild',
  ),
  SearchableTravelItem(
    title: 'Pedro Tea Estate Heritage Factory Walk',
    category: 'ACTIVITY',
    location: 'Nuwara Eliya Highlands',
    price: 'LKR 8,000',
    rating: '4.89 (42 reviews)',
    imageUrl: 'https://images.unsplash.com/photo-1588598198321-9735fd52455b?auto=format&fit=crop&w=800&q=80',
    provider: 'Highland Tea Excursions (Pvt) Ltd',
  ),
  SearchableTravelItem(
    title: 'Yala National Park Leopard & Elephant Safari',
    category: 'ACTIVITY',
    location: 'Yala / Southern Province',
    price: 'LKR 24,000',
    rating: '4.97 (96 reviews)',
    imageUrl: 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?auto=format&fit=crop&w=800&q=80',
    provider: 'Yala Wild Trackers (Pvt) Ltd',
  ),
  SearchableTravelItem(
    title: 'Galle Dutch Fort Heritage & Ramparts Sunset Walk',
    category: 'GUIDE',
    location: 'Galle Maritime District',
    price: 'LKR 8,500',
    rating: '4.94 (67 reviews)',
    imageUrl: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?auto=format&fit=crop&w=800&q=80',
    provider: 'Southern Coast Heritage Guild',
  ),
];

class HomeScreen extends StatefulWidget {
  final bool hasActiveTrip;
  final bool isHotelConfirmed;
  final VoidCallback onNavigateToPlan;
  final Function(ServiceCategoryItem) onCategorySelected;
  final VoidCallback onNavigateToSafety;
  final VoidCallback onNavigateToCatalogue;
  final Function(String query)? onSearchSubmitted;

  const HomeScreen({
    super.key,
    required this.hasActiveTrip,
    required this.isHotelConfirmed,
    required this.onNavigateToPlan,
    required this.onCategorySelected,
    required this.onNavigateToSafety,
    required this.onNavigateToCatalogue,
    this.onSearchSubmitted,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _activeQuery = '';
  List<SearchableTravelItem> _searchResults = [];

  final List<String> _quickDestinations = [
    'Sigiriya',
    'Kandy',
    'Nuwara Eliya',
    'Transfer',
    'Villas',
    'Safaris',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _activeQuery = query;
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        final q = query.toLowerCase();
        _searchResults = kSearchableInventory.where((item) {
          return item.title.toLowerCase().contains(q) ||
              item.location.toLowerCase().contains(q) ||
              item.category.toLowerCase().contains(q) ||
              item.provider.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  void _submitSearch(String query) {
    if (query.trim().isNotEmpty) {
      if (widget.onSearchSubmitted != null) {
        widget.onSearchSubmitted!(query.trim());
      } else {
        widget.onNavigateToCatalogue();
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() {
      _activeQuery = '';
      _searchResults = [];
    });
  }

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: TraverzaColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Sri Lanka Travel Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TraverzaColors.text,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: TraverzaColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Corridor Regions',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: TraverzaColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip('Cultural Triangle', isSelected: true),
                  _buildFilterChip('Central Highlands', isSelected: false),
                  _buildFilterChip('Southern Coast', isSelected: false),
                  _buildFilterChip('Northern Heritage', isSelected: false),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Service Categories',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: TraverzaColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip('All Services', isSelected: true),
                  _buildFilterChip('Verified Stays', isSelected: false),
                  _buildFilterChip('Licensed Chauffeurs', isSelected: false),
                  _buildFilterChip('Heritage Guides', isSelected: false),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onNavigateToCatalogue();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TraverzaColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters & View Catalogue',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? TraverzaColors.secondary.withValues(alpha: 0.12)
            : TraverzaColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? TraverzaColors.secondary : TraverzaColors.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? TraverzaColors.secondary : TraverzaColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildMapCorridorChip({
    required String label,
    required double lat,
    required double lng,
  }) {
    return InkWell(
      onTap: () {
        TraverzaMapsLauncher.openLocation(
          latitude: lat,
          longitude: lng,
          label: label,
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.place_rounded, size: 12, color: TraverzaColors.accent),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                    color: TraverzaColors.text,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Discover places, find experiences and organise every part of your journey.',
                  style: TextStyle(
                    fontSize: 13,
                    color: TraverzaColors.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2. Interactive Search & Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: TraverzaColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _searchFocus.hasFocus
                      ? TraverzaColors.secondary
                      : TraverzaColors.border,
                  width: _searchFocus.hasFocus ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: TraverzaColors.primary.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _submitSearch(_searchController.text),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.search_rounded,
                        color: TraverzaColors.secondary,
                        size: 22,
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
                          'Where would you like to go?',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: TraverzaColors.primary,
                          ),
                        ),
                        TextField(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          textInputAction: TextInputAction.search,
                          onSubmitted: _submitSearch,
                          style: const TextStyle(
                            fontSize: 13,
                            color: TraverzaColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 4),
                            hintText: 'Search destinations, stays and experiences',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: TraverzaColors.textMuted,
                              fontWeight: FontWeight.normal,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_activeQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: TraverzaColors.textMuted),
                      onPressed: _clearSearch,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: _openFilterModal,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TraverzaColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: TraverzaColors.border),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 16,
                        color: TraverzaColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quick Destination Tags
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _quickDestinations.map((dest) {
                final isSelected = _activeQuery.toLowerCase() == dest.toLowerCase();
                return InkWell(
                  onTap: () {
                    _searchController.text = dest;
                    _submitSearch(dest);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TraverzaColors.secondary.withValues(alpha: 0.15)
                          : TraverzaColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? TraverzaColors.secondary : TraverzaColors.border,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      dest,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? TraverzaColors.secondary : TraverzaColors.textMuted,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Live In-Page Search Results (when query is active)
          if (_activeQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Found ${_searchResults.length} results for "$_activeQuery"',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: TraverzaColors.text,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearSearch,
                    style: TextButton.styleFrom(
                      foregroundColor: TraverzaColors.secondary,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Clear', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            if (_searchResults.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.search_off_rounded, size: 40, color: TraverzaColors.textMuted),
                      SizedBox(height: 8),
                      Text(
                        'No direct matches found.',
                        style: TextStyle(fontWeight: FontWeight.bold, color: TraverzaColors.text),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Try searching "Sigiriya", "Kandy", "Villa" or "Transfer".',
                        style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final item = _searchResults[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: TraverzaColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item.category == 'STAY'
                              ? Icons.hotel_rounded
                              : item.category == 'TRANSFER'
                                  ? Icons.directions_car_rounded
                                  : Icons.explore_rounded,
                          color: TraverzaColors.secondary,
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: TraverzaColors.text,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            '${item.location} • ${item.provider}',
                            style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.price,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: TraverzaColors.primary,
                            ),
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _submitSearch(item.title),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TraverzaColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: const Size(60, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],

          const SizedBox(height: 10),

          // 3. Cinematic Hero Photograph (Style A)
          StyleAHeroCard(
            onPlanPressed: widget.onNavigateToPlan,
          ),

          // 4. Conditional "Continue your journey" Card
          if (widget.hasActiveTrip)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(16),
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: TraverzaColors.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.hub_rounded,
                            size: 16,
                            color: TraverzaColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'CONTINUE YOUR JOURNEY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: TraverzaColors.secondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'ID: TRIP-LK-2026-9041',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: TraverzaColors.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: TraverzaColors.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'COMMAND CENTER',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: TraverzaColors.secondary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: widget.isHotelConfirmed
                                ? const Color(0x2610B981)
                                : const Color(0x26F59E0B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.isHotelConfirmed
                                  ? TraverzaColors.emeraldSuccess
                                  : TraverzaColors.amberWarning,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            widget.isHotelConfirmed
                                ? 'Fully Confirmed (3/3)'
                                : 'Partially Confirmed (2/3)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: widget.isHotelConfirmed
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Colombo - Sigiriya - Kandy - Nuwara Eliya',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: TraverzaColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Next Action Module
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: TraverzaColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: TraverzaColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.isHotelConfirmed ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                            size: 16,
                            color: widget.isHotelConfirmed ? TraverzaColors.emeraldSuccess : TraverzaColors.amberWarning,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.isHotelConfirmed
                                  ? 'Next: Day 1 · 18:30 Check-in at Sigiriya Eco Villa'
                                  : 'Next Action: Sigiriya Eco Villa pending provider response (12h SLA)',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: TraverzaColors.text),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Trip Health & Autopilot Monitor
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0x1A0284C7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0x330284C7)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.bolt_rounded, size: 12, color: Color(0xFF0284C7)),
                              SizedBox(width: 4),
                              Text(
                                'Autopilot: +30m Active',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0x1A10B981),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0x3310B981)),
                          ),
                          child: const Text(
                            'Health: 94%',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Budget Breakdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Committed Spend',
                                style: TextStyle(fontSize: 10, color: TraverzaColors.textMuted),
                              ),
                              Text(
                                widget.isHotelConfirmed ? 'LKR 68,500' : 'LKR 30,500 (+ LKR 38k req)',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TraverzaColors.primary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const JourneyCommandCenterScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: TraverzaColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Command Center',
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

          // Island Atlas Feature Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                key: const Key('home_island_atlas_card'),
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const IslandAtlasScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF334155)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: TraverzaColors.secondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: TraverzaColors.secondary.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.explore_rounded, size: 13, color: TraverzaColors.secondary),
                                SizedBox(width: 5),
                                Text(
                                  'ISLAND ATLAS',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: TraverzaColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '9 Provinces · 25 Districts',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF34D399),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Discover Sri Lanka District by District',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Verified cultural heritage, scenic landmarks, regional food, and your collectible District Passport.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.military_tech_rounded, size: 16, color: Color(0xFFFBBF24)),
                              SizedBox(width: 6),
                              Text(
                                'Passport Active',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFBBF24),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            key: const Key('home_explore_atlas_button'),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const IslandAtlasScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TraverzaColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Explore Atlas',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 13),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Community Pulse: Flagship Living Island Discovery Feature
          Container(
            key: const Key('home_community_pulse_card'),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0F172A).withValues(alpha: 0.04),
                  TraverzaColors.secondary.withValues(alpha: 0.06),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: TraverzaColors.secondary.withValues(alpha: 0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Feature Section Header with Live Radar Pulse Indicator
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: TraverzaColors.emeraldSuccess,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.6),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'LIVE ISLAND RADAR',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: TraverzaColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: TraverzaColors.secondary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '6 Districts Active',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: TraverzaColors.secondary,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            key: const Key('home_open_community_pulse_button'),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CommunityPulseScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TraverzaColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Full Pulse',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 3),
                                Icon(Icons.arrow_forward_rounded, size: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Community Pulse',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                          color: TraverzaColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Real-time moments, video dispatches & verified local trail intelligence',
                        style: TextStyle(
                          fontSize: 11,
                          color: TraverzaColors.textMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Creative Action Launcher Chips Bar (Share Photo, Post Video, Advisory, Ask Guide)
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildPulseActionChip(
                        icon: Icons.camera_alt_rounded,
                        label: 'Share Photo',
                        color: const Color(0xFF0284C7),
                        bgColor: const Color(0xFFE0F2FE),
                        onTap: () => CreatePostSheet.show(
                          context,
                          initialPostType: PostType.photo,
                          initialMediaTab: 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildPulseActionChip(
                        icon: Icons.videocam_rounded,
                        label: 'Post Video',
                        color: const Color(0xFFDC2626),
                        bgColor: const Color(0xFFFEE2E2),
                        badgeText: 'HD',
                        onTap: () => CreatePostSheet.show(
                          context,
                          initialPostType: PostType.video,
                          initialMediaTab: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildPulseActionChip(
                        icon: Icons.warning_amber_rounded,
                        label: 'Road Advisory',
                        color: const Color(0xFFD97706),
                        bgColor: const Color(0xFFFEF3C7),
                        onTap: () => CreatePostSheet.show(
                          context,
                          initialPostType: PostType.fieldReport,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildPulseActionChip(
                        icon: Icons.help_outline_rounded,
                        label: 'Ask Guide',
                        color: const Color(0xFF0D9488),
                        bgColor: const Color(0xFFCCFBF1),
                        onTap: () => CreatePostSheet.show(
                          context,
                          initialPostType: PostType.question,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 3. Living Moments & Video Dispatches Stream (Horizontal Reel)
                ListenableBuilder(
                  listenable: CommunityService.instance,
                  builder: (context, _) {
                    final posts = CommunityService.instance.allPosts;
                    if (posts.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return SizedBox(
                      height: 215,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: posts.length,
                        separatorBuilder: (ctx, idx) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return _buildHomePulseMomentCard(context, post);
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // 4. Live Island Radar & Road Status Telemetry Ticker
                _buildIslandRadarTicker(context),

                const SizedBox(height: 12),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 5. "Explore services" Header & 2-Column Photographic Bento Grid (Style B)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Explore services',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TraverzaColors.text,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'All curated providers across the island',
                        style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: widget.onNavigateToCatalogue,
                  style: TextButton.styleFrom(
                    foregroundColor: TraverzaColors.secondary,
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
                  onTap: () => widget.onCategorySelected(cat),
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
                    color: TraverzaColors.text,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  'Expertly paced multi-day corridors with verified drivers',
                  style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
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
                  onTap: widget.onNavigateToPlan,
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Creative Google Maps Sri Lanka Corridor Explorer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [TraverzaColors.primary, Color(0xFF0C4A6E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: TraverzaColors.primary.withValues(alpha: 0.15),
                    blurRadius: 12,
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
                      Expanded(
                        child: Row(
                          children: const [
                            Icon(Icons.map_rounded, color: TraverzaColors.accent, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Google Maps Corridor Explorer',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: TraverzaColors.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Live GPS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Explore Sri Lanka’s curated corridors with verified routes, terrain warnings, and 1-tap Google Maps navigation.',
                    style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMapCorridorChip(
                        label: 'Cultural Triangle (Sigiriya)',
                        lat: 7.9570,
                        lng: 80.7603,
                      ),
                      _buildMapCorridorChip(
                        label: 'Kandy Highlands (Tooth Relic)',
                        lat: 7.2936,
                        lng: 80.6413,
                      ),
                      _buildMapCorridorChip(
                        label: 'Nuwara Eliya (Tea Valleys)',
                        lat: 6.9497,
                        lng: 80.7891,
                      ),
                      _buildMapCorridorChip(
                        label: 'Southern Galle Fort',
                        lat: 6.0329,
                        lng: 80.2168,
                      ),
                    ],
                  ),
                ],
              ),
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
                    color: TraverzaColors.text,
                    letterSpacing: -0.2,
                  ),
                ),
                const Text(
                  'Intelligent trip coordination & safety utilities',
                  style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                ),
                const SizedBox(height: 12),
                ManageJourneyShortcut(
                  icon: Icons.alt_route_rounded,
                  title: 'Trip Canvas',
                  description: 'Build and organise every day of the trip.',
                  onTap: widget.onNavigateToPlan,
                  iconColor: TraverzaColors.lagoonTeal,
                ),
                const SizedBox(height: 8),
                ManageJourneyShortcut(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Trip budget',
                  description: 'Estimate and track committed costs (LKR 68,500 total).',
                  onTap: widget.onNavigateToPlan,
                  iconColor: TraverzaColors.emeraldSuccess,
                ),
                const SizedBox(height: 8),
                ManageJourneyShortcut(
                  icon: Icons.explore_outlined,
                  title: 'Routes & nearby',
                  description: 'Explore stops, highland transit buffers and services.',
                  onTap: widget.onNavigateToPlan,
                  iconColor: TraverzaColors.warmSand,
                ),
                const SizedBox(height: 8),
                ManageJourneyShortcut(
                  icon: Icons.shield_outlined,
                  title: 'Travel safety',
                  description: 'Access 1912 Tourism Hotline, 1990 Ambulance & Emergency Vault.',
                  onTap: widget.onNavigateToSafety,
                  iconColor: TraverzaColors.roseEmergency,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 8. Compact Action Needed / Support Banner
          if (!widget.isHotelConfirmed)
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
                              color: TraverzaColors.text,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Sigiriya Eco Villa requested. Response guaranteed within 12h SLA. Operations Rescue Desk is active.',
                            style: TextStyle(
                              fontSize: 10,
                              color: TraverzaColors.textMuted,
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

  Widget _buildPulseActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomePulseMomentCard(BuildContext context, CommunityPostModel post) {
    final media = post.media.isNotEmpty ? post.media.first : null;
    final imageUrl = media?.thumbnailUrl ?? media?.mediaUrl ?? 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=800&q=80';
    final isVideo = post.postType == PostType.video || (media != null && media.mediaType == 'video');

    Color typeColor;
    String typeLabel;
    IconData typeIcon;
    switch (post.postType) {
      case PostType.video:
        typeColor = const Color(0xFFEF4444);
        typeLabel = 'VIDEO REEL';
        typeIcon = Icons.videocam_rounded;
        break;
      case PostType.fieldReport:
        typeColor = const Color(0xFFF59E0B);
        typeLabel = 'LIVE REPORT';
        typeIcon = Icons.bolt_rounded;
        break;
      case PostType.localNote:
        typeColor = const Color(0xFF10B981);
        typeLabel = 'GUIDE NOTE';
        typeIcon = Icons.verified_user_rounded;
        break;
      case PostType.question:
        typeColor = const Color(0xFF0284C7);
        typeLabel = 'Q&A SIGNAL';
        typeIcon = Icons.help_outline_rounded;
        break;
      default:
        typeColor = const Color(0xFF8B5CF6);
        typeLabel = 'MOMENT';
        typeIcon = Icons.photo_camera_rounded;
    }

    final avatarUrl = post.authorAvatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final dest = (post.destinationName != null && post.destinationName!.isNotEmpty)
        ? post.destinationName!
        : post.districtName;
    final placeName = dest.contains('·') ? dest.split('·').first.trim() : dest;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PostDetailScreen(postId: post.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 180,
          height: 215,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Media Image / Thumbnail
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1E293B),
                  child: const Center(
                    child: Icon(Icons.terrain_rounded, color: Colors.white30, size: 36),
                  ),
                ),
              ),

              // 2. Cinematic Gradient Scrim
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    stops: const [0.0, 0.42, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // 3. Top Badges Row (Type Pill + Video Duration)
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon, size: 10, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            typeLabel,
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isVideo)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.play_arrow_rounded, size: 10, color: Colors.white),
                            const SizedBox(width: 2),
                            Text(
                              '${media?.durationSeconds ?? 18}s',
                              style: const TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // 4. Center Play Button if Video
              if (isVideo)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),

              // 5. Bottom Metadata Overlay
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Author Row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 9,
                          backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                          onBackgroundImageError: hasAvatar ? (obj, trace) {} : null,
                          child: !hasAvatar
                              ? Text(
                                  post.authorName.isNotEmpty ? post.authorName[0] : 'T',
                                  style: const TextStyle(fontSize: 7.5, color: Colors.white),
                                )
                              : null,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            post.authorName,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (post.authorBadge == AuthorBadge.licensedGuide)
                          const Icon(Icons.verified_rounded, size: 11, color: Color(0xFF38BDF8))
                        else if (post.authorBadge == AuthorBadge.verifiedVisitor)
                          const Icon(Icons.check_circle_rounded, size: 11, color: Color(0xFF34D399)),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Destination Tag
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 10, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            placeName,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFCD34D),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Caption preview
                    Text(
                      post.caption,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFE2E8F0),
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),

                    // Micro-stats
                    Row(
                      children: [
                        const Icon(Icons.favorite_rounded, size: 10, color: Color(0xFFF43F5E)),
                        const SizedBox(width: 3),
                        Text(
                          '${post.likeCount}',
                          style: const TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chat_bubble_outline_rounded, size: 9.5, color: Colors.white70),
                        const SizedBox(width: 3),
                        Text(
                          '${post.commentCount} replies',
                          style: const TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIslandRadarTicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CommunityPulseScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sensors_rounded,
                  size: 13,
                  color: TraverzaColors.emeraldSuccess,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'LIVE RADAR:',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: TraverzaColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  '🟢 Sigiriya: Clear ascent · 🟡 Ramboda Pass: Light mist · 🟢 Nine Arch: Train on schedule',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: TraverzaColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 15,
                color: TraverzaColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
