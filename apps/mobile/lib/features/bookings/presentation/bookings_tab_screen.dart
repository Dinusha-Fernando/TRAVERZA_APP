import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../data/booking_models.dart';
import 'widgets/booking_detail_sheet.dart';
import 'widgets/booking_voucher_sheet.dart';
import 'widgets/service_detail_modal.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/presentation/welcome_auth_screen.dart';
import '../../../widgets/creative_auth_gate_dialog.dart';
import '../../../widgets/creative_google_button.dart';

enum BookingTabMode {
  explore,
  myBookings,
}

enum BookingFilterSegment {
  needsAction,
  upcoming,
  past,
  cancelled,
}

class BookingsTabScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialSearchQuery;
  final BookingTabMode initialMode;

  const BookingsTabScreen({
    super.key,
    this.initialCategory,
    this.initialSearchQuery,
    this.initialMode = BookingTabMode.explore,
  });

  @override
  State<BookingsTabScreen> createState() => _BookingsTabScreenState();
}

class _BookingsTabScreenState extends State<BookingsTabScreen> {
  late BookingTabMode _currentMode;
  BookingFilterSegment _myBookingsSegment = BookingFilterSegment.needsAction;

  String? _selectedCategory;
  String? _searchQuery;
  bool _fitToTripActive = true;
  late TextEditingController _searchController;

