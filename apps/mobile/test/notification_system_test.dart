import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/command_center/presentation/journey_command_center_screen.dart';
import 'package:mobile/features/notifications/data/notification_model.dart';
import 'package:mobile/features/notifications/presentation/notification_center_sheet.dart';
import 'package:mobile/features/notifications/presentation/widgets/in_app_notification_banner.dart';
import 'package:mobile/features/notifications/presentation/widgets/notification_detail_sheet.dart';
import 'package:mobile/features/notifications/services/notification_service.dart';
import 'package:mobile/main.dart';

void main() {
  setUp(() {
    TraverzaNotificationService.instance.resetToDefaults();
  });

  testWidgets('Notification System: tapping notification bell opens NotificationCenterSheet with badges and unread counts', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const TraverzaApp(showSplash: false));
    await tester.pumpAndSettle();

    // Verify initial unread badge is 2
    expect(find.text('2'), findsOneWidget); // Badge counter on bell

    // Tap notification bell icon in AppBar
    final bellFinder = find.byIcon(Icons.notifications_none_rounded);
    expect(bellFinder, findsOneWidget);
    await tester.tap(find.byIcon(Icons.notifications_none_rounded), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify Notification Center opens
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('2 NEW'), findsOneWidget);
    expect(find.text('Mark all read'), findsOneWidget);
    expect(find.text('Kandy → Nuwara Eliya Hairpin Roadwork'), findsOneWidget);
    expect(find.text('Booking Request Received: Sigiriya Eco Villa'), findsOneWidget);
  });

  testWidgets('Notification System: category filter chips filter notifications by Safety, Bookings, Trip, and Offers', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const TraverzaApp(showSplash: false));
    await tester.pumpAndSettle();

    // Tap notification bell
    await tester.tap(find.byIcon(Icons.notifications_none_rounded), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Tap "Safety & Alerts" filter chip
    await tester.tap(find.text('Safety & Alerts (1)'));
    await tester.pumpAndSettle();

    // Only safety notifications should be visible
    expect(find.text('Kandy → Nuwara Eliya Hairpin Roadwork'), findsOneWidget);
    expect(find.text('Booking Request Received: Sigiriya Eco Villa'), findsNothing);

    // Tap "Bookings" filter chip
    await tester.tap(find.text('Bookings (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Booking Request Received: Sigiriya Eco Villa'), findsOneWidget);
    expect(find.text('Kandy → Nuwara Eliya Hairpin Roadwork'), findsNothing);
  });

  testWidgets('Notification System: mark all as read clears the unread badge counter', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const TraverzaApp(showSplash: false));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);

    // Open notification center
    await tester.tap(find.byIcon(Icons.notifications_none_rounded), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Tap "Mark all read"
    await tester.tap(find.text('Mark all read'));
    await tester.pumpAndSettle();

    // Verify "2 NEW" badge in header disappears
    expect(find.text('2 NEW'), findsNothing);
    expect(TraverzaNotificationService.instance.unreadCount, 0);

    // Close sheet by tapping outside / back
    Navigator.of(tester.element(find.byType(NotificationCenterSheet))).pop();
    await tester.pumpAndSettle();

    // In AppBar, the unread badge "2" should no longer exist!
    expect(find.text('2'), findsNothing);
  });

  testWidgets('Notification System: clicking and viewing a notification removes it and navigates to the target tab', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const TraverzaApp(showSplash: false));
    await tester.pumpAndSettle();

    // Open notification center
    await tester.tap(find.byIcon(Icons.notifications_none_rounded), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Tap "Review Buffers" notification (actionRoute: 'plan')
    await tester.tap(find.text('Review Buffers'));
    await tester.pumpAndSettle();

    // Verify it automatically navigated to Plan tab (index 1)
    expect(find.text('Trip Timeline'), findsOneWidget);
    expect(find.text('ID: TRIP-LK-2026-9041'), findsOneWidget);

    // Verify notification was removed from the active notification list as in a real-world production app
    expect(
      TraverzaNotificationService.instance.notifications.any((n) => n.id == 'NOTIF-LK-001'),
      isFalse,
    );
  });

  testWidgets('Notification System: incoming alert dynamically pushes a new notification and updates badge', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const TraverzaApp(showSplash: false));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);

    // Open notification center
    await tester.tap(find.byIcon(Icons.notifications_none_rounded), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify adder bell icon (add_alert_rounded) has been completely removed from the screen
    expect(find.byIcon(Icons.add_alert_rounded), findsNothing);

    // Incoming push alert dynamically received by service
    TraverzaNotificationService.instance.simulateIncomingNotification();
    await tester.pumpAndSettle();

    // Unread count should increment to 3
    expect(find.text('3 NEW'), findsOneWidget);
    expect(TraverzaNotificationService.instance.unreadCount, 3);
  });

  testWidgets('Notification System: simulating Provider Accept in Plan tab dispatches live booking notification', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const TraverzaApp(showSplash: false));
    await tester.pumpAndSettle();

    // Navigate to Plan tab
    await tester.tap(find.byIcon(Icons.alt_route_outlined));
    await tester.pumpAndSettle();

    // Tap Simulate Provider Accept
    await tester.tap(find.text('Simulate Provider Accept'));
    await tester.pumpAndSettle();

    // Verify unread count increased from 2 to 3
    expect(TraverzaNotificationService.instance.unreadCount, 3);

    // Open Notification Center
    await tester.tap(find.byIcon(Icons.notifications_none_rounded), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify new booking confirmation alert is in feed
    expect(find.text('Sigiriya Water Garden: Fully Confirmed'), findsOneWidget);
    expect(find.text('Eco Villa reservation confirmed by provider. Voucher #VOUCH-LK-9041 is ready.'), findsOneWidget);
  });

  testWidgets('Notification System: search and unread toggle dynamically filter notifications', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const TraverzaApp(showSplash: false));
    await tester.pumpAndSettle();

    // Open Notification Center
    await tester.tap(find.byIcon(Icons.notifications_none_rounded), warnIfMissed: false);
    await tester.pumpAndSettle();

    // 1. Search for 'Hairpin' in notification sheet search field
    final searchFinder = find.descendant(
      of: find.byType(NotificationCenterSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(searchFinder, 'Hairpin');
    await tester.pumpAndSettle();

    expect(find.text('Kandy → Nuwara Eliya Hairpin Roadwork'), findsOneWidget);
    expect(find.text('Booking Request Received: Sigiriya Eco Villa'), findsNothing);

    // Clear search
    await tester.tap(find.byIcon(Icons.clear_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Booking Request Received: Sigiriya Eco Villa'), findsOneWidget);

    // 2. Tap "Unread" toggle
    await tester.tap(find.text('Unread'));
    await tester.pumpAndSettle();

    // Unread items should be visible (2 unread: Kandy roadwork and Sigiriya booking)
    expect(find.text('Kandy → Nuwara Eliya Hairpin Roadwork'), findsOneWidget);
    expect(find.text('Booking Request Received: Sigiriya Eco Villa'), findsOneWidget);
    // Already read item should be excluded
    expect(find.text('SLTDA Biometric Pass Activated'), findsNothing);
  });

  testWidgets('Notification System: notification preferences sheet toggles delivery channels and categories', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const TraverzaApp(showSplash: false));
    await tester.pumpAndSettle();

    // Open Notification Center
    await tester.tap(find.byIcon(Icons.notifications_none_rounded), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Tap Preferences icon inside NotificationCenterSheet
    await tester.tap(
      find.descendant(
        of: find.byType(NotificationCenterSheet),
        matching: find.byIcon(Icons.tune_rounded),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notification Preferences'), findsOneWidget);
    expect(find.text('Push Notifications'), findsOneWidget);
    expect(find.text('In-App Heads-Up Banners'), findsOneWidget);
    expect(find.text('Safety & Emergency Advisories'), findsOneWidget);
    expect(find.text('Journey Autopilot & Disruption Recovery'), findsOneWidget);
    expect(find.text('Quiet Hours'), findsOneWidget);

    // Toggle Quiet Hours switch
    final switches = find.byType(Switch);
    expect(switches, findsWidgets);

    // Close preferences sheet
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
  });

  testWidgets('Notification System: notification detail sheet displays telemetry metadata and triggers direct action', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool navigated = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationDetailSheet(
            notification: TraverzaNotification.initialNotifications.first,
            onNavigate: (route) {
              navigated = true;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kandy → Nuwara Eliya Hairpin Roadwork'), findsOneWidget);
    expect(find.text('CORRIDOR TELEMETRY & DISPATCH METADATA'), findsOneWidget);
    expect(find.text('A5 Hill Highway · Ramboda Pass'), findsOneWidget);
    expect(find.text('Review Buffers'), findsOneWidget);

    // Tap Review Buffers action
    await tester.tap(find.text('Review Buffers'));
    await tester.pumpAndSettle();

    expect(navigated, isTrue);
  });

  testWidgets('Notification System: in-app heads-up notification banner slides in and navigates to command_center', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const TraverzaApp(showSplash: false));
    await tester.pumpAndSettle();

    // Trigger Autopilot Disruption notification
    TraverzaNotificationService.instance.addNotification(
      TraverzaNotification(
        id: 'NOTIF-TEST-AP-01',
        title: '⚡ Autopilot Alert: Flight UL-504 Delayed',
        body: 'Landing delayed by +45m. Feasible recovery plan ready for your approval.',
        category: NotificationCategory.autopilot,
        timestamp: DateTime.now(),
        isRead: false,
        actionRoute: 'command_center',
        actionLabel: 'Review Recovery Plan',
        priority: 'high',
      ),
    );
    await tester.pumpAndSettle();

    // In-App Heads-Up Banner is rendered at top
    expect(find.byType(InAppNotificationBanner), findsOneWidget);
    expect(find.text('⚡ Autopilot Alert: Flight UL-504 Delayed'), findsOneWidget);
    expect(find.text('Review Recovery Plan'), findsOneWidget);

    // Tapping the banner triggers navigation to Journey Command Center
    await tester.tap(find.text('Review Recovery Plan'));
    await tester.pumpAndSettle();

    expect(find.byType(JourneyCommandCenterScreen), findsOneWidget);
    expect(find.text('JOURNEY COMMAND CENTER'), findsOneWidget);
    expect(find.text('Mission Control'), findsOneWidget);
  });
}
