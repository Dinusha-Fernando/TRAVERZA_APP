import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../data/saved_models.dart';

/// Modal to create a new custom Wishlist Collection
class CreateCollectionSheet extends StatefulWidget {
  final Function(String name, String description, IconData icon, Color color) onCreate;

  const CreateCollectionSheet({super.key, required this.onCreate});

  static void show(BuildContext context, {required Function(String name, String description, IconData icon, Color color) onCreate}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateCollectionSheet(onCreate: onCreate),
    );
  }

  @override
  State<CreateCollectionSheet> createState() => _CreateCollectionSheetState();
}

class _CreateCollectionSheetState extends State<CreateCollectionSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  final List<IconData> _icons = [
    Icons.bookmark_outline_rounded,
    Icons.hotel_outlined,
    Icons.directions_car_outlined,
    Icons.tour_outlined,
    Icons.restaurant_outlined,
    Icons.hiking_outlined,
    Icons.spa_outlined,
    Icons.photo_camera_outlined,
  ];

  final List<Color> _colors = [
    TraverzaColors.primary,
    TraverzaColors.secondary,
    TraverzaColors.accent,
    TraverzaColors.rating,
    TraverzaColors.emeraldSuccess,
    const Color(0xFF8B5CF6),
  ];

  late IconData _selectedIcon;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedIcon = _icons[0];
    _selectedColor = _colors[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TraverzaColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Create Custom Collection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TraverzaColors.text),
            ),
            const SizedBox(height: 4),
            const Text(
              'Group your saved stays, chauffeur rides and activities for easy trip planning.',
              style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
            ),
            const SizedBox(height: 16),

            // Collection Name Input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Collection Name (e.g. Scenic Tea Bungalows)',
                labelStyle: const TextStyle(fontSize: 13, color: TraverzaColors.textMuted),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: TraverzaColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: TraverzaColors.secondary, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),

            // Description Input
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                labelStyle: const TextStyle(fontSize: 13, color: TraverzaColors.textMuted),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: TraverzaColors.border)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Icon Picker
            const Text('Choose Icon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: TraverzaColors.text)),
            const SizedBox(height: 8),
            Row(
              children: _icons.map((icon) {
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? _selectedColor.withValues(alpha: 0.15) : TraverzaColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? _selectedColor : TraverzaColors.border),
                    ),
                    child: Icon(icon, size: 20, color: isSelected ? _selectedColor : TraverzaColors.textMuted),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Color Picker
            const Text('Choose Accent Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: TraverzaColors.text)),
            const SizedBox(height: 8),
            Row(
              children: _colors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                      boxShadow: isSelected
                          ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6, spreadRadius: 1)]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: TraverzaColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: TraverzaColors.textMuted)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final name = _nameController.text.trim();
                      if (name.isEmpty) return;
                      widget.onCreate(name, _descController.text.trim(), _selectedIcon, _selectedColor);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TraverzaColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Create Collection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal to Edit or Add Traveler Notes to a Saved Item
class ItemNotesSheet extends StatefulWidget {
  final SavedItem item;
  final Function(String newNotes) onSaveNotes;

  const ItemNotesSheet({super.key, required this.item, required this.onSaveNotes});

  static void show(BuildContext context, {required SavedItem item, required Function(String newNotes) onSaveNotes}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ItemNotesSheet(item: item, onSaveNotes: onSaveNotes),
    );
  }

  @override
  State<ItemNotesSheet> createState() => _ItemNotesSheetState();
}

class _ItemNotesSheetState extends State<ItemNotesSheet> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.item.personalNotes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TraverzaColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.edit_note, color: TraverzaColors.secondary, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Travel Notes: ${widget.item.title}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Keep personal reminders, party preferences, or special requests private to your itinerary.',
            style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'e.g. Inquire about quiet chalet near lotus pond, verify toddler car seat availability...',
              hintStyle: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: TraverzaColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: TraverzaColors.secondary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: TraverzaColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: TraverzaColors.textMuted)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSaveNotes(_notesController.text.trim());
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TraverzaColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Note', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Modal to Move a Saved Item to another Collection
class MoveCollectionSheet extends StatelessWidget {
  final SavedItem item;
  final List<SavedCollection> collections;
  final Function(String targetCollectionId) onMove;

  const MoveCollectionSheet({
    super.key,
    required this.item,
    required this.collections,
    required this.onMove,
  });