  final List<TraverzaServiceItem> _allInventory = TraverzaServiceItem.getCuratedInventory();
  late List<TraverzaBooking> _userBookings;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
    _selectedCategory = widget.initialCategory;
    _searchQuery = widget.initialSearchQuery;
    _searchController = TextEditingController(text: _searchQuery ?? '');
    _userBookings = TraverzaBooking.getSampleBookings();
  }

  @override
  void didUpdateWidget(covariant BookingsTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory) {
      setState(() {
        _selectedCategory = widget.initialCategory;
      });
    }
    if (widget.initialSearchQuery != oldWidget.initialSearchQuery) {
      setState(() {
        _searchQuery = widget.initialSearchQuery;
        _searchController.text = _searchQuery ?? '';
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TraverzaServiceItem> get _filteredInventory {
    return _allInventory.where((item) {
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        if (item.category != _selectedCategory &&
            !(_selectedCategory == 'ACCOMMODATION' && item.category == 'STAY')) {
          return false;
        }
      }
      if (_searchQuery != null && _searchQuery!.trim().isNotEmpty) {
        final q = _searchQuery!.toLowerCase();
        final matches = item.title.toLowerCase().contains(q) ||
            item.provider.toLowerCase().contains(q) ||
            item.category.toLowerCase().contains(q) ||
            item.location.toLowerCase().contains(q) ||
            item.license.toLowerCase().contains(q);
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  List<TraverzaBooking> get _filteredBookings {
    switch (_myBookingsSegment) {
      case BookingFilterSegment.needsAction:
        return _userBookings
            .where((b) => b.status == BookingStatus.requestSubmitted || b.status == BookingStatus.providerAccepted)
            .toList();
      case BookingFilterSegment.upcoming:
        return _userBookings
            .where((b) => b.status == BookingStatus.confirmed || b.status == BookingStatus.inProgress)
            .toList();
      case BookingFilterSegment.past:
        return _userBookings
            .where((b) => b.status == BookingStatus.completed)
            .toList();
      case BookingFilterSegment.cancelled:
        return _userBookings
            .where((b) => b.status == BookingStatus.cancelled || b.status == BookingStatus.exception)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mode Selector: Explore Services vs My Bookings
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
              _buildModeTab('Explore Services', BookingTabMode.explore, Icons.travel_explore),
              _buildModeTab(
                'My Bookings (${_userBookings.where((b) => b.status != BookingStatus.cancelled).length})',
                BookingTabMode.myBookings,
                Icons.confirmation_number_outlined,
              ),
            ],
          ),
        ),

        // Body
        Expanded(
          child: _currentMode == BookingTabMode.explore
              ? _buildExploreView()
              : (!TraverzaAuthService.instance.isAccountComplete
                  ? _buildLockedBookingsVaultView()
                  : _buildMyBookingsView()),
        ),
      ],
    );
  }

  Widget _buildModeTab(String label, BookingTabMode mode, IconData icon) {
    final isSelected = _currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? TraverzaColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : TraverzaColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : TraverzaColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // VIEW 1: Explore Services Marketplace
  // ==========================================
  Widget _buildExploreView() {
    final filtered = _filteredInventory;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      physics: const BouncingScrollPhysics(),
      children: [
        // Context Header
        const Text(
          'Services for your trip',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: TraverzaColors.text),
        ),
        const SizedBox(height: 2),
        const Text(
          'Fit-to-Trip Verified Services',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: TraverzaColors.secondary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Services matched against corridor route, dates, and party size.',
          style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
        ),
        const SizedBox(height: 12),

        // Search Bar
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: TraverzaColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TraverzaColors.border),
          ),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (query) => setState(() => _searchQuery = query),
            decoration: InputDecoration(
              hintText: 'Search service, destination, provider or license...',
              hintStyle: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
              prefixIcon: const Icon(Icons.search, size: 18, color: TraverzaColors.secondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = null;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Fit-to-Trip Corridor Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: TraverzaColors.secondary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: TraverzaColors.secondary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.alt_route, size: 16, color: TraverzaColors.secondary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Corridor: Colombo (CMB) → Sigiriya → Kandy → Nuwara Eliya',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                ),
              ),
              InkWell(
                onTap: () => setState(() => _fitToTripActive = !_fitToTripActive),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _fitToTripActive ? TraverzaColors.secondary : TraverzaColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: TraverzaColors.secondary),
                  ),
                  child: Text(
                    _fitToTripActive ? 'Fit-to-Trip ON' : 'All Sri Lanka',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _fitToTripActive ? Colors.white : TraverzaColors.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Category Shortcuts (Spec Section 2.2)
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryShortcut('All', null),
              _buildCategoryShortcut('Transport', 'TRANSFER'),
              _buildCategoryShortcut('Stays', 'STAY'),
              _buildCategoryShortcut('Guides', 'GUIDE'),
              _buildCategoryShortcut('Activities', 'ACTIVITY'),
            ],
          ),
        ),

        // Active filter chips (Filtered: $category, Search: "$query")
        if (_selectedCategory != null || _searchQuery != null) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_selectedCategory != null)
                InkWell(
                  onTap: () => setState(() => _selectedCategory = null),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
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
                        const Icon(Icons.close, size: 14, color: TraverzaColors.primary),
                      ],
                    ),
                  ),
                ),
              if (_searchQuery != null)
                InkWell(
                  onTap: () {
                    setState(() {
                      _searchQuery = null;
                      _searchController.clear();
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
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
                        const Icon(Icons.close, size: 14, color: TraverzaColors.primary),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 14),

        // Empty state
        if (filtered.isEmpty)
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
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _searchQuery = null;
                        _searchController.clear();
                      });
                    },
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
          // Service Cards List
          ...filtered.map((item) => _buildServiceCard(item)),
      ],
    );
  }

  Widget _buildServiceCard(TraverzaServiceItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: TraverzaColors.border),
      ),
      elevation: 0,
      color: TraverzaColors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openServiceDetail(item),
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
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(
                        color: TraverzaColors.secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: TraverzaColors.rating, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        item.rating,
                        style: const TextStyle(color: TraverzaColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: TraverzaColors.text),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.verified, size: 13, color: TraverzaColors.secondary),
                  const SizedBox(width: 4),
                  const Text(
                    'SLTDA Verified',
                    style: TextStyle(fontSize: 11.5, color: TraverzaColors.secondary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '• ${item.provider}',
                    style: const TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.policy,
                      style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.price,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: TraverzaColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alt_route, size: 12, color: TraverzaColors.emeraldSuccess),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        item.fitToTripReason,
                        style: const TextStyle(fontSize: 10.5, color: TraverzaColors.emeraldSuccess, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  void _openServiceDetail(TraverzaServiceItem item) {
    ServiceDetailModal.show(
      context,
      service: item,
      onAddToTrip: () async {
        if (!TraverzaAuthService.instance.isAccountComplete) {
          final granted = await CreativeAuthGateSheet.show(
            context,
            featureTitle: 'Trip Planner Sync',
            actionMessage: 'Add "${item.title}" to Trip Draft',
            clearanceReason:
                'Syncing multi-stop corridor itineraries and hotel bookings requires an authenticated TRAVERZA account.',
            featureIcon: Icons.route_rounded,
          );
          if (!granted) return;
        }
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${item.title}" to your active trip draft.'),
            backgroundColor: TraverzaColors.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onRequestBooking: () async {
        if (!TraverzaAuthService.instance.isAccountComplete) {
          final granted = await CreativeAuthGateSheet.show(
            context,
            featureTitle: 'Verified Bookings',
            actionMessage: 'Reserve ${item.title}',
            clearanceReason:
                'Sri Lanka Tourism Development Authority (SLTDA) escrow safety and licensed provider insurance require an active, verified traveller account.',
            featureIcon: Icons.confirmation_number_rounded,
          );
          if (!granted) return;
        }
        if (!mounted) return;

        final profile = TraverzaAuthService.instance.currentProfile;
        // Create booking request and switch to My Bookings
        final newBooking = TraverzaBooking(
          id: 'TRIP-LK-2026-9041-B0${_userBookings.length + 1}',
          tripId: 'TRIP-LK-2026-9041',
          serviceTitle: item.title,
          category: item.category,
          providerName: item.provider,
          sltdaLicenseNo: item.license,
          dateDescription: '25 Oct 2026',
          timeWindow: 'Scheduled as per corridor itinerary',
          locationDetails: item.location,
          priceFormatted: item.price,
          priceBasis: item.priceBasis,
          status: BookingStatus.requestSubmitted,
          responseDeadline: DateTime.now().add(const Duration(hours: 12)),
          cancellationTerms: item.policy,
          qrToken: 'TRV-VOUCHER-${item.id}-${profile.id}',
          timeline: [
            TraverzaBookingEvent(
              title: 'Booking Request Submitted',
              description: 'Request dispatched under SLTDA escrow protection for ${profile.fullName}.',
              timestamp: 'Just now',
              actorRole: 'TRAVELLER',
            ),
          ],
        );

        setState(() {
          _userBookings.insert(0, newBooking);
          _currentMode = BookingTabMode.myBookings;
          _myBookingsSegment = BookingFilterSegment.needsAction;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking request submitted to ${item.provider}!'),
            backgroundColor: TraverzaColors.emeraldSuccess,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Widget _buildLockedBookingsVaultView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF031622),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.40),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: TraverzaColors.secondary.withValues(alpha: 0.15),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TraverzaColors.secondary.withValues(alpha: 0.20),
                  border: Border.all(color: TraverzaColors.accent.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.lock_person_rounded, size: 36, color: TraverzaColors.accent),
              ),
              const SizedBox(height: 14),
              const Text(
                'SLTDA Booking Vault Locked',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Active multi-stop reservations, offline emergency vouchers, and licensed driver live sync require a verified TRAVERZA account.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildVaultPill(Icons.verified_outlined, 'SLTDA Escrow'),
                    Container(width: 1, height: 18, color: Colors.white.withValues(alpha: 0.2)),
                    _buildVaultPill(Icons.qr_code_2_rounded, 'Offline QR'),
                    Container(width: 1, height: 18, color: Colors.white.withValues(alpha: 0.2)),
                    _buildVaultPill(Icons.alt_route, 'Driver Sync'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              CreativeGoogleButton(
                onPressed: () async {
                  final success = await TraverzaAuthService.instance.signInWithGoogle();
                  if (success && mounted) {
                    setState(() {});
                  }
                },
                text: 'Continue with Google',
                subtitle: 'Instant 1-Tap Booking Access',
                variant: CreativeGoogleVariant.pearl,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    WelcomeAuthScreen.show(context).then((_) {
                      if (mounted) setState(() {});
                    });
                  },
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                  label: const Text('Create Account or Sign In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TraverzaColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVaultPill(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: TraverzaColors.accent),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white70)),
      ],
    );
  }

  // ==========================================
  // VIEW 2: My Bookings Control Centre
  // ==========================================
  Widget _buildMyBookingsView() {
    final bookings = _filteredBookings;

    return Column(
      children: [
        // Sub-segment filters: Needs Action, Upcoming, Past, Cancelled
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              _buildSegmentPill('Needs Action', BookingFilterSegment.needsAction),
              _buildSegmentPill('Upcoming', BookingFilterSegment.upcoming),
              _buildSegmentPill('Past', BookingFilterSegment.past),
              _buildSegmentPill('Cancelled & Refunds', BookingFilterSegment.cancelled),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Bookings List
        Expanded(
          child: bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 48, color: TraverzaColors.textMuted.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      const Text(
                        'No bookings in this category',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: TraverzaColors.text),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Browse verified services to request or confirm a reservation.',
                        style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () => setState(() => _currentMode = BookingTabMode.explore),
                        icon: const Icon(Icons.search, size: 16),
                        label: const Text('Explore Services'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final b = bookings[index];
                    return _buildMyBookingCard(b);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryShortcut(String label, String? category) {
    final isSelected = _selectedCategory == category || (category == null && _selectedCategory == null);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          setState(() {
            _selectedCategory = category;
          });
        },
        selectedColor: TraverzaColors.primary,
        backgroundColor: TraverzaColors.surface,
        side: BorderSide(
          color: isSelected ? TraverzaColors.primary : TraverzaColors.border,
        ),
        labelStyle: TextStyle(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : TraverzaColors.text,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
    );
  }

  Widget _buildSegmentPill(String title, BookingFilterSegment segment) {
    final isSelected = _myBookingsSegment == segment;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(title),
        selected: isSelected,
        onSelected: (val) {
          if (val) setState(() => _myBookingsSegment = segment);
        },
        selectedColor: TraverzaColors.secondary.withValues(alpha: 0.15),
        backgroundColor: TraverzaColors.surface,
        side: BorderSide(
          color: isSelected ? TraverzaColors.secondary : TraverzaColors.border,
        ),
        labelStyle: TextStyle(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? TraverzaColors.secondary : TraverzaColors.textMuted,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
    );
  }

  Widget _buildMyBookingCard(TraverzaBooking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TraverzaColors.border),
        boxShadow: [
          BoxShadow(
            color: TraverzaColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar with ID and Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: TraverzaColors.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(bottom: BorderSide(color: TraverzaColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  b.id,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: TraverzaColors.secondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: b.status.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: b.status.color),
                  ),
                  child: Text(
                    b.status.label,
                    style: TextStyle(
                      color: b.status.color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Info
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.serviceTitle,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                ),
                const SizedBox(height: 3),
                Text(
                  '${b.providerName} • ${b.sltdaLicenseNo}',
                  style: const TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 13, color: TraverzaColors.secondary),
                    const SizedBox(width: 4),
                    Text(b.dateDescription, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 14),
                    const Icon(Icons.payments_outlined, size: 13, color: TraverzaColors.secondary),
                    const SizedBox(width: 4),
                    Text(b.priceFormatted, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TraverzaColors.primary)),
                  ],
                ),
                const SizedBox(height: 12),

                // Action Bar
                Row(
                  children: [
                    if (b.status == BookingStatus.confirmed)
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TraverzaColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                          ),
                          onPressed: () => BookingVoucherSheet.show(context, booking: b),
                          icon: const Icon(Icons.qr_code, size: 15, color: Colors.white),
                          label: const Text('View Voucher', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      )
                    else if (b.status == BookingStatus.requestSubmitted)
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: TraverzaColors.amberWarning,
                            side: const BorderSide(color: TraverzaColors.amberWarning),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                          ),
                          onPressed: () => _openBookingDetail(b),
                          icon: const Icon(Icons.hourglass_top, size: 14),
                          label: const Text('Awaiting Provider (12h SLA)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: TraverzaColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      ),
                      onPressed: () => _openBookingDetail(b),
                      child: const Text('Details', style: TextStyle(color: TraverzaColors.text, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openBookingDetail(TraverzaBooking b) {
    BookingDetailSheet.show(
      context,
      booking: b,
      onBookingUpdated: () => setState(() {}),
    );
  }
}
