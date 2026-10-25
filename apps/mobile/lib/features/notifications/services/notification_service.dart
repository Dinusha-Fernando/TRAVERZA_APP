import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/notification_model.dart';

/// Central Real-World Notification Service for TRAVERZA Sri Lanka
/// Manages real-time corridor alerts, in-app heads-up banners, backend sync,
/// unread badges, push registration, and deep navigation.
class TraverzaNotificationService extends ChangeNotifier {
  TraverzaNotificationService._internal() {
    _notifications = List.from(TraverzaNotification.initialNotifications);
    _preferences = NotificationPreferences();
  }

  static final TraverzaNotificationService instance = TraverzaNotificationService._internal();

  late List<TraverzaNotification> _notifications;
  late NotificationPreferences _preferences;

  /// Holds the current active in-app heads-up notification banner
  final ValueNotifier<TraverzaNotification?> activeBanner = ValueNotifier<TraverzaNotification?>(null);

  List<TraverzaNotification> get notifications => List.unmodifiable(_notifications);

  NotificationPreferences get preferences => _preferences;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  bool get hasUnread => unreadCount > 0;

  String get _apiBaseUrl {
    try {
      if (!kIsWeb && Platform.isAndroid) {
        return 'http://10.0.2.2:8000/api/v1/notifications';
      }
    } catch (_) {}
    return 'http://127.0.0.1:8000/api/v1/notifications';
  }

