import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../bookings/data/booking_models.dart';
import '../../bookings/presentation/widgets/service_detail_modal.dart';
import '../data/saved_models.dart';
import 'widgets/saved_sheets.dart';

enum SavedViewMode {
  wishlist,
  readiness,
  compare,
}

class SavedTabScreen extends StatefulWidget {
  final bool isHotelConfirmed;
  final VoidCallback onToggleHotelConfirmation;

  const SavedTabScreen({
    super.key,
    this.isHotelConfirmed = false,
    required this.onToggleHotelConfirmation,
  });

  @override
  State<SavedTabScreen> createState() => _SavedTabScreenState();
}

class _SavedTabScreenState extends State<SavedTabScreen> {
  SavedViewMode _currentView = SavedViewMode.wishlist;
  String _selectedCollectionId = 'col_all';
  String? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  late List<SavedCollection> _collections;
  late List<SavedItem> _savedItems;

  @override
  void initState() {
    super.initState();
    _collections = SavedRepository.getInitialCollections();
    _savedItems = SavedRepository.getInitialSavedItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SavedItem> get _filteredItems {
    return _savedItems.where((item) {
      if (_selectedCollectionId != 'col_all' && item.collectionId != _selectedCollectionId) {
        return false;
      }
      if (_selectedCategory != null && item.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matches = item.title.toLowerCase().contains(q) ||
            item.provider.toLowerCase().contains(q) ||
            item.location.toLowerCase().contains(q) ||
            item.corridorDay.toLowerCase().contains(q) ||
            (item.personalNotes != null && item.personalNotes!.toLowerCase().contains(q));
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  void _handleDeleteItem(SavedItem item) {
    final deletedIndex = _savedItems.indexOf(item);
    setState(() {
      _savedItems.remove(item);
      _updateCollectionCounts();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${item.title}" from Saved.'),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: TraverzaColors.accent,
          onPressed: () {
            setState(() {
              _savedItems.insert(deletedIndex, item);
              _updateCollectionCounts();
            });
          },
        ),
        backgroundColor: TraverzaColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateCollectionCounts() {
    for (var col in _collections) {
      if (col.id == 'col_all') {
        col.itemCount = _savedItems.length;
      } else {
        col.itemCount = _savedItems.where((i) => i.collectionId == col.id).length;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TraverzaColors.background,
      body: Column(
        children: [
          // Header & View Selector
          _buildHeader(),

          // Main View Content
          Expanded(
            child: _currentView == SavedViewMode.wishlist
                ? _buildWishlistView()
                : _currentView == SavedViewMode.readiness
                    ? _buildReadinessView()
                    : _buildCompareView(),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Header with Segmented Navigation
  // ==========================================
  Widget _buildHeader() {
    return Container(
      color: TraverzaColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Saved & Wishlist Hub',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: TraverzaColors.text,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Curated shortlist & trip readiness audit for your corridor',
                      style: TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: TraverzaColors.secondary),
                tooltip: 'Share Wishlist',
                onPressed: () => ShareWishlistSheet.show(
                  context,
                  totalCount: _savedItems.length,
                  collections: _collections,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3-way Segmented Switch: Wishlist / Trip Readiness / Compare
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: TraverzaColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TraverzaColors.border),
            ),
            child: Row(
              children: [
                _buildSegmentButton('Wishlist (${_savedItems.length})', SavedViewMode.wishlist, Icons.bookmark_outline),
                _buildSegmentButton(
                  widget.isHotelConfirmed ? '100% Ready' : '85% Ready',
                  SavedViewMode.readiness,
                  Icons.verified_user_outlined,
                  badgeColor: widget.isHotelConfirmed ? TraverzaColors.emeraldSuccess : TraverzaColors.amberWarning,
                ),
                _buildSegmentButton('Compare (2)', SavedViewMode.compare, Icons.compare_arrows_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String label, SavedViewMode mode, IconData icon, {Color? badgeColor}) {
    final isSelected = _currentView == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentView = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? TraverzaColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : (badgeColor ?? TraverzaColors.textMuted),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : TraverzaColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // VIEW 1: My Wishlist & Collections
  // ==========================================
  Widget _buildWishlistView() {
    final items = _filteredItems;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      physics: const BouncingScrollPhysics(),
      children: [
        // Search Input
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: TraverzaColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TraverzaColors.border),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search saved stays, rides, activities or notes...',
              hintStyle: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
              prefixIcon: const Icon(Icons.search, size: 18, color: TraverzaColors.secondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 9),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Collections Selector Bar + Create Button
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._collections.map((col) {
                final isSelected = _selectedCollectionId == col.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(col.icon, size: 16, color: isSelected ? Colors.white : col.color),
                    label: Text('${col.name} (${col.itemCount})'),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedCollectionId = col.id);
                    },
                    selectedColor: TraverzaColors.primary,
                    backgroundColor: TraverzaColors.surface,
                    side: BorderSide(color: isSelected ? TraverzaColors.primary : TraverzaColors.border),
                    labelStyle: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : TraverzaColors.text,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  ),
                );
              }),
              ActionChip(
                avatar: const Icon(Icons.add, size: 16, color: TraverzaColors.secondary),
                label: const Text('New Collection', style: TextStyle(color: TraverzaColors.secondary, fontSize: 11.5, fontWeight: FontWeight.bold)),
                backgroundColor: TraverzaColors.secondary.withValues(alpha: 0.1),
                side: const BorderSide(color: TraverzaColors.secondary),
                onPressed: () {
                  CreateCollectionSheet.show(
                    context,
                    onCreate: (name, desc, icon, color) {
                      setState(() {
                        final newId = 'col_${DateTime.now().millisecondsSinceEpoch}';
                        _collections.add(
                          SavedCollection(
                            id: newId,
                            name: name,
                            description: desc,
                            icon: icon,
                            color: color,
                            itemCount: 0,
                          ),
                        );
                        _selectedCollectionId = newId;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Created collection "$name".'),
                          backgroundColor: TraverzaColors.emeraldSuccess,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryChip('All Categories', null),
              _buildCategoryChip('Stays', 'STAY'),
              _buildCategoryChip('Transport', 'TRANSFER'),
              _buildCategoryChip('Activities', 'ACTIVITY'),
              _buildCategoryChip('Guides', 'GUIDE'),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Items List or Empty State
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.bookmark_border_rounded, size: 54, color: TraverzaColors.textMuted.withValues(alpha: 0.4)),
                const SizedBox(height: 12),
                const Text(
                  'No saved services in this collection',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: TraverzaColors.text),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Browse corridor services and tap the bookmark icon to save here.',
                  style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedCollectionId = 'col_all';
                      _selectedCategory = null;
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reset Filters'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: TraverzaColors.border),
                  ),
                ),
              ],
            ),
          )
        else
          ...items.map((item) => _buildSavedItemCard(item)),
      ],
    );
  }

  Widget _buildCategoryChip(String label, String? categoryCode) {
    final isSelected = _selectedCategory == categoryCode;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          setState(() {
            _selectedCategory = val ? categoryCode : null;
          });
        },
        selectedColor: TraverzaColors.secondary.withValues(alpha: 0.15),
        backgroundColor: TraverzaColors.surface,
        side: BorderSide(color: isSelected ? TraverzaColors.secondary : TraverzaColors.border),
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? TraverzaColors.secondary : TraverzaColors.textMuted,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
    );
  }

  Widget _buildSavedItemCard(SavedItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TraverzaColors.border),
        boxShadow: [
          BoxShadow(
            color: TraverzaColors.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Open standard service detail modal
          ServiceDetailModal.show(
            context,
            service: TraverzaServiceItem(
              id: item.serviceId,
              title: item.title,
              category: item.category,
              provider: item.provider,
              license: item.sltdaLicense,
              price: item.price,
              priceBasis: item.priceBasis,
              policy: item.cancellationTerms,
              rating: item.rating,
              location: item.location,
              imageUrl: item.imageUrl,
              fitToTripReason: item.fitToTripReason,
              inclusions: item.inclusions,
            ),
            onAddToTrip: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added "${item.title}" to active itinerary draft.'),
                  backgroundColor: TraverzaColors.secondary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            onRequestBooking: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking request dispatched for "${item.title}".'),
                  backgroundColor: TraverzaColors.emeraldSuccess,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Banner with Badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    item.imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 140,
                      color: TraverzaColors.border,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image, color: TraverzaColors.textMuted),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: TraverzaColors.primary.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.corridorDay,
                      style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: TraverzaColors.rating, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          item.rating,
                          style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: TraverzaColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.category,
                          style: const TextStyle(color: TraverzaColors.secondary, fontSize: 9.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.verified, size: 13, color: TraverzaColors.secondary),
                          const SizedBox(width: 3),
                          Text(
                            item.sltdaLicense,
                            style: const TextStyle(fontSize: 10.5, color: TraverzaColors.secondary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${item.provider} • ${item.location}',
                    style: const TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted),
                  ),
                  const SizedBox(height: 8),

                  // Fit to Trip Reason Banner
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

                  // Traveler Private Note
                  if (item.personalNotes != null && item.personalNotes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TraverzaColors.warmSand.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: TraverzaColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.notes_rounded, size: 14, color: TraverzaColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.personalNotes!,
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: TraverzaColors.text),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              ItemNotesSheet.show(
                                context,
                                item: item,
                                onSaveNotes: (notes) {
                                  setState(() => item.personalNotes = notes);
                                },
                              );
                            },
                            child: const Icon(Icons.edit, size: 12, color: TraverzaColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: TraverzaColors.border),
                  const SizedBox(height: 10),

                  // Price & Quick Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.price,
                              style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: TraverzaColors.primary),
                            ),
                            Text(
                              item.priceBasis,
                              style: const TextStyle(fontSize: 10, color: TraverzaColors.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              MoveCollectionSheet.show(
                                context,
                                item: item,
                                collections: _collections,
                                onMove: (targetId) {
                                  setState(() {
                                    item.collectionId = targetId;
                                    _updateCollectionCounts();
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Item moved to collection.'),
                                      backgroundColor: TraverzaColors.secondary,
                                    ),
                                  );
                                },
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.all(5),
                              child: Icon(Icons.drive_file_move_outline, size: 18, color: TraverzaColors.secondary),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              ItemNotesSheet.show(
                                context,
                                item: item,
                                onSaveNotes: (notes) {
                                  setState(() => item.personalNotes = notes);
                                },
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.all(5),
                              child: Icon(Icons.edit_note_outlined, size: 20, color: TraverzaColors.secondary),
                            ),
                          ),
                          InkWell(
                            onTap: () => _handleDeleteItem(item),
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.all(5),
                              child: Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                            ),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TraverzaColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added "${item.title}" to Trip Canvas!'),
                                  backgroundColor: TraverzaColors.emeraldSuccess,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: const Text('Add to Trip', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VIEW 2: Trip Readiness & Safety Audit
  // ==========================================
  Widget _buildReadinessView() {
    final isAllConfirmed = widget.isHotelConfirmed;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      physics: const BouncingScrollPhysics(),
      children: [
        // Readiness Diagnostic Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                TraverzaColors.primary,
                TraverzaColors.secondary.withValues(alpha: 0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: TraverzaColors.primary.withValues(alpha: 0.2),
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
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAllConfirmed ? Icons.check_circle : Icons.warning_amber_rounded,
                            color: isAllConfirmed ? TraverzaColors.emeraldSuccess : TraverzaColors.amberWarning,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              isAllConfirmed ? '100% TRIP READY' : '85% READY · 1 PENDING',
                              style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 0.4),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: widget.onToggleHotelConfirmation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isAllConfirmed ? 'Simulate Pending' : 'Simulate 100% Ready',
                        style: const TextStyle(color: TraverzaColors.primary, fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Corridor Readiness Audit',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Connected route: Colombo (CMB) → Sigiriya → Kandy → Nuwara Eliya',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 14),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: isAllConfirmed ? 1.0 : 0.85,
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isAllConfirmed ? TraverzaColors.emeraldSuccess : TraverzaColors.amberWarning,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        const Text(
          'Diagnostic Safety & Invariant Checks',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text),
        ),
        const SizedBox(height: 4),
        const Text(
          'Authoritative verification of transit feasibility, audited SLTDA licenses, and daylight hours.',
          style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
        ),
        const SizedBox(height: 12),

        _buildDiagnosticTile(
          title: 'Transit Buffer Feasibility',
          subtitle: 'Hill-country transit speeds: CMB → Sigiriya (4.0h), Sigiriya → Kandy (2.5h), Kandy → Nuwara Eliya (2.5h) all clear.',
          icon: Icons.timer_outlined,
          isPassed: true,
          badgeText: 'VALIDATED',
        ),
        _buildDiagnosticTile(
          title: 'SLTDA Provider Verification',
          subtitle: 'All 3 shortlisted & booked suppliers hold active, audited SLTDA licenses (#102, #089, #044).',
          icon: Icons.verified_user_outlined,
          isPassed: true,
          badgeText: '100% AUDITED',
        ),
        _buildDiagnosticTile(
          title: 'Lodging & Service Confirmation',
          subtitle: isAllConfirmed
              ? 'All 3 corridor services confirmed with immutable cryptographic vouchers.'
              : '2 of 3 services confirmed. Sigiriya Water Garden Eco Villa is in REQUEST_SUBMITTED status (12h SLA active).',
          icon: Icons.hotel_outlined,
          isPassed: isAllConfirmed,
          badgeText: isAllConfirmed ? '3/3 CONFIRMED' : '1 ACTION NEEDED',
        ),
        _buildDiagnosticTile(
          title: 'Opening Hours & Daylight Invariants',
          subtitle: 'Sigiriya Rock ascent concludes safely before 18:15 sunset. Zero overlapping activities detected by TripGraph.',
          icon: Icons.wb_sunny_outlined,
          isPassed: true,
          badgeText: 'NO CONFLICTS',
        ),
        _buildDiagnosticTile(
          title: 'Offline Emergency Cache & SOS',
          subtitle: 'Emergency contact vault (119 Police, 1912 Tourism Hotline, 1990 Ambulance) cached locally.',
          icon: Icons.offline_pin_outlined,
          isPassed: true,
          badgeText: 'OFFLINE CACHED',
        ),
      ],
    );
  }

  Widget _buildDiagnosticTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isPassed,
    required String badgeText,
  }) {
    final statusColor = isPassed ? TraverzaColors.emeraldSuccess : TraverzaColors.amberWarning;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isPassed ? TraverzaColors.border : TraverzaColors.amberWarning.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: TraverzaColors.text),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(color: statusColor, fontSize: 9.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW 3: Side-by-Side Shortlist Comparison
  // ==========================================
  Widget _buildCompareView() {
    final staysToCompare = _savedItems.where((i) => i.category == 'STAY').toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TraverzaColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TraverzaColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.compare_arrows_rounded, color: TraverzaColors.secondary, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Shortlist Comparison Matrix',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Compare shortlisted options side-by-side to select the ideal stay for your Day 2 overnight stop in Sigiriya.',
                style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
              ),
              const SizedBox(height: 14),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TraverzaColors.primary,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (staysToCompare.length >= 2) {
                    CompareShortlistModal.show(
                      context,
                      items: staysToCompare.sublist(0, 2),
                      onSelectToTrip: (item) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Selected "${item.title}" for your Day 2 stay!'),
                            backgroundColor: TraverzaColors.emeraldSuccess,
                          ),
                        );
                      },
                    );
                  }
                },
                icon: const Icon(Icons.table_chart_outlined, size: 16, color: Colors.white),
                label: const Text('Open Comparison Table', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text('Shortlisted Stays in Cultural Triangle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 10),
        ...staysToCompare.map((item) => _buildSavedItemCard(item)),
      ],
    );
  }
}
