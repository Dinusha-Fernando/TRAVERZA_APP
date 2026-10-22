import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/atlas_models.dart';
import '../services/island_atlas_service.dart';

class DestinationDetailsScreen extends StatelessWidget {
  final DestinationModel destination;

  const DestinationDetailsScreen({
    super.key,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final district = IslandAtlasService().getDistrictById(destination.districtId);
    final province = IslandAtlasService().getProvinceById(destination.provinceId);

    return Scaffold(
      backgroundColor: TraverzaColors.background,
      body: CustomScrollView(
        slivers: [
          // Collapsible Photographic Hero AppBar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: TraverzaColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    destination.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF0F3B57),
                      child: const Center(
                        child: Icon(Icons.landscape_rounded, size: 64, color: Colors.white24),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.5),
                          const Color(0xFF0B1728).withValues(alpha: 0.95),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: TraverzaColors.oceanBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                destination.category,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                destination.placeType.toUpperCase(),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          destination.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${destination.nameSi} • ${destination.nameTa}',
                          style: const TextStyle(fontSize: 12, color: TraverzaColors.warmSand),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Breadcrumb
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Icon(Icons.place_rounded, size: 14, color: TraverzaColors.secondary),
                      Text(
                        '${district?.name ?? destination.districtId}, ${province?.name ?? destination.provinceId}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                      ),
                      const Text('•', style: TextStyle(color: TraverzaColors.textMuted)),
                      Text(
                        'Precision: ${destination.coordinatePrecision}',
                        style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Summary
                  Text(
                    destination.summary,
                    style: const TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w500, color: TraverzaColors.text),
                  ),
                  const SizedBox(height: 20),

                  // Plan Your Visit Card
                  _buildSectionHeader('Plan Your Visit', Icons.schedule_rounded),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TraverzaColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: TraverzaColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildVisitRow(Icons.timer_outlined, 'Dwell Duration', '${destination.dwellDurationMins} minutes recommended'),
                        const Divider(height: 16),
                        _buildVisitRow(Icons.access_time_rounded, 'Hours', destination.openingHoursText),
                        const Divider(height: 16),
                        _buildVisitRow(Icons.payments_outlined, 'Fees & Access', destination.feeInfoText),
                        const Divider(height: 16),
                        _buildVisitRow(
                          Icons.verified_outlined,
                          'Access Status',
                          destination.accessState == 'OPEN' ? 'Open & Accessible' : destination.accessState,
                          valueColor: destination.accessState == 'OPEN' ? TraverzaColors.emeraldSuccess : TraverzaColors.amberWarning,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Story & Cultural Significance
                  _buildSectionHeader('Story & Heritage', Icons.menu_book_rounded),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TraverzaColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: TraverzaColors.border),
                    ),
                    child: Text(
                      destination.story,
                      style: const TextStyle(fontSize: 13, height: 1.5, color: TraverzaColors.text),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Safety, Terrain & Accessibility
                  _buildSectionHeader('Terrain & Safety Guidance', Icons.shield_outlined),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TraverzaColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: TraverzaColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildVisitRow(Icons.terrain_rounded, 'Terrain', destination.terrainNotes),
                        const Divider(height: 16),
                        _buildVisitRow(Icons.warning_amber_rounded, 'Safety Notes', destination.safetyNotes),
                        const Divider(height: 16),
                        _buildVisitRow(
                          Icons.family_restroom_rounded,
                          'Family Suitability',
                          destination.isFamilyFriendly ? 'Suitable for families' : 'Moderate caution advised',
                        ),
                        const Divider(height: 16),
                        _buildVisitRow(Icons.accessible_rounded, 'Accessibility', destination.accessibilityNotes),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Evidence & Verification Box (Section 6 & 12 Non-Negotiable Rule)
                  _buildSectionHeader('Evidence & Truth Standard', Icons.fact_check_outlined),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.verified_rounded, size: 16, color: TraverzaColors.emeraldSuccess),
                            SizedBox(width: 8),
                            Text(
                              'SLTDA Verified Travel Record',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF065F46)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Source: ${destination.evidenceSource}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF047857)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Last Verified: ${destination.lastVerifiedAt.year}-${destination.lastVerifiedAt.month.toString().padLeft(2, '0')}-${destination.lastVerifiedAt.day.toString().padLeft(2, '0')} • Review Status: ${destination.reviewStatus}',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF047857)),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => _showCorrectionDialog(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF059669)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFF059669)),
                          label: const Text('Suggest an Update / Report Error', style: TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${destination.name} added to your draft trip!'),
                                backgroundColor: TraverzaColors.primary,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TraverzaColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                          label: const Text('Add to My Trip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: TraverzaColors.secondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: TraverzaColors.text),
        ),
      ],
    );
  }

  Widget _buildVisitRow(IconData icon, String title, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: TraverzaColors.secondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? TraverzaColors.text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCorrectionDialog(BuildContext context) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Submit Verified Correction', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Place: ${destination.name}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text(
              'Your report will enter moderation by the District Curator. We do not publish unverified crowd-sourced edits automatically.',
              style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Correction Details',
                hintText: 'e.g. Updated opening hours or road condition...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you! Your correction has been submitted for editorial moderation.'),
                  backgroundColor: TraverzaColors.emeraldSuccess,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: TraverzaColors.primary, foregroundColor: Colors.white),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
