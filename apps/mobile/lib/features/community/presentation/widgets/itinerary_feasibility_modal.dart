import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../models/community_models.dart';
import '../../services/community_service.dart';

class ItineraryFeasibilityModal extends StatefulWidget {
  final CommunityPostModel post;

  const ItineraryFeasibilityModal({
    super.key,
    required this.post,
  });

  static Future<void> show(BuildContext context, CommunityPostModel post) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ItineraryFeasibilityModal(post: post),
    );
  }

  @override
  State<ItineraryFeasibilityModal> createState() => _ItineraryFeasibilityModalState();
}

class _ItineraryFeasibilityModalState extends State<ItineraryFeasibilityModal> {
  int _selectedDay = 1;
  int _selectedHour = 10;
  late ItineraryAdditionValidationResult _result;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    _result = CommunityService.instance.validateItineraryAddition(
      destinationName: widget.post.destinationName ?? 'Selected Landmark',
      dayNumber: _selectedDay,
      requestedStartHour: _selectedHour,
      dwellDurationMins: 90,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: TraverzaColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TraverzaColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.alt_route_rounded, color: TraverzaColors.secondary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TripGraph Feasibility Check',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TraverzaColors.primary,
                      ),
                    ),
                    Text(
                      widget.post.destinationName ?? 'Landmark Stop',
                      style: const TextStyle(fontSize: 12, color: TraverzaColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Day Selector
          const Text('Target Itinerary Day', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.textMuted)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [1, 2, 3, 4].map((d) {
                final isSel = _selectedDay == d;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() {
                      _selectedDay = d;
                      _recalculate();
                    }),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSel ? TraverzaColors.primary : TraverzaColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSel ? TraverzaColors.primary : TraverzaColors.border),
                      ),
                      child: Text(
                        'Day $d',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSel ? Colors.white : TraverzaColors.text,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Arrival Time Selector
          const Text('Proposed Arrival Time', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.textMuted)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [9, 11, 14, 17].map((h) {
                final isSel = _selectedHour == h;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() {
                      _selectedHour = h;
                      _recalculate();
                    }),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSel ? TraverzaColors.secondary : TraverzaColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSel ? TraverzaColors.secondary : TraverzaColors.border),
                      ),
                      child: Text(
                        '${h.toString().padLeft(2, '0')}:00',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSel ? Colors.white : TraverzaColors.text,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Validation Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _result.isFeasible
                  ? TraverzaColors.emeraldSuccess.withValues(alpha: 0.08)
                  : TraverzaColors.roseEmergency.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _result.isFeasible ? TraverzaColors.emeraldSuccess : TraverzaColors.roseEmergency,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _result.isFeasible ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                      color: _result.isFeasible ? TraverzaColors.emeraldSuccess : TraverzaColors.roseEmergency,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _result.isFeasible ? 'TripGraph Validated: Feasible' : 'Itinerary Conflict Detected',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _result.isFeasible ? TraverzaColors.emeraldSuccess : TraverzaColors.roseEmergency,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _result.recommendation,
                  style: const TextStyle(fontSize: 12, color: TraverzaColors.text, height: 1.4),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  children: [
                    Text('Transit: ${_result.transitDurationMins}m', style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted)),
                    Text('Road Buffer: +${_result.roadBufferMins}m', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TraverzaColors.secondary)),
                    Text('Window: ${_result.proposedStartTime} - ${_result.proposedEndTime}', style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added "${widget.post.destinationName}" to Day $_selectedDay itinerary!'),
                    backgroundColor: TraverzaColors.emeraldSuccess,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TraverzaColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Confirm & Insert Draft Stop into Trip Canvas',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
