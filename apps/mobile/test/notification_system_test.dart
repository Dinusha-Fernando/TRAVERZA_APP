import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/notifications/presentation/notification_center_sheet.dart';
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

  testWidgets('Notification System: tapping a notification marks it as read and navigates to the target tab', (WidgetTester tester) async {
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
  });

  testWidgets('Notification System: simulating incoming alert dynamically pushes a new notification and updates badge', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const TraverzaApp(showSplash: false));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);

    // Open notification center
    await tester.tap(find.byIcon(Icons.notifications_none_rounded), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Tap Simulate Incoming Alert button
    final simulateBtn = find.byIcon(Icons.add_alert_rounded);
    expect(simulateBtn, findsOneWidget);
    await tester.tap(simulateBtn);
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
}
