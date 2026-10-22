import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../models/community_models.dart';

class PlaceSignalCard extends StatelessWidget {
  final PlaceSignalModel signal;
  final VoidCallback? onAskTapped;
  final VoidCallback? onReportTapped;

  const PlaceSignalCard({
    super.key,
    required this.signal,
    this.onAskTapped,
    this.onReportTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Header row with freshness pulse
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: TraverzaColors.emeraldSuccess,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'PLACE SIGNAL · LIVE COMMUNITY PULSE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: TraverzaColors.secondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  signal.freshnessStatus,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: TraverzaColors.emeraldSuccess,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Latest observation quote
          if (signal.latestObservation != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: TraverzaColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: TraverzaColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote_rounded, size: 16, color: TraverzaColors.secondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      signal.latestObservation!,
                      style: const TextStyle(fontSize: 11.5, color: TraverzaColors.text, height: 1.35),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Metrics Pills
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildMetricPill(
                icon: Icons.directions_walk_rounded,
                label: 'Trail: ${signal.trailOrRoadStatus.replaceAll('_', ' ')}',
                color: TraverzaColors.emeraldSuccess,
              ),
              _buildMetricPill(
                icon: Icons.groups_rounded,
                label: 'Crowd: ${signal.crowdLevel.replaceAll('_', ' ')}',
                color: TraverzaColors.secondary,
              ),
              _buildMetricPill(
                icon: Icons.help_outline_rounded,
                label: '${signal.unansweredQuestionsCount} Questions',
                color: TraverzaColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
