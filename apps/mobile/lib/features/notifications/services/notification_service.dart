import 'dart:math';
import 'package:flutter/material.dart';
import '../data/notification_model.dart';

/// Central Notification Service for TRAVERZA Sri Lanka
/// Manages real-time notifications, unread badges, push simulation, and deep navigation.
class TraverzaNotificationService extends ChangeNotifier {
  TraverzaNotificationService._internal() {
    _notifications = TraverzaNotification.initialNotifications;
  }

  static final TraverzaNotificationService instance = TraverzaNotificationService._internal();

  late List<TraverzaNotification> _notifications;

  List<TraverzaNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  bool get hasUnread => unreadCount > 0;

  /// Marks a specific notification as read
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  /// Marks all current notifications as read
  void markAllAsRead() {
    bool changed = false;
    for (var n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  /// Removes a notification by ID
  void deleteNotification(String id) {
    final initialLength = _notifications.length;
    _notifications.removeWhere((n) => n.id == id);
    if (_notifications.length != initialLength) {
      notifyListeners();
    }
  }

  /// Clears all notifications
  void clearAll() {
    if (_notifications.isNotEmpty) {
      _notifications.clear();
      notifyListeners();
    }
  }

  /// Adds a new notification at the top of the feed
  void addNotification(TraverzaNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// Simulates a real-time incoming notification from local operators or corridor dispatch
  TraverzaNotification simulateIncomingNotification() {
    final randomPool = [
      TraverzaNotification(
        id: 'NOTIF-SIM-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Chauffeur En Route: Lalith J.',
        body: 'Fleet #LK-402 is 12 mins away from Bandaranaike Airport (CMB) Arrivals buffer area.',
        category: NotificationCategory.booking,
        timestamp: DateTime.now(),
        isRead: false,
        actionRoute: 'bookings',
        actionLabel: 'View Chauffeur',
        priority: 'high',
      ),
      TraverzaNotification(
        id: 'NOTIF-SIM-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Sigiriya Morning Weather Advisory',
        body: 'Clear morning skies with 14 km/h light breeze. Perfect weather for Sigiriya Rock ascent.',
        category: NotificationCategory.safety,
        timestamp: DateTime.now(),
        isRead: false,
        actionRoute: 'safety',
        actionLabel: 'Check Weather',
        priority: 'medium',
      ),
      TraverzaNotification(
        id: 'NOTIF-SIM-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Trip Readiness Score: 100%',
        body: 'All 3 pilot corridor reservations are now fully confirmed and cross-validated against TripGraph.',
        category: NotificationCategory.trip,
        timestamp: DateTime.now(),
        isRead: false,
        actionRoute: 'plan',
        actionLabel: 'Open Canvas',
        priority: 'medium',
      ),
      TraverzaNotification(
        id: 'NOTIF-SIM-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Ceylon Tea Tasting Privilege',
        body: 'Complimentary high-altitude tea flight voucher added to your trip pass for Pedro Estate.',
        category: NotificationCategory.offers,
        timestamp: DateTime.now(),
        isRead: false,
        actionRoute: 'saved',
        actionLabel: 'View Perks',
        priority: 'low',
      ),
    ];

    final chosen = randomPool[Random().nextInt(randomPool.length)];
    addNotification(chosen);
    return chosen;
  }

  /// Resets back to default initial state (useful for test isolation)
  void resetToDefaults() {
    _notifications = TraverzaNotification.initialNotifications;
    notifyListeners();
  }
}
