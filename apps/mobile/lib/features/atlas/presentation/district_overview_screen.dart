import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/atlas_models.dart';
import '../services/island_atlas_service.dart';
import 'destination_details_screen.dart';
import 'district_day_plan_sheet.dart';

class DistrictOverviewScreen extends StatefulWidget {
  final String districtId;

  const DistrictOverviewScreen({
    super.key,
    required this.districtId,
  });

  @override
  State<DistrictOverviewScreen> createState() => _DistrictOverviewScreenState();
}

class _DistrictOverviewScreenState extends State<DistrictOverviewScreen> {
  final String _selectedCategory = 'ALL';
  String _selectedPlaceType = 'ALL';

  @override
  Widget build(BuildContext context) {
    final service = IslandAtlasService();
    final district = service.getDistrictById(widget.districtId);
    if (district == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('District')),
        body: const Center(child: Text('District not found')),
      );
    }

    final province = service.getProvinceById(district.provinceId);
    final specialities = service.getSpecialitiesForDistrict(district.id);
    final places = service.searchDestinations(
      districtId: district.id,
      category: _selectedCategory,
      placeType: _selectedPlaceType,
    );

    return Scaffold(
      backgroundColor: TraverzaColors.background,
      appBar: AppBar(
        title: Text(district.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: TraverzaColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: TraverzaColors.primary),
            tooltip: 'Build Me a District Day',
            onPressed: () => DistrictDayPlanSheet.show(context, district.id),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // District Story Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: TraverzaColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: TraverzaColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: TraverzaColors.primary.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${province?.name ?? ''} • ${district.nameSi} • ${district.nameTa}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0x1A10B981),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'OFFICIAL 25-DISTRICT SCOPE',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      district.story,
                      style: const TextStyle(fontSize: 13, height: 1.4, color: TraverzaColors.text),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      children: [
                        const Icon(Icons.explore_outlined, size: 14, color: TraverzaColors.textMuted),
                        Text(
                          'Known for: ${district.knownFor}',
                          style: const TextStyle(fontSize: 11.5, color: TraverzaColors.textMuted, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // "What makes this district special?" Specialties Rail
          if (specialities.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'What Makes This District Special?',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  itemCount: specialities.length,
                  itemBuilder: (context, index) {
                    final spec = specialities[index];
                    return Container(
                      width: 240,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TraverzaColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: TraverzaColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: TraverzaColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              spec.themeGroup.replaceAll('_', ' '),
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: TraverzaColors.primary),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            spec.title,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            spec.description,
                            style: const TextStyle(fontSize: 10.5, color: TraverzaColors.textMuted, height: 1.2),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          // Filter Toolbar (Famous + Locally Loved)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Verified Places (${places.length})',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => DistrictDayPlanSheet.show(context, district.id),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: TraverzaColors.primary),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.auto_awesome, size: 14, color: TraverzaColors.primary),
                        label: const Text('Build Day Plan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('ALL', 'All Places', _selectedPlaceType == 'ALL', (val) {
                          setState(() => _selectedPlaceType = val ? 'ALL' : 'ALL');
                        }),
                        _buildFilterChip('iconic', 'Iconic Landmarks', _selectedPlaceType == 'iconic', (val) {
                          setState(() => _selectedPlaceType = val ? 'iconic' : 'ALL');
                        }),
                        _buildFilterChip('locally_loved', 'Locally Loved', _selectedPlaceType == 'locally_loved', (val) {
                          setState(() => _selectedPlaceType = val ? 'locally_loved' : 'ALL');
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Destination Cards List
          if (places.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No destinations matching this filter.\nMore local places are currently in editorial review.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: TraverzaColors.textMuted, fontSize: 13),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final place = places[index];
                    return _DestinationCard(
                      destination: place,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DestinationDetailsScreen(destination: place),
                          ),
                        );
                      },
                    );
                  },
                  childCount: places.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, bool isSelected, ValueChanged<bool> onSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        selected: isSelected,
        selectedColor: TraverzaColors.primary.withValues(alpha: 0.15),
        checkmarkColor: TraverzaColors.primary,
        onSelected: onSelected,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final DestinationModel destination;
  final VoidCallback onTap;

  const _DestinationCard({
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: TraverzaColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: TraverzaColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Thumbnail Header
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        destination.photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF0F3B57),
                          child: const Center(child: Icon(Icons.landscape_rounded, color: Colors.white24, size: 40)),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_outlined, size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                '${destination.dwellDurationMins}m',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Card Details
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          destination.category,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                        ),
                        const Text('•', style: TextStyle(color: TraverzaColors.textMuted)),
                        Text(
                          destination.feeInfoText,
                          style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destination.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      destination.summary,
                      style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
}
