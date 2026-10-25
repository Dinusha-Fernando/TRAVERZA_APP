import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../data/notification_model.dart';
import '../../services/notification_service.dart';

/// Modal for inspecting full corridor notification details, payload metadata, and taking direct route action
class NotificationDetailSheet extends StatelessWidget {
  final TraverzaNotification notification;
  final ValueChanged<String> onNavigate;

  const NotificationDetailSheet({
    super.key,
    required this.notification,
    required this.onNavigate,
  });

  static Future<void> show(
    BuildContext context, {
    required TraverzaNotification notification,
    required ValueChanged<String> onNavigate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationDetailSheet(
        notification: notification,
        onNavigate: onNavigate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cat = notification.category;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: const BoxDecoration(
        color: TraverzaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: TraverzaColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Category & Priority Row
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cat.color.withValues(alpha: 0.3)),
                ),
                child: Icon(cat.icon, color: cat.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: cat.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            cat.label.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: cat.color,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: notification.priorityColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            notification.priority.toUpperCase(),
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              color: notification.priorityColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${notification.timeAgo} · ${notification.timestamp.hour.toString().padLeft(2, '0')}:${notification.timestamp.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 11, color: TraverzaColors.textMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: TraverzaColors.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            notification.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: TraverzaColors.text,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),

          // Body Message
          Text(
            notification.body,
            style: const TextStyle(
              fontSize: 13,
              color: TraverzaColors.text,
              height: 1.45,
            ),
          ),

          // Metadata Card (Corridor / Source telemetry)
          if (notification.subtitle != null || notification.payload != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TraverzaColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TraverzaColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.info_outline_rounded, size: 14, color: TraverzaColors.secondary),
                      SizedBox(width: 6),
                      Text(
                        'CORRIDOR TELEMETRY & DISPATCH METADATA',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: TraverzaColors.secondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  if (notification.subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      notification.subtitle!,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: TraverzaColors.text),
                    ),
                  ],
                  if (notification.payload != null) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: notification.payload!.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: TraverzaColors.surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: TraverzaColors.border),
                          ),
                          child: Text(
                            '${entry.key}: ${entry.value}',
                            style: const TextStyle(fontSize: 10, color: TraverzaColors.textMuted),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Primary Route Action Button
          if (notification.actionLabel != null && notification.actionRoute != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  TraverzaNotificationService.instance.markAsRead(notification.id);
                  TraverzaNotificationService.instance.deleteNotification(notification.id);
                  Navigator.pop(context); // pop detail
                  onNavigate(notification.actionRoute!);
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: Text(notification.actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TraverzaColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Secondary Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  if (notification.isRead) {
                    TraverzaNotificationService.instance.markAsUnread(notification.id);
                  } else {
                    TraverzaNotificationService.instance.markAsRead(notification.id);
                  }
                  Navigator.pop(context);
                },
                icon: Icon(
                  notification.isRead ? Icons.mark_email_unread_rounded : Icons.mark_email_read_rounded,
                  size: 16,
                  color: TraverzaColors.secondary,
                ),
                label: Text(
                  notification.isRead ? 'Mark as Unread' : 'Mark as Read',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TraverzaColors.secondary),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  TraverzaNotificationService.instance.deleteNotification(notification.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Deleted: ${notification.title}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: TraverzaColors.roseEmergency),
                label: const Text(
                  'Delete Alert',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TraverzaColors.roseEmergency),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
