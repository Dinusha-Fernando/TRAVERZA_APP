import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../services/island_atlas_service.dart';

class DistrictDayPlanSheet extends StatefulWidget {
  final String districtId;

  const DistrictDayPlanSheet({
    super.key,
    required this.districtId,
  });

  static Future<void> show(BuildContext context, String districtId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DistrictDayPlanSheet(districtId: districtId),
    );
  }

  @override
  State<DistrictDayPlanSheet> createState() => _DistrictDayPlanSheetState();
}

class _DistrictDayPlanSheetState extends State<DistrictDayPlanSheet> {
  int _availableHours = 8;
  final Set<String> _selectedInterests = {'HERITAGE', 'NATURE'};
  Map<String, dynamic>? _generatedPlan;

  @override
  void initState() {
    super.initState();
    _recalculatePlan();
  }

  void _recalculatePlan() {
    final plan = IslandAtlasService().buildDistrictDayPlan(
      districtId: widget.districtId,
      availableHours: _availableHours,
      interests: _selectedInterests.toList(),
    );
    setState(() {
      _generatedPlan = plan;
    });
  }

  @override
  Widget build(BuildContext context) {
    final plan = _generatedPlan;
    final district = IslandAtlasService().getDistrictById(widget.districtId);
    final districtName = district?.name ?? 'District';

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: TraverzaColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Sheet Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TraverzaColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TraverzaColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome, color: TraverzaColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Build a Day in $districtName',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TraverzaColors.text),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Text(
                            'TripGraph validated timing & buffer feasibility',
                            style: TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Content Body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Duration & Preferences
                    const Text('Available Time Budget', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TraverzaColors.textMuted)),
                    const SizedBox(height: 8),
                    Row(
                      children: [4, 6, 8, 10].map((hours) {
                        final isSelected = _availableHours == hours;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text('$hours Hours', style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                              selected: isSelected,
                              selectedColor: TraverzaColors.primary.withValues(alpha: 0.15),
                              onSelected: (_) {
                                setState(() => _availableHours = hours);
                                _recalculatePlan();
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Feasibility Status Banner
                    if (plan != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: plan['feasibility'] == 'FEASIBLE'
                              ? const Color(0x1A10B981)
                              : const Color(0x1AF59E0B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: plan['feasibility'] == 'FEASIBLE'
                                ? TraverzaColors.emeraldSuccess
                                : TraverzaColors.amberWarning,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              plan['feasibility'] == 'FEASIBLE' ? Icons.check_circle_rounded : Icons.info_outline,
                              color: plan['feasibility'] == 'FEASIBLE'
                                  ? TraverzaColors.emeraldSuccess
                                  : TraverzaColors.amberWarning,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan['feasibility'] == 'FEASIBLE'
                                        ? 'TripGraph Feasibility: Verified Pass'
                                        : 'TripGraph: Tight Road Buffers',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: plan['feasibility'] == 'FEASIBLE'
                                          ? const Color(0xFF059669)
                                          : const Color(0xFFD97706),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Estimated duration: ${(plan['totalDurationMins'] / 60.0).toStringAsFixed(1)}h with road travel buffers.',
                                    style: const TextStyle(fontSize: 11, color: TraverzaColors.text),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sequenced Timeline Stops
                      const Text('Sequenced Day Itinerary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TraverzaColors.text)),
                      const SizedBox(height: 12),
                      ...(plan['stops'] as List<dynamic>).map((stop) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: TraverzaColors.background,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: TraverzaColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: TraverzaColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${stop['order']}',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stop['name'] as String,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: TraverzaColors.text),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          Text(
                                            '${stop['arrival']} - ${stop['departure']} (${stop['dwellMins']}m dwell)',
                                            style: const TextStyle(fontSize: 11, color: TraverzaColors.secondary, fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            '• ${stop['fee']}',
                                            style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
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
                      }),
                    ],

                    const SizedBox(height: 20),
                    // Add Plan Action Button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$districtName Day Plan added to your draft itinerary!'),
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
                      icon: const Icon(Icons.add_task_rounded, size: 18),
                      label: const Text('Add Plan to My Trip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
