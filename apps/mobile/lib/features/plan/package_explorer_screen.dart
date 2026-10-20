import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'data/package_model.dart';
import 'package_details_screen.dart';
import 'widgets/package_offer_card.dart';

class PackageExplorerScreen extends StatefulWidget {
  final VoidCallback onBackToHub;
  final Function(TraverzaPackage package) onCustomizePackage;

  const PackageExplorerScreen({
    super.key,
    required this.onBackToHub,
    required this.onCustomizePackage,
  });

  @override
  State<PackageExplorerScreen> createState() => _PackageExplorerScreenState();
}

class _PackageExplorerScreenState extends State<PackageExplorerScreen> {
  final List<TraverzaPackage> _allPackages = TraverzaPackage.getCuratedPackages();
  int _selectedTypeIndex = 0; // 0: All, 1: Operator Packages, 2: Itinerary Templates
  String _searchQuery = '';
  final Set<String> _selectedForComparison = {};

  List<TraverzaPackage> get _filteredPackages {
    return _allPackages.where((pkg) {
      if (_selectedTypeIndex == 1 && !pkg.isOperatorPackage) return false;
      if (_selectedTypeIndex == 2 && pkg.isOperatorPackage) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = pkg.title.toLowerCase().contains(query);
        final matchCorridor = pkg.corridorName.toLowerCase().contains(query);
        final matchProvider = pkg.providerName.toLowerCase().contains(query);
        if (!matchTitle && !matchCorridor && !matchProvider) return false;
      }
      return true;
    }).toList();
  }

  void _showCompareModal() {
    final packagesToCompare = _allPackages.where((p) => _selectedForComparison.contains(p.id)).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: TraverzaColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Package Comparison',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Text(
              'Side-by-side comparison of operator terms, transport & stays',
              style: TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: packagesToCompare.map((pkg) {
                  return Container(
                    width: 260,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TraverzaColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: TraverzaColors.border),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pkg.isOperatorPackage ? 'OPERATOR BUNDLE' : 'ITINERARY TEMPLATE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: pkg.isOperatorPackage ? TraverzaColors.primary : TraverzaColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            pkg.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'LKR ${pkg.basePriceLkr.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TraverzaColors.primary),
                          ),
                          Text(
                            pkg.priceBasis,
                            style: const TextStyle(fontSize: 10, color: TraverzaColors.textMuted),
                          ),
                          const Divider(height: 20),
                          const Text('Duration:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          Text('${pkg.durationDays} Days / ${pkg.durationNights} Nights', style: const TextStyle(fontSize: 11.5)),
                          const SizedBox(height: 8),
                          const Text('Corridor:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          Text(pkg.corridorName, style: const TextStyle(fontSize: 11.5)),
                          const SizedBox(height: 8),
                          const Text('Provider:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          Text('${pkg.providerName}\n${pkg.sltdaLicenseNo}', style: const TextStyle(fontSize: 11.5)),
                          const SizedBox(height: 8),
                          const Text('Key Inclusions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          Text(pkg.inclusions.join('\n• '), style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted)),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TraverzaColors.secondary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                widget.onCustomizePackage(pkg);
                              },
                              child: const Text('Customize', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TraverzaColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TraverzaColors.text),
          onPressed: widget.onBackToHub,
        ),
        title: const Text(
          'Packages Marketplace',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: TraverzaColors.text),
        ),
        actions: [
          if (_selectedForComparison.length >= 2)
            TextButton.icon(
              onPressed: _showCompareModal,
              icon: const Icon(Icons.compare_arrows, size: 16, color: TraverzaColors.secondary),
              label: Text(
                'Compare (${_selectedForComparison.length})',
                style: const TextStyle(color: TraverzaColors.secondary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: TraverzaColors.surface,
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search corridors, destinations or agencies...',
                    hintStyle: const TextStyle(fontSize: 12.5, color: TraverzaColors.textMuted),
                    prefixIcon: const Icon(Icons.search, color: TraverzaColors.secondary, size: 20),
                    filled: true,
                    fillColor: TraverzaColors.background,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: TraverzaColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: TraverzaColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildFilterChip('All Packages', 0),
                    const SizedBox(width: 8),
                    _buildFilterChip('Operator Bundles', 1),
                    const SizedBox(width: 8),
                    _buildFilterChip('Route Templates', 2),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: TraverzaColors.border),

          // Compare instructions banner if selecting
          if (_selectedForComparison.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: TraverzaColors.sand.withValues(alpha: 0.4),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 15, color: TraverzaColors.text),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedForComparison.length} selected for comparison (Select up to 3)',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: TraverzaColors.text),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _selectedForComparison.clear()),
                    child: const Text('Clear', style: TextStyle(fontSize: 11.5, color: TraverzaColors.roseEmergency, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

          // Packages Feed
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _filteredPackages.length,
              itemBuilder: (context, index) {
                final pkg = _filteredPackages[index];
                final isSelected = _selectedForComparison.contains(pkg.id);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Stack(
                    children: [
                      PackageOfferCard(
                        package: pkg,
                        cardWidth: double.infinity,
                        onTap: () {
                          PackageDetailsScreen.show(
                            context,
                            package: pkg,
                            onCustomize: () => widget.onCustomizePackage(pkg),
                          );
                        },
                        onCustomize: () => widget.onCustomizePackage(pkg),
                        onBook: pkg.isOperatorPackage
                            ? () {
                                PackageDetailsScreen.show(
                                  context,
                                  package: pkg,
                                  onCustomize: () => widget.onCustomizePackage(pkg),
                                );
                              }
                            : null,
                      ),
                      Positioned(
                        right: 8,
                        top: 10,
                        child: IconButton(
                          icon: Icon(
                            isSelected ? Icons.check_circle : Icons.add_circle_outline,
                            color: isSelected ? TraverzaColors.secondary : TraverzaColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              if (isSelected) {
                                _selectedForComparison.remove(pkg.id);
                              } else if (_selectedForComparison.length < 3) {
                                _selectedForComparison.add(pkg.id);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Maximum 3 packages can be compared simultaneously'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedTypeIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTypeIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? TraverzaColors.primary : TraverzaColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? TraverzaColors.primary : TraverzaColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : TraverzaColors.text,
          ),
        ),
      ),
    );
  }
}
