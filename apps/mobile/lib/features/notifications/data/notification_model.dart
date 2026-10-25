import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

enum NotificationCategory {
  all,
  safety,
  booking,
  trip,
  autopilot,
  offers,
  messenger,
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
      case NotificationCategory.autopilot:
        return 'Autopilot & Disruptions';
      case NotificationCategory.offers:
        return 'Perks & Offers';
      case NotificationCategory.messenger:
        return 'Messages & Community';
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
      case NotificationCategory.autopilot:
        return Icons.bolt_rounded;
      case NotificationCategory.offers:
        return Icons.local_offer_rounded;
      case NotificationCategory.messenger:
        return Icons.forum_rounded;
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
      case NotificationCategory.autopilot:
        return const Color(0xFF0284C7);
      case NotificationCategory.offers:
        return TraverzaColors.amberWarning;
      case NotificationCategory.messenger:
        return const Color(0xFF8B5CF6);
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
  final String? actionRoute; // 'plan', 'bookings', 'safety', 'saved', 'command_center', 'messenger'
  final String? actionLabel;
  final String priority; // 'emergency', 'high', 'medium', 'low'
  final String? subtitle;
  final Map<String, dynamic>? payload;

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
    this.subtitle,
    this.payload,
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

  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'emergency':
      case 'critical':
        return TraverzaColors.roseEmergency;
      case 'high':
        return const Color(0xFFEA580C);
      case 'medium':
        return TraverzaColors.secondary;
      case 'low':
      default:
        return TraverzaColors.textMuted;
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
    String? subtitle,
    Map<String, dynamic>? payload,
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
      subtitle: subtitle ?? this.subtitle,
      payload: payload ?? this.payload,
    );
  }

  factory TraverzaNotification.fromJson(Map<String, dynamic> json) {
    NotificationCategory parsedCategory;
    final catRaw = (json['category'] as String? ?? '').toUpperCase();
    switch (catRaw) {
      case 'SAFETY':
        parsedCategory = NotificationCategory.safety;
        break;
      case 'BOOKING':
        parsedCategory = NotificationCategory.booking;
        break;
      case 'TRIP':
        parsedCategory = NotificationCategory.trip;
        break;
      case 'AUTOPILOT':
        parsedCategory = NotificationCategory.autopilot;
        break;
      case 'OFFERS':
        parsedCategory = NotificationCategory.offers;
        break;
      case 'MESSENGER':
        parsedCategory = NotificationCategory.messenger;
        break;
      default:
        parsedCategory = NotificationCategory.trip;
    }

    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['timestamp'] as String);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return TraverzaNotification(
      id: json['id'] as String? ?? 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Notification',
      body: json['body'] as String? ?? '',
      category: parsedCategory,
      timestamp: parsedDate,
      isRead: json['is_read'] as bool? ?? false,
      actionRoute: json['action_route'] as String?,
      actionLabel: json['action_label'] as String?,
      priority: json['priority'] as String? ?? 'medium',
      subtitle: json['subtitle'] as String?,
      payload: json['payload'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'category': category.name.toUpperCase(),
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'action_route': actionRoute,
      'action_label': actionLabel,
      'priority': priority,
      'subtitle': subtitle,
      'payload': payload,
    };
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
          subtitle: 'A5 Hill Highway · Ramboda Pass',
          payload: {
            'corridor': 'Kandy - Nuwara Eliya (A5)',
            'delayMinutes': 30,
            'source': 'SL-RDA Highway Operations Centre',
          },
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
          subtitle: 'Cultural Triangle · Sigiriya Basin',
          payload: {
            'bookingId': 'BK-LK-8041',
            'slaHours': 12,
            'provider': 'Sigiriya Eco Villas Pvt Ltd',
          },
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
          subtitle: 'Sri Lanka Tourism Development Authority',
          payload: {
            'passCode': 'TRV-LK-9041-INTL',
            'validUntil': '2026-11-15',
          },
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
          subtitle: 'Exclusive Member Perk · Sigiriya',
          payload: {
            'entryTime': '06:30 AM',
            'gate': 'Western Water Garden Gate',
          },
        ),
      ];
}

/// Notification Delivery & Channel Preferences
class NotificationPreferences {
  bool pushEnabled;
  bool inAppBannersEnabled;
  bool safetyEnabled;
  bool bookingEnabled;
  bool autopilotEnabled;
  bool messengerEnabled;
  bool offersEnabled;
  bool quietHoursEnabled;
  TimeOfDay quietHoursStart;
  TimeOfDay quietHoursEnd;

  NotificationPreferences({
    this.pushEnabled = true,
    this.inAppBannersEnabled = true,
    this.safetyEnabled = true,
    this.bookingEnabled = true,
    this.autopilotEnabled = true,
    this.messengerEnabled = true,
    this.offersEnabled = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = const TimeOfDay(hour: 22, minute: 0),
    this.quietHoursEnd = const TimeOfDay(hour: 6, minute: 0),
  });

  bool isCategoryEnabled(NotificationCategory category) {
    if (!pushEnabled && !inAppBannersEnabled) return false;
    switch (category) {
      case NotificationCategory.safety:
        return true; // Safety alerts are critical and never suppressed
      case NotificationCategory.booking:
        return bookingEnabled;
      case NotificationCategory.autopilot:
        return autopilotEnabled;
      case NotificationCategory.messenger:
        return messengerEnabled;
      case NotificationCategory.offers:
        return offersEnabled;
      default:
        return true;
    }
  }

  NotificationPreferences copyWith({
    bool? pushEnabled,
    bool? inAppBannersEnabled,
    bool? safetyEnabled,
    bool? bookingEnabled,
    bool? autopilotEnabled,
    bool? messengerEnabled,
    bool? offersEnabled,
    bool? quietHoursEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
  }) {
    return NotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      inAppBannersEnabled: inAppBannersEnabled ?? this.inAppBannersEnabled,
      safetyEnabled: safetyEnabled ?? this.safetyEnabled,
      bookingEnabled: bookingEnabled ?? this.bookingEnabled,
      autopilotEnabled: autopilotEnabled ?? this.autopilotEnabled,
      messengerEnabled: messengerEnabled ?? this.messengerEnabled,
      offersEnabled: offersEnabled ?? this.offersEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}
