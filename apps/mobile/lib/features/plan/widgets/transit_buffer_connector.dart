import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class TransitBufferConnector extends StatelessWidget {
  final String duration;
  final String note;
  final IconData icon;

  const TransitBufferConnector({
    super.key,
    required this.duration,
    required this.note,
    this.icon = Icons.hourglass_empty_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 36,
            color: TraverzaColors.secondary.withValues(alpha: 0.35),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: TraverzaColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: TraverzaColors.secondary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 14, color: TraverzaColors.secondary),
                  const SizedBox(width: 8),
                  Text(
                    duration,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: TraverzaColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '•  $note',
                      style: const TextStyle(
                        fontSize: 10,
                        color: TraverzaColors.textMuted,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
