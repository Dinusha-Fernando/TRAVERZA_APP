import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/saved/presentation/saved_tab_screen.dart';
import 'package:mobile/theme/app_theme.dart';

void main() {
  testWidgets('SavedTabScreen: renders Wishlist header, collections, items and action buttons', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool isConfirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(
          body: SavedTabScreen(
            isHotelConfirmed: isConfirmed,
            onToggleHotelConfirmation: () => isConfirmed = !isConfirmed,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Header and Segmented Control
    expect(find.text('Saved & Wishlist Hub'), findsOneWidget);
    expect(find.text('Wishlist (5)'), findsOneWidget);
    expect(find.text('85% Ready'), findsOneWidget);
    expect(find.text('Compare (2)'), findsOneWidget);

    // 2. Verify Collections Bar
    expect(find.text('All Saved (5)'), findsOneWidget);
    expect(find.text('Cultural Triangle Stays (2)'), findsOneWidget);
    expect(find.text('Highland Chauffeurs (1)'), findsOneWidget);
    expect(find.text('UNESCO Heritage & Walks (2)'), findsOneWidget);
    expect(find.text('New Collection'), findsOneWidget);

    // 3. Verify Saved Item Cards
    expect(find.text('Airport to Sigiriya Luxury Transfer'), findsOneWidget);
    expect(find.text('Sigiriya Water Garden Eco Villa'), findsOneWidget);
    expect(find.text('Sigiriya Rock Fortress Guided Archaeological Ascent'), findsOneWidget);

    // 4. Verify SLTDA badges & quick actions
    expect(find.text('SLTDA/CG/2026/102'), findsOneWidget);
    expect(find.text('Add to Trip'), findsWidgets);
  });

  testWidgets('SavedTabScreen: collection switching and search filtering works', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(
          body: SavedTabScreen(
            isHotelConfirmed: false,
            onToggleHotelConfirmation: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on 'Cultural Triangle Stays (2)'
    await tester.tap(find.text('Cultural Triangle Stays (2)'));
    await tester.pumpAndSettle();

    // Only Stays should remain visible
    expect(find.text('Sigiriya Water Garden Eco Villa'), findsOneWidget);
    expect(find.text('Heritance Kandalama Forest Suite'), findsOneWidget);
    expect(find.text('Airport to Sigiriya Luxury Transfer'), findsNothing);

    // Enter search query
    await tester.enterText(find.byType(TextField).first, 'Kandalama');
    await tester.pumpAndSettle();

    expect(find.text('Heritance Kandalama Forest Suite'), findsOneWidget);
    expect(find.text('Sigiriya Water Garden Eco Villa'), findsNothing);
  });

  testWidgets('SavedTabScreen: Trip Readiness mode displays diagnostic meter and simulation toggle', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool isConfirmed = false;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => MaterialApp(
          theme: AppTheme.theme,
          home: Scaffold(
            body: SavedTabScreen(
              isHotelConfirmed: isConfirmed,
              onToggleHotelConfirmation: () {
                setState(() => isConfirmed = !isConfirmed);
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Switch to Trip Readiness View
    await tester.tap(find.text('85% Ready'));
    await tester.pumpAndSettle();

    // Verify Diagnostics
    expect(find.text('Corridor Readiness Audit'), findsOneWidget);
    expect(find.text('Diagnostic Safety & Invariant Checks'), findsOneWidget);
    expect(find.text('Transit Buffer Feasibility'), findsOneWidget);
    expect(find.text('SLTDA Provider Verification'), findsOneWidget);
    expect(find.text('Lodging & Service Confirmation'), findsOneWidget);
    expect(find.text('1 ACTION NEEDED'), findsOneWidget);

    // Tap 'Simulate 100% Ready'
    await tester.tap(find.text('Simulate 100% Ready'));
    await tester.pumpAndSettle();

    expect(find.text('100% TRIP READY'), findsOneWidget);
    expect(find.text('3/3 CONFIRMED'), findsOneWidget);
  });

  testWidgets('SavedTabScreen: Side-by-Side comparison mode and modal works', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(
          body: SavedTabScreen(
            isHotelConfirmed: false,
            onToggleHotelConfirmation: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Switch to Compare View
    await tester.tap(find.text('Compare (2)'));
    await tester.pumpAndSettle();

    expect(find.text('Shortlist Comparison Matrix'), findsOneWidget);
    expect(find.text('Open Comparison Table'), findsOneWidget);

    // Tap 'Open Comparison Table'
    await tester.tap(find.text('Open Comparison Table'));
    await tester.pumpAndSettle();

    // Verify comparison table modal
    expect(find.text('Side-by-Side Service Comparison'), findsOneWidget);
    expect(find.text('Add to Trip Draft'), findsWidgets);
  });

  testWidgets('SavedTabScreen: Share Wishlist sheet opens with link and export', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(
          body: SavedTabScreen(
            isHotelConfirmed: false,
            onToggleHotelConfirmation: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap share icon in header
    await tester.tap(find.byIcon(Icons.share_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Share Your Saved Wishlist'), findsOneWidget);
    expect(find.text('Export PDF'), findsOneWidget);
    expect(find.text('Copy Link'), findsOneWidget);
  });
}
