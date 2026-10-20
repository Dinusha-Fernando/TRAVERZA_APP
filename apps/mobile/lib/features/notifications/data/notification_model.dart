import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

enum NotificationCategory {
  all,
  safety,
  booking,
  trip,
  offers,
}

extension NotificationCategoryExtension on NotificationCategory {
  String get label {
    switch (this) {
      case NotificationCategory.all:
        return 'All';
      case NotificationCategory.safety:
        return 'Safety & Alerts';
      case NotificationCategory.booking:
        return 'Bookings';
      case NotificationCategory.trip:
        return 'Trip & Route';
      case NotificationCategory.offers:
        return 'Perks & Offers';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationCategory.all:
        return Icons.notifications_rounded;
      case NotificationCategory.safety:
        return Icons.shield_rounded;
      case NotificationCategory.booking:
        return Icons.confirmation_number_rounded;
      case NotificationCategory.trip:
        return Icons.alt_route_rounded;
      case NotificationCategory.offers:
        return Icons.local_offer_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotificationCategory.all:
        return TraverzaColors.primary;
      case NotificationCategory.safety:
        return TraverzaColors.roseEmergency;
      case NotificationCategory.booking:
        return TraverzaColors.secondary;
      case NotificationCategory.trip:
        return const Color(0xFF0F4C75);
      case NotificationCategory.offers:
        return TraverzaColors.amberWarning;
    }
  }
}

class TraverzaNotification {
  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final DateTime timestamp;
  bool isRead;
  final String? actionRoute; // 'plan', 'bookings', 'safety', 'saved'
  final String? actionLabel;
  final String priority; // 'high', 'medium', 'low'

  TraverzaNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
    this.actionLabel,
    this.priority = 'medium',
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  TraverzaNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationCategory? category,
    DateTime? timestamp,
    bool? isRead,
    String? actionRoute,
    String? actionLabel,
    String? priority,
  }) {
    return TraverzaNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
      actionLabel: actionLabel ?? this.actionLabel,
      priority: priority ?? this.priority,
    );
  }

  /// Default baseline corridor notifications for TRAVERZA Sri Lanka
  static List<TraverzaNotification> get initialNotifications => [
        TraverzaNotification(
          id: 'NOTIF-LK-001',
          title: 'Kandy → Nuwara Eliya Hairpin Roadwork',
          body: '+30 min scenic buffer recommended due to road resurfacing near Ramboda Falls. Chauffeur notified.',
          category: NotificationCategory.safety,
          timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
          isRead: false,
          actionRoute: 'plan',
          actionLabel: 'Review Buffers',
          priority: 'high',
        ),
        TraverzaNotification(
          id: 'NOTIF-LK-002',
          title: 'Booking Request Received: Sigiriya Eco Villa',
          body: 'Provider has a 12h SLA response deadline to confirm. Direct reservation tracking active.',
          category: NotificationCategory.booking,
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
          isRead: false,
          actionRoute: 'bookings',
          actionLabel: 'Track SLA',
          priority: 'medium',
        ),
        TraverzaNotification(
          id: 'NOTIF-LK-003',
          title: 'SLTDA Biometric Pass Activated',
          body: 'Universal check-in token #TRV-LK-9041-INTL is active for express hotel & national park entry.',
          category: NotificationCategory.trip,
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          isRead: true,
          actionRoute: 'safety',
          actionLabel: 'View Pass',
          priority: 'medium',
        ),
        TraverzaNotification(
          id: 'NOTIF-LK-004',
          title: 'Lion Rock Sunrise Climb Privilege',
          body: 'Early gate pass available for registered pilot members at 06:30 AM before peak heat.',
          category: NotificationCategory.offers,
          timestamp: DateTime.now().subtract(const Duration(hours: 8)),
          isRead: true,
          actionRoute: 'plan',
          actionLabel: 'Explore',
          priority: 'low',
        ),
      ];
}
