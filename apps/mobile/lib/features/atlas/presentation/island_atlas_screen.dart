import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/atlas_models.dart';
import '../services/island_atlas_service.dart';
import 'destination_details_screen.dart';
import 'district_overview_screen.dart';
import 'district_passport_screen.dart';

class IslandAtlasScreen extends StatefulWidget {
  const IslandAtlasScreen({super.key});

  @override
  State<IslandAtlasScreen> createState() => _IslandAtlasScreenState();
}

class _IslandAtlasScreenState extends State<IslandAtlasScreen> {
  final IslandAtlasService _service = IslandAtlasService();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedProvinceId;
  String? _selectedDistrictId;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provinces = _service.provinces;
    final districts = _selectedProvinceId != null
        ? _service.getDistrictsForProvince(_selectedProvinceId!)
        : _service.districts;
    final collections = _service.collections;
    final destinations = _service.searchDestinations(
      query: _searchQuery,
      districtId: _selectedDistrictId,
    );

    return Scaffold(
      backgroundColor: TraverzaColors.background,
      appBar: AppBar(
        title: const Text(
          'TRAVERZA Island Atlas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: TraverzaColors.surface,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_rounded, color: TraverzaColors.primary),
            tooltip: 'District Passport',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DistrictPassportScreen()),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Search & Multi-lingual Input Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: TraverzaColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TraverzaColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search places, districts, Sinhala / Tamil names...',
                    hintStyle: const TextStyle(fontSize: 13, color: TraverzaColors.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded, color: TraverzaColors.primary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
          ),

          // District Passport Tracker Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ValueListenableBuilder<List<DistrictPassportStamp>>(
                valueListenable: _service.passportStampsNotifier,
                builder: (context, stamps, _) {
                  final stamped = stamps.where((s) => s.isStamped).length;
                  final total = stamps.length;
                  final percent = (stamped / total * 100).toInt();

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DistrictPassportScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F3B57), Color(0xFF0B2138)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: TraverzaColors.lagoonTeal.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.military_tech_rounded, color: TraverzaColors.lagoonTeal, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DISTRICT PASSPORT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                    color: TraverzaColors.lagoonTeal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$stamped of $total Districts Explored ($percent%)',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 9 Provinces Visual Carousel Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nine Official Provinces',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                  ),
                  if (_selectedProvinceId != null)
                    TextButton(
                      onPressed: () => setState(() => _selectedProvinceId = null),
                      child: const Text('Show All', style: TextStyle(fontSize: 12, color: TraverzaColors.primary)),
                    ),
                ],
              ),
            ),
          ),

          // 9 Provinces Horizontal Rail
          SliverToBoxAdapter(
            child: SizedBox(
              height: 165,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: provinces.length,
                itemBuilder: (context, index) {
                  final prov = provinces[index];
                  final isSelected = _selectedProvinceId == prov.id;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedProvinceId = isSelected ? null : prov.id;
                          _selectedDistrictId = null;
                        });
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: 155,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? TraverzaColors.primary : Colors.black.withValues(alpha: 0.1),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(17),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                prov.coverImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: const Color(0xFF0F3B57),
                                  child: const Center(child: Icon(Icons.landscape_rounded, color: Colors.white24)),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.4),
                                      const Color(0xFF0B1728).withValues(alpha: 0.95),
                                    ],
                                    stops: const [0.0, 0.4, 1.0],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prov.nameSi,
                                      style: const TextStyle(fontSize: 10, color: TraverzaColors.warmSand, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      prov.name,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${prov.districtCount} Districts • ${prov.publishedPlacesCount} Places',
                                      style: const TextStyle(fontSize: 9.5, color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 25 Districts Quick Selector Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: Text(
                _selectedProvinceId != null
                    ? 'Districts in ${_service.getProvinceById(_selectedProvinceId!)?.name} (${districts.length})'
                    : 'All 25 Administrative Districts',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: districts.length,
                itemBuilder: (context, index) {
                  final dist = districts[index];
                  final isSelected = _selectedDistrictId == dist.id;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(
                        dist.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? TraverzaColors.primary : TraverzaColors.text,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: TraverzaColors.primary.withValues(alpha: 0.15),
                      checkmarkColor: TraverzaColors.primary,
                      onSelected: (val) {
                        setState(() {
                          _selectedDistrictId = val ? dist.id : null;
                        });
                      },
                      avatar: CircleAvatar(
                        radius: 8,
                        backgroundColor: TraverzaColors.secondary.withValues(alpha: 0.2),
                        child: Text(
                          dist.provinceId,
                          style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Curated Collections Rail
          if (_searchQuery.isEmpty && _selectedDistrictId == null) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                child: const Text(
                  'Curated Island Themes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final col = collections[index];
                    return Container(
                      width: 220,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              col.coverImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF0F3B57)),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, const Color(0xFF071424).withValues(alpha: 0.9)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    col.theme,
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: TraverzaColors.lagoonTeal),
                                  ),
                                  Text(
                                    col.title,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    col.subtitle,
                                    style: const TextStyle(fontSize: 10, color: TraverzaColors.warmSand),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          // Verified Places Feed Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Verified Places (${destinations.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                  ),
                  if (_selectedDistrictId != null)
                    TextButton(
                      onPressed: () {
                        final dist = _service.getDistrictById(_selectedDistrictId!);
                        if (dist != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DistrictOverviewScreen(districtId: dist.id)),
                          );
                        }
                      },
                      child: const Text('Open District Hub', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TraverzaColors.primary)),
                    ),
                ],
              ),
            ),
          ),

          // Destinations List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final dest = destinations[index];
                  final dist = _service.getDistrictById(dest.districtId);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DestinationDetailsScreen(destination: dest)),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: TraverzaColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: TraverzaColors.border),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: Image.network(
                                  dest.photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: const Color(0xFF0F3B57),
                                    child: const Icon(Icons.landscape_rounded, color: Colors.white24),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 6,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        dest.category,
                                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                                      ),
                                      const Text('•', style: TextStyle(color: TraverzaColors.textMuted)),
                                      Text(
                                        dist?.name ?? dest.districtId,
                                        style: const TextStyle(fontSize: 10, color: TraverzaColors.textMuted),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    dest.name,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    dest.summary,
                                    style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted, height: 1.2),
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
                },
                childCount: destinations.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
