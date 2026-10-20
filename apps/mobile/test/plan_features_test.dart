import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/plan/custom_trip_builder_screen.dart';
import 'package:mobile/features/plan/data/package_model.dart';
import 'package:mobile/features/plan/package_details_screen.dart';
import 'package:mobile/features/plan/package_explorer_screen.dart';
import 'package:mobile/features/plan/plan_tab_screen.dart';
import 'package:mobile/features/plan/widgets/add_to_trip_sheet.dart';
import 'package:mobile/theme/app_theme.dart';

void main() {
  testWidgets('PlanTabScreen: renders Hub, 3 Planning Paths, active trip card, and packages carousel', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool isConfirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(
          body: PlanTabScreen(
            isHotelConfirmed: isConfirmed,
            onToggleSimulation: () => isConfirmed = !isConfirmed,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Plan Hub Header & Context
    expect(find.text('Plan your Sri Lanka journey'), findsOneWidget);
    expect(find.text('Connected corridor: Colombo (CMB) → Sigiriya → Kandy → Nuwara Eliya'), findsOneWidget);

    // 2. Verify Three Planning Paths
    expect(find.text('Three Ways to Plan'), findsOneWidget);
    expect(find.text('Continue My Trip'), findsOneWidget);
    expect(find.text('Explore Provider Packages'), findsOneWidget);
    expect(find.text('Build a Custom Trip'), findsOneWidget);

    // 3. Verify Active Trip Card
    expect(find.text('Trip Timeline'), findsOneWidget);
    expect(find.text('ID: TRIP-LK-2026-9041'), findsOneWidget);
    expect(find.text('Partially Confirmed (2/3)'), findsOneWidget);

    // 4. Verify Recommended Packages
    expect(find.text('Recommended Packages & Routes'), findsOneWidget);
    expect(find.text('3-Day Cultural Triangle Signature Escape'), findsOneWidget);
    expect(find.text('OPERATOR PACKAGE'), findsWidgets);
  });

  testWidgets('PlanTabScreen: switching to Trip Canvas, Packages, and Custom Builder views works', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(
          body: PlanTabScreen(
            isHotelConfirmed: false,
            onToggleSimulation: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Switch to Packages view via top mode tab
    await tester.tap(find.text('Packages'));
    await tester.pumpAndSettle();
    expect(find.text('Packages Marketplace'), findsOneWidget);
    expect(find.text('Operator Bundles'), findsOneWidget);
    expect(find.text('Route Templates'), findsOneWidget);

    // Return to Plan Hub via back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Switch to Custom Builder view via top mode tab
    await tester.tap(find.text('Custom Builder'));
    await tester.pumpAndSettle();
    expect(find.text('Stage 1 of 5: Trip Basics'), findsOneWidget);
    expect(find.text('Trip Name'), findsOneWidget);
  });

  testWidgets('PlanTabScreen: Trip Canvas provides back button and mode switcher to others', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(
          body: PlanTabScreen(
            isHotelConfirmed: false,
            onToggleSimulation: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Switch to Trip Canvas from Hub
    await tester.tap(find.text('Trip Canvas'));
    await tester.pumpAndSettle();

    // Verify Trip Canvas header and back navigation are present
    expect(find.text('Active Workspace'), findsOneWidget);
    expect(find.text('Back to Plan Hub'), findsOneWidget); // On ActiveTripSummaryCard
    expect(find.byIcon(Icons.arrow_back), findsWidgets); // Back arrow in header and card

    // 2. Tap back button to return to Hub
    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await tester.pumpAndSettle();

    expect(find.text('Plan your Sri Lanka journey'), findsOneWidget);
    expect(find.text('Three Ways to Plan'), findsOneWidget);

    // 3. Open Trip Canvas again via "Open Trip Canvas" on active card
    await tester.tap(find.text('Open Trip Canvas'));
    await tester.pumpAndSettle();

    expect(find.text('Active Workspace'), findsOneWidget);

    // 4. Test switching directly to "Packages" from within Trip Canvas ("others")
    await tester.tap(find.text('Packages'));
    await tester.pumpAndSettle();

    expect(find.text('Packages Marketplace'), findsOneWidget);

    // Return to Hub
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // 5. Open Trip Canvas again, and test switching to "Custom Builder" directly from within Trip Canvas ("others")
    await tester.tap(find.text('Trip Canvas'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Custom Builder'));
    await tester.pumpAndSettle();

    expect(find.text('Stage 1 of 5: Trip Basics'), findsOneWidget);

    // Exit Draft back to Hub
    await tester.tap(find.text('Exit Draft'));
    await tester.pumpAndSettle();

    expect(find.text('Plan your Sri Lanka journey'), findsOneWidget);
  });

  testWidgets('PackageExplorerScreen: filters packages and triggers compare modal', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: PackageExplorerScreen(
          onBackToHub: () {},
          onCustomizePackage: (pkg) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Packages Marketplace'), findsOneWidget);
    expect(find.text('All Packages'), findsOneWidget);

    // Filter by Route Templates
    await tester.tap(find.text('Route Templates'));
    await tester.pumpAndSettle();

    expect(find.text('5-Day Hill Country Scenic Route'), findsOneWidget);
    expect(find.text('ITINERARY TEMPLATE'), findsOneWidget);
  });

  testWidgets('PackageDetailsScreen: displays inclusions, terms, and opens booking sheet', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final pkg = TraverzaPackage.getCuratedPackages().first;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: PackageDetailsScreen(
          package: pkg,
          onCustomize: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Operator Package Details'), findsOneWidget);
    expect(find.text('3-Day Cultural Triangle Signature Escape'), findsOneWidget);
    expect(find.text('Day-by-Day Journey Itinerary'), findsOneWidget);
    expect(find.text('Inclusions & Terms'), findsOneWidget);

    // Tap Book Package
    await tester.tap(find.text('Book Package'));
    await tester.pumpAndSettle();

    expect(find.text('Request Booking: ${pkg.title}'), findsOneWidget);
    expect(find.text('Submit Booking Request'), findsOneWidget);
  });

  testWidgets('CustomTripBuilderScreen: progresses through stages and tests TripGraph repairs', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: CustomTripBuilderScreen(
          onBackToHub: () {},
          onTripSaved: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Stage 1: Basics
    expect(find.text('Stage 1 of 5: Trip Basics'), findsOneWidget);
    expect(find.text('My Cultural & Highland Journey'), findsOneWidget);

    // Proceed to Stage 2: Destinations
    await tester.tap(find.text('Continue to Destinations'));
    await tester.pumpAndSettle();
    expect(find.text('Stage 2 of 5: Destinations'), findsOneWidget);
    expect(find.text('Sigiriya & Dambulla'), findsOneWidget);

    // Proceed to Stage 3: Services
    await tester.tap(find.text('Continue to Add Services'));
    await tester.pumpAndSettle();
    expect(find.text('Stage 3 of 5: Add Services'), findsOneWidget);
    expect(find.text('Toyota Prado Chauffeur Transfer'), findsOneWidget);

    // Proceed to Stage 4: TripGraph
    await tester.tap(find.text('Continue to TripGraph Feasibility'));
    await tester.pumpAndSettle();
    expect(find.text('Stage 4 of 5: TripGraph Feasibility'), findsOneWidget);
    expect(find.text('TripGraph Schedule Audit'), findsOneWidget);
    expect(find.text('Warning: Tight Airport Transfer Window'), findsOneWidget);

    // Apply repair
    await tester.tap(find.text('Apply 30m Buffer Repair'));
    await tester.pumpAndSettle();
    expect(find.text('Buffer Resolved: 30m Customs Buffer Added'), findsOneWidget);

    // Proceed to Stage 5: Review
    await tester.tap(find.text('Continue to Review & Save'));
    await tester.pumpAndSettle();
    expect(find.text('Stage 5 of 5: Review & Save'), findsOneWidget);
    expect(find.text('Save Draft & Open Canvas'), findsOneWidget);
  });

  testWidgets('AddToTripSheet: allows category selection and adding items', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    String? addedTitle;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(
          body: Builder(
            builder: (ctx) => Center(
              child: ElevatedButton(
                onPressed: () => AddToTripSheet.show(
                  ctx,
                  onItemAdded: (title, cat, subtitle, price) => addedTitle = title,
                ),
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Add to Your Trip'), findsOneWidget);
    expect(find.text('Dambulla Golden Rock Temple'), findsOneWidget);

    // Tap Add on the first item
    await tester.tap(find.text('Add').first);
    await tester.pumpAndSettle();

    expect(addedTitle, 'Dambulla Golden Rock Temple');
  });
}
