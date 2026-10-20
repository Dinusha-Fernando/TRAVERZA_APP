import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/maps_launcher.dart';

class TripStopCard extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;
  final String category;
  final String status;
  final IconData icon;
  final Color iconColor;
  final String? price;
  final double? latitude;
  final double? longitude;
  final String? warningNote;
  final VoidCallback? onDetailsTap;

  const TripStopCard({
    super.key,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.status,
    required this.icon,
    required this.iconColor,
    this.price,
    this.latitude,
    this.longitude,
    this.warningNote,
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeBg = Colors.grey.withValues(alpha: 0.15);
    Color badgeTextColor = Colors.grey;
    String badgeLabel = status;

    if (status == 'CONFIRMED') {
      badgeBg = TraverzaColors.emeraldSuccess.withValues(alpha: 0.15);
      badgeTextColor = TraverzaColors.emeraldSuccess;
      badgeLabel = 'Confirmed';
    } else if (status == 'REQUEST_SUBMITTED') {
      badgeBg = TraverzaColors.amberWarning.withValues(alpha: 0.15);
      badgeTextColor = TraverzaColors.amberWarning;
      badgeLabel = 'Request Pending';
    } else if (status == 'ESTIMATED') {
      badgeBg = TraverzaColors.accent.withValues(alpha: 0.15);
      badgeTextColor = TraverzaColors.accent;
      badgeLabel = 'Estimated';
    } else if (status == 'NONE') {
      badgeBg = Colors.blue.withValues(alpha: 0.15);
      badgeTextColor = Colors.blue;
      badgeLabel = 'Transit / Arrival';
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: TraverzaColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 12,
                              color: TraverzaColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badgeLabel,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: badgeTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: TraverzaColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: TraverzaColors.textMuted,
                height: 1.3,
              ),
            ),
            if (warningNote != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TraverzaColors.amberWarning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: TraverzaColors.amberWarning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 14, color: TraverzaColors.amberWarning),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        warningNote!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: TraverzaColors.text,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(color: TraverzaColors.border, height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (price != null)
                  Text(
                    price!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: TraverzaColors.text,
                    ),
                  )
                else
                  const Text(
                    'Included in Package / Schedule',
                    style: TextStyle(
                      fontSize: 11,
                      color: TraverzaColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                Row(
                  children: [
                    if (latitude != null && longitude != null)
                      InkWell(
                        onTap: () {
                          TraverzaMapsLauncher.openDirections(
                            destinationLat: latitude!,
                            destinationLng: longitude!,
                            destinationName: title,
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: TraverzaColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: TraverzaColors.secondary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.directions_rounded, size: 14, color: TraverzaColors.secondary),
                              SizedBox(width: 4),
                              Text(
                                'Google Maps Navigation',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: TraverzaColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.more_horiz, size: 18, color: TraverzaColors.textMuted),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onDetailsTap,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
