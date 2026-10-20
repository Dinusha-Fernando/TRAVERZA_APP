import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ActiveTripSummaryCard extends StatelessWidget {
  final bool isHotelConfirmed;
  final VoidCallback onToggleSimulation;
  final VoidCallback? onOpenCanvas;
  final VoidCallback? onOpenReadiness;

  const ActiveTripSummaryCard({
    super.key,
    required this.isHotelConfirmed,
    required this.onToggleSimulation,
    this.onOpenCanvas,
    this.onOpenReadiness,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = isHotelConfirmed
        ? 'Fully Confirmed (3/3)'
        : 'Partially Confirmed (2/3)';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TraverzaColors.border),
        boxShadow: [
          BoxShadow(
            color: TraverzaColors.primary.withValues(alpha: 0.05),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: TraverzaColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.alt_route, color: TraverzaColors.secondary, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Trip Timeline',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TraverzaColors.text,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isHotelConfirmed
                      ? const Color(0x2610B981)
                      : const Color(0x26F59E0B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isHotelConfirmed
                        ? TraverzaColors.emeraldSuccess
                        : TraverzaColors.amberWarning,
                    width: 1,
                  ),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: isHotelConfirmed
                        ? const Color(0xFF10B981)
                        : const Color(0xFFD97706),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Text(
                'ID: TRIP-LK-2026-9041',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: TraverzaColors.secondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Colombo - Sigiriya - Kandy - Nuwara Eliya (3 Days)',
            style: TextStyle(
              color: TraverzaColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.people_alt_outlined, size: 15, color: TraverzaColors.secondary),
              SizedBox(width: 5),
              Text(
                '2 Travellers',
                style: TextStyle(color: TraverzaColors.textMuted, fontSize: 12),
              ),
              SizedBox(width: 16),
              Icon(Icons.payments_outlined, size: 15, color: TraverzaColors.secondary),
              SizedBox(width: 5),
              Text(
                'LKR 68,500 Total',
                style: TextStyle(color: TraverzaColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 16),
              Icon(Icons.verified_outlined, size: 15, color: TraverzaColors.emeraldSuccess),
              SizedBox(width: 4),
              Text(
                'SLTDA Protected',
                style: TextStyle(color: TraverzaColors.emeraldSuccess, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onOpenCanvas,
                  icon: const Icon(Icons.map_outlined, size: 16, color: Colors.white),
                  label: const Text('Open Trip Canvas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TraverzaColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: onOpenReadiness,
                icon: const Icon(Icons.check_circle_outline, size: 16, color: TraverzaColors.secondary),
                label: const Text('Readiness', style: TextStyle(color: TraverzaColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: TraverzaColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
