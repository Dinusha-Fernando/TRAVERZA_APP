import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/atlas_models.dart';
import '../services/island_atlas_service.dart';

class DistrictPassportScreen extends StatelessWidget {
  const DistrictPassportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = IslandAtlasService();

    return Scaffold(
      backgroundColor: TraverzaColors.background,
      appBar: AppBar(
        title: const Text('District Passport', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: TraverzaColors.surface,
        elevation: 0,
        centerTitle: false,
      ),
      body: ValueListenableBuilder<List<DistrictPassportStamp>>(
        valueListenable: service.passportStampsNotifier,
        builder: (context, stamps, _) {
          final stampedCount = stamps.where((s) => s.isStamped).length;
          final progress = stampedCount / stamps.length;

          return CustomScrollView(
            slivers: [
              // Header Passport Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F3B57), Color(0xFF071424)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: TraverzaColors.lagoonTeal.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: TraverzaColors.lagoonTeal.withValues(alpha: 0.5)),
                              ),
                              child: const Text(
                                'OFFICIAL TRAVEL PASSPORT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                  color: TraverzaColors.lagoonTeal,
                                ),
                              ),
                            ),
                            const Icon(Icons.verified_user_rounded, color: TraverzaColors.emeraldSuccess, size: 20),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Sri Lanka 25-District Journal',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Collect digital stamps by visiting and learning about Sri Lanka\'s 25 official districts.',
                          style: TextStyle(color: TraverzaColors.warmSand, fontSize: 12),
                        ),
                        const SizedBox(height: 16),

                        // Progress Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$stampedCount of ${stamps.length} Districts Explored',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(color: TraverzaColors.lagoonTeal, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(TraverzaColors.lagoonTeal),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Stamps Grid Header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Text(
                    'All 25 Administrative Districts',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                  ),
                ),
              ),

              // Stamps 2-column Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final stamp = stamps[index];
                      return _PassportStampCard(
                        stamp: stamp,
                        onStampPressed: () => _showStampDialog(context, stamp),
                      );
                    },
                    childCount: stamps.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  void _showStampDialog(BuildContext context, DistrictPassportStamp stamp) {
    final noteController = TextEditingController(text: stamp.userNote);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              stamp.isStamped ? Icons.verified_rounded : Icons.add_location_alt_rounded,
              color: stamp.isStamped ? TraverzaColors.emeraldSuccess : TraverzaColors.primary,
            ),
            const SizedBox(width: 8),
            Text(stamp.districtName, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Province: ${stamp.provinceName}',
              style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
            ),
            const SizedBox(height: 6),
            Text(
              stamp.culturalFact,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: TraverzaColors.text),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Personal Travel Journal Note',
                hintText: 'e.g. Explored ancient caves with local guide...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              IslandAtlasService().stampDistrict(stamp.districtId, note: noteController.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${stamp.districtName} stamped in your passport!'),
                  backgroundColor: TraverzaColors.emeraldSuccess,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TraverzaColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(stamp.isStamped ? 'Update Journal' : 'Stamp Visit'),
          ),
        ],
      ),
    );
  }
}

class _PassportStampCard extends StatelessWidget {
  final DistrictPassportStamp stamp;
  final VoidCallback onStampPressed;

  const _PassportStampCard({
    required this.stamp,
    required this.onStampPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isStamped = stamp.isStamped;

    return InkWell(
      onTap: onStampPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isStamped ? const Color(0xFFFBFBF4) : TraverzaColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isStamped ? const Color(0xFFD97706).withValues(alpha: 0.6) : TraverzaColors.border,
            width: isStamped ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isStamped ? const Color(0xFFFEF3C7) : TraverzaColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isStamped ? const Color(0xFFD97706) : TraverzaColors.border,
                    ),
                  ),
                  child: Icon(
                    isStamped ? Icons.military_tech_rounded : Icons.place_outlined,
                    color: isStamped ? const Color(0xFFB45309) : TraverzaColors.textMuted,
                    size: 18,
                  ),
                ),
                if (isStamped)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0x1A10B981),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'VISITED',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stamp.districtName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isStamped ? const Color(0xFF78350F) : TraverzaColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  stamp.provinceName,
                  style: const TextStyle(fontSize: 10, color: TraverzaColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Text(
              isStamped ? stamp.userNote : stamp.culturalFact,
              style: TextStyle(
                fontSize: 10.5,
                color: isStamped ? const Color(0xFF92400E) : TraverzaColors.textMuted,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
