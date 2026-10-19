import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('TRAVERZA Splash Screen: renders animated branding and transitions to MainTripScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Mount app with showSplash: true
    await tester.pumpWidget(const TraverzaApp(showSplash: true));

    // Mid-animation frame
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('TRAVERZA'), findsOneWidget);
    expect(find.text('SRI LANKA OPERATING PLATFORM'), findsOneWidget);
    expect(find.text('One island. One connected trip.'), findsOneWidget);
    expect(find.text('Connecting Pilot Corridor: Colombo · Sigiriya · Kandy'), findsOneWidget);
    expect(find.text('SLTDA Verified Travel Marketplace Standard'), findsOneWidget);

    // Complete timer duration and transition to Home
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();

    // Verify navigation into MainTripScreen
    expect(find.text('Your Sri Lanka story starts here.'), findsOneWidget);
    expect(find.text('Explore services'), findsOneWidget);
  });

  testWidgets('TRAVERZA Home Screen: renders magazine hero, search, services grid and active trip', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const TraverzaApp(showSplash: false));
    await tester.pumpAndSettle();

    // 1. Verify App Bar branding and location chip
    expect(find.text('TRAVERZA'), findsOneWidget);
    expect(find.text('SRI LANKA · CULTURAL TRIANGLE'), findsOneWidget);

    // 2. Verify Welcome Headline
    expect(find.text('Your Sri Lanka story starts here.'), findsOneWidget);
    expect(find.text('YOUR JOURNEY, CONNECTED'), findsOneWidget);

    // 3. Verify Search Bar
    expect(find.text('Where would you like to go?'), findsOneWidget);
    expect(find.text('Search destinations, stays and experiences'), findsOneWidget);

    // 4. Verify Style A Hero Feature Card
    expect(find.text('One island. One connected trip.'), findsOneWidget);
    expect(find.text('Plan my trip'), findsOneWidget);

    // 5. Verify Active Trip card
    expect(find.text('CONTINUE YOUR JOURNEY'), findsOneWidget);
    expect(find.text('ID: TRIP-LK-2026-9041'), findsOneWidget);
    expect(find.text('Partially Confirmed (2/3)'), findsOneWidget);

    // 6. Verify "Explore services" bento grid categories
    expect(find.text('Explore services'), findsOneWidget);
    expect(find.text('Stays'), findsOneWidget);
    expect(find.text('Transport'), findsOneWidget);
    expect(find.text('Tours & Experiences'), findsOneWidget);
    expect(find.text('Local Guides'), findsOneWidget);
    expect(find.text('Food & Dining'), findsOneWidget);
    expect(find.text('Places & Tickets'), findsOneWidget);
    expect(find.text('Vehicle Rentals'), findsOneWidget);
    expect(find.text('Travel Essentials'), findsOneWidget);

    // 7. Drag vertical SingleChildScrollView to reveal Curated Journeys and Manage Your Journey
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Curated Sri Lanka Journeys'), findsOneWidget);
    expect(find.text('The Cultural Triangle'), findsOneWidget);
    expect(find.text('Manage your journey'), findsOneWidget);
    expect(find.text('Trip Canvas'), findsOneWidget);
    expect(find.text('Trip budget'), findsOneWidget);
    expect(find.text('Travel safety'), findsOneWidget);
  });

  testWidgets('Navigation: Plan button navigates to Trip Canvas and simulates confirmation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const TraverzaApp(showSplash: false));
    await tester.pumpAndSettle();

    // Tap "Plan my trip" CTA button on Hero Card
    await tester.tap(find.text('Plan my trip'));
    await tester.pumpAndSettle();

    // Verify Trip Timeline is displayed
    expect(find.text('Trip Timeline'), findsOneWidget);
    expect(find.text('ID: TRIP-LK-2026-9041'), findsOneWidget);
    expect(find.text('Partially Confirmed (2/3)'), findsOneWidget);
    expect(find.text('Simulate Provider Accept'), findsOneWidget);

    // Tap Simulate Provider Accept
    await tester.tap(find.text('Simulate Provider Accept'));
    await tester.pumpAndSettle();

    // Verify status transitions to Fully Confirmed
    expect(find.text('Fully Confirmed (3/3)'), findsOneWidget);
  });

  testWidgets('Navigation: Service Category card filters Bookings catalogue', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const TraverzaApp(showSplash: false));
    await tester.pumpAndSettle();

    // Tap on "Transport" category card
    await tester.tap(find.text('Transport'));
    await tester.pumpAndSettle();

    // Verify that Bookings catalogue opens with filter applied
    expect(find.text('Fit-to-Trip Verified Services'), findsOneWidget);
    expect(find.text('Filtered: TRANSFER'), findsOneWidget);
  });

  testWidgets('Navigation: Travel safety shortcut opens Offline SOS & Emergency Vault', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const TraverzaApp(showSplash: false));
    await tester.pumpAndSettle();

    // Drag vertical scroll view so that Travel safety shortcut is in view
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1000));
    await tester.pumpAndSettle();

    // Tap Travel safety
    await tester.tap(find.text('Travel safety'));
    await tester.pumpAndSettle();

    // Verify Emergency Vault opens
    expect(find.text('Offline SOS & Emergency Vault'), findsOneWidget);
    expect(find.text('1912'), findsOneWidget); // Tourist Police
    expect(find.text('1990'), findsOneWidget); // Ambulance
  });

  testWidgets('Search: entering query in Home Screen filters services and navigates', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const TraverzaApp(showSplash: false));
    await tester.pumpAndSettle();

    // 1. Enter text in the search TextField
    final searchInput = find.byType(TextField);
    expect(searchInput, findsOneWidget);
    await tester.enterText(searchInput, 'Sigiriya');
    await tester.pumpAndSettle();

    // 2. Verify in-page search results appear
    expect(find.text('Found 3 results for "Sigiriya"'), findsOneWidget);
    expect(find.text('Sigiriya Water Garden Eco Villa'), findsOneWidget);

    // 3. Submit search
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    // 4. Verify navigation to filtered Bookings Catalogue
    expect(find.text('Fit-to-Trip Verified Services'), findsOneWidget);
    expect(find.text('Search: "Sigiriya"'), findsOneWidget);
  });
}