  static void show(
    BuildContext context, {
    required SavedItem item,
    required List<SavedCollection> collections,
    required Function(String targetCollectionId) onMove,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MoveCollectionSheet(item: item, collections: collections, onMove: onMove),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TraverzaColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Move to Collection',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: TraverzaColors.text),
          ),
          const SizedBox(height: 4),
          Text(
            'Select a destination collection for "${item.title}".',
            style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
          ),
          const SizedBox(height: 16),

          ...collections.map((col) {
            final isCurrent = item.collectionId == col.id;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isCurrent ? TraverzaColors.secondary.withValues(alpha: 0.1) : TraverzaColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isCurrent ? TraverzaColors.secondary : TraverzaColors.border),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: col.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(col.icon, size: 18, color: col.color),
                ),
                title: Text(col.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isCurrent ? TraverzaColors.secondary : TraverzaColors.text)),
                subtitle: Text(col.description, style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: isCurrent ? const Icon(Icons.check, color: TraverzaColors.secondary, size: 18) : null,
                onTap: () {
                  onMove(col.id);
                  Navigator.pop(context);
                },
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Modal for Side-by-Side Comparison of Shortlisted Services
class CompareShortlistModal extends StatelessWidget {
  final List<SavedItem> items;
  final Function(SavedItem selected) onSelectToTrip;

  const CompareShortlistModal({
    super.key,
    required this.items,
    required this.onSelectToTrip,
  });

  static void show(BuildContext context, {required List<SavedItem> items, required Function(SavedItem selected) onSelectToTrip}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CompareShortlistModal(items: items, onSelectToTrip: onSelectToTrip),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(color: TraverzaColors.border, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Side-by-Side Service Comparison',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                      ),
                      Text(
                        'Compare price basis, SLTDA licence, and cancellation flexibility.',
                        style: TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: TraverzaColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: TraverzaColors.border),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items.map((item) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TraverzaColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: TraverzaColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              item.imageUrl,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 100,
                                color: TraverzaColors.border,
                                child: const Icon(Icons.image, color: TraverzaColors.textMuted),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: TraverzaColors.text),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.price,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: TraverzaColors.primary),
                          ),
                          Text(
                            item.priceBasis,
                            style: const TextStyle(fontSize: 10, color: TraverzaColors.textMuted),
                          ),
                          const Divider(height: 16, color: TraverzaColors.border),

                          _buildComparisonRow('Provider', item.provider),
                          _buildComparisonRow('SLTDA License', item.sltdaLicense),
                          _buildComparisonRow('Rating', item.rating),
                          _buildComparisonRow('Corridor Slot', item.corridorDay),
                          _buildComparisonRow('Cancellation', item.cancellationTerms),
                          _buildComparisonRow('Fit Reason', item.fitToTripReason),

                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TraverzaColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                onSelectToTrip(item);
                              },
                              child: const Text('Add to Trip Draft', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: TraverzaColors.textMuted, fontWeight: FontWeight.bold)),
          const SizedBox(height: 1),
          Text(value, style: const TextStyle(fontSize: 11, color: TraverzaColors.text)),
        ],
      ),
    );
  }
}

/// Modal to Share Wishlist / Export Shortlist
class ShareWishlistSheet extends StatelessWidget {
  final int totalCount;
  final List<SavedCollection> collections;

  const ShareWishlistSheet({super.key, required this.totalCount, required this.collections});

  static void show(BuildContext context, {required int totalCount, required List<SavedCollection> collections}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ShareWishlistSheet(totalCount: totalCount, collections: collections),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: TraverzaColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Icon(Icons.share_outlined, color: TraverzaColors.primary, size: 22),
              SizedBox(width: 8),
              Text(
                'Share Your Saved Wishlist',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: TraverzaColors.text),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Generate a secure shareable link for co-travellers with $totalCount shortlisted verified services.',
            style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TraverzaColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TraverzaColors.border),
            ),
            child: Row(
              children: const [
                Icon(Icons.link, size: 18, color: TraverzaColors.secondary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'https://traverza.lk/wishlist/trv-share-9041-colombo-kandy',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: TraverzaColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Wishlist PDF summary generated & downloaded.'),
                        backgroundColor: TraverzaColors.secondary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                  label: const Text('Export PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: TraverzaColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share link copied to clipboard!'),
                        backgroundColor: TraverzaColors.emeraldSuccess,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16, color: Colors.white),
                  label: const Text('Copy Link', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TraverzaColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