  /// Marks a specific notification as read and syncs with backend
  void markAsRead(String id, {String? authToken}) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
      _syncReadStatusToBackend(id, authToken: authToken);
    }
  }

  /// Toggles a notification back to unread state
  void markAsUnread(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && _notifications[index].isRead) {
      _notifications[index].isRead = false;
      notifyListeners();
    }
  }

  /// Marks all current notifications as read
  void markAllAsRead({String? authToken}) {
    bool changed = false;
    for (var n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        changed = true;
        _syncReadStatusToBackend(n.id, authToken: authToken);
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
      if (activeBanner.value?.id == id) {
        dismissActiveBanner();
      }
      notifyListeners();
    }
  }

  /// Clears all notifications
  void clearAll() {
    if (_notifications.isNotEmpty) {
      _notifications.clear();
      dismissActiveBanner();
      notifyListeners();
    }
  }

  /// Adds a new notification at the top of the feed and displays an in-app banner
  void addNotification(TraverzaNotification notification, {bool showInAppBanner = true}) {
    _notifications.insert(0, notification);
    notifyListeners();

    if (showInAppBanner && _preferences.inAppBannersEnabled && _preferences.isCategoryEnabled(notification.category)) {
      activeBanner.value = notification;
    }
  }

  /// Manually dismisses the current active heads-up banner
  void dismissActiveBanner() {
    activeBanner.value = null;
  }

  /// Updates notification delivery and channel preferences
  void updatePreferences(NotificationPreferences newPreferences) {
    _preferences = newPreferences;
    notifyListeners();
  }

  /// Filter notifications by category, search query, and unread status
  List<TraverzaNotification> filterNotifications({
    NotificationCategory category = NotificationCategory.all,
    String query = '',
    bool unreadOnly = false,
  }) {
    return _notifications.where((n) {
      if (category != NotificationCategory.all && n.category != category) {
        return false;
      }
      if (unreadOnly && n.isRead) {
        return false;
      }
      if (query.trim().isNotEmpty) {
        final q = query.toLowerCase();
        final matchesTitle = n.title.toLowerCase().contains(q);
        final matchesBody = n.body.toLowerCase().contains(q);
        final matchesSubtitle = n.subtitle?.toLowerCase().contains(q) ?? false;
        if (!matchesTitle && !matchesBody && !matchesSubtitle) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  /// Synchronizes notifications with the backend API (/api/v1/notifications)
  Future<void> syncWithBackend({String? authToken}) async {
    if (kIsWeb) return;
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(milliseconds: 1500);
      final request = await client.getUrl(Uri.parse(_apiBaseUrl));
      if (authToken != null && authToken.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $authToken');
      }

      final response = await request.close().timeout(const Duration(milliseconds: 1800));
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List<dynamic> data = jsonDecode(responseBody) as List<dynamic>;

        final fetched = data.map((item) => TraverzaNotification.fromJson(item as Map<String, dynamic>)).toList();

        // Merge fetched items without duplicating existing IDs
        final existingIds = _notifications.map((n) => n.id).toSet();
        for (var n in fetched) {
          if (!existingIds.contains(n.id)) {
            _notifications.insert(0, n);
            existingIds.add(n.id);
          }
        }
        notifyListeners();
      }
      client.close();
    } catch (_) {
      // Graceful offline fallback
    }
  }

  /// Internal asynchronous call to sync read status to backend
  void _syncReadStatusToBackend(String id, {String? authToken}) {
    if (kIsWeb) return;
    Future.microtask(() async {
      try {
        final client = HttpClient();
        client.connectionTimeout = const Duration(milliseconds: 1500);
        final request = await client.postUrl(Uri.parse('$_apiBaseUrl/$id/read'));
        if (authToken != null && authToken.isNotEmpty) {
          request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $authToken');
        }
        final response = await request.close().timeout(const Duration(milliseconds: 1500));
        response.drain();
        client.close();
      } catch (_) {}
    });
  }

  /// Registers client FCM/device push token with backend
  Future<bool> registerDevicePushToken(String token, {String platform = 'android', String? authToken}) async {
    if (kIsWeb) return false;
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(milliseconds: 1500);
      final request = await client.postUrl(Uri.parse('$_apiBaseUrl/device-token'));
      request.headers.contentType = ContentType.json;
      if (authToken != null && authToken.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $authToken');
      }
      request.write(jsonEncode({
        'token': token,
        'platform': platform,
      }));

      final response = await request.close().timeout(const Duration(milliseconds: 1800));
      final success = response.statusCode == 201 || response.statusCode == 200;
      client.close();
      return success;
    } catch (_) {
      return false;
    }
  }

  /// Simulates a real-time incoming notification from local operators, corridor telemetry, or AI autopilot
  TraverzaNotification simulateIncomingNotification({NotificationCategory? category}) {
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
        subtitle: 'CMB Airport Expressway Corridor',
        payload: {'driver': 'Lalith J.', 'vehicle': 'Toyota HiAce Luxury (Fleet #LK-402)'},
      ),
      TraverzaNotification(
        id: 'NOTIF-SIM-${DateTime.now().millisecondsSinceEpoch + 1}',
        title: 'Sigiriya Morning Weather Advisory',
        body: 'Clear morning skies with 14 km/h light breeze. Perfect weather for Sigiriya Rock ascent.',
        category: NotificationCategory.safety,
        timestamp: DateTime.now(),
        isRead: false,
        actionRoute: 'safety',
        actionLabel: 'Check Weather',
        priority: 'medium',
        subtitle: 'Cultural Triangle Micro-Climate',
        payload: {'tempC': 26, 'windKmh': 14, 'uvIndex': 'Moderate'},
      ),
      TraverzaNotification(
        id: 'NOTIF-SIM-${DateTime.now().millisecondsSinceEpoch + 2}',
        title: 'Trip Readiness Score: 100%',
        body: 'All 3 pilot corridor reservations are now fully confirmed and cross-validated against TripGraph.',
        category: NotificationCategory.trip,
        timestamp: DateTime.now(),
        isRead: false,
        actionRoute: 'plan',
        actionLabel: 'Open Canvas',
        priority: 'medium',
        subtitle: 'TripGraph Deterministic Validation',
      ),
      TraverzaNotification(
        id: 'NOTIF-SIM-${DateTime.now().millisecondsSinceEpoch + 3}',
        title: 'Ceylon Tea Tasting Privilege',
        body: 'Complimentary high-altitude tea flight voucher added to your trip pass for Pedro Estate.',
        category: NotificationCategory.offers,
        timestamp: DateTime.now(),
        isRead: false,
        actionRoute: 'saved',
        actionLabel: 'View Perks',
        priority: 'low',
        subtitle: 'Pedro Estate · Nuwara Eliya',
      ),
      TraverzaNotification(
        id: 'NOTIF-SIM-${DateTime.now().millisecondsSinceEpoch + 4}',
        title: '⚡ Autopilot Alert: Flight UL-504 Delayed',
        body: 'Landing delayed by +45m. Feasible recovery plan ready for your approval with zero cancellation risk.',
        category: NotificationCategory.autopilot,
        timestamp: DateTime.now(),
        isRead: false,
        actionRoute: 'command_center',
        actionLabel: 'Review Recovery Plan',
        priority: 'emergency',
        subtitle: 'CMB Flight Telemetry Feed',
      ),
      TraverzaNotification(
        id: 'NOTIF-SIM-${DateTime.now().millisecondsSinceEpoch + 5}',
        title: 'New Message from Guide Samantha',
        body: "'Meeting at Pidurangala base car park at 05:15 AM for dawn headlamp hike. Trail is dry.'",
        category: NotificationCategory.messenger,
        timestamp: DateTime.now(),
        isRead: false,
        actionRoute: 'messenger',
        actionLabel: 'Reply in Chat',
        priority: 'high',
        subtitle: 'Direct Host Messenger',
      ),
    ];

    TraverzaNotification chosen;
    if (category != null) {
      final matching = randomPool.where((n) => n.category == category).toList();
      chosen = matching.isNotEmpty ? matching.first : randomPool.first;
    } else {
      chosen = randomPool[Random().nextInt(randomPool.length)];
    }

    addNotification(chosen);
    return chosen;
  }

  /// Resets back to default initial state (useful for test isolation)
  void resetToDefaults() {
    activeBanner.value = null;
    _notifications = List.from(TraverzaNotification.initialNotifications);
    _preferences = NotificationPreferences();
    notifyListeners();
  }
}
