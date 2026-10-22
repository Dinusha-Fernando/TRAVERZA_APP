import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/command_center/presentation/journey_command_center_screen.dart';
import 'package:mobile/features/command_center/services/journey_autopilot_service.dart';
import 'package:mobile/screens/home_screen.dart';
import 'package:mobile/theme/app_theme.dart';

void main() {
  setUp(() {
    JourneyAutopilotService.instance.resetToBaseline();
  });

  testWidgets('Journey Command Center: renders Mission Control with 7 modules', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: const JourneyCommandCenterScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify App Bar and Header
    expect(find.text('JOURNEY COMMAND CENTER'), findsOneWidget);
    expect(find.text('TRAVERZA 2.0'), findsOneWidget);

    // 2. Verify Segment Tabs
    expect(find.text('Mission Control'), findsOneWidget);
    expect(find.text('Autopilot (1)'), findsOneWidget);
    expect(find.text('Travel Wallet'), findsOneWidget);

    // 3. Verify Module 1: Journey Status Hero
    expect(find.text('DAY 1 OF 3'), findsOneWidget);
    expect(find.text('Cultural Triangle & Highland Heritage'), findsOneWidget);
    expect(find.text('Trip ID: TRIP-LK-2026-9041'), findsOneWidget);

    // 4. Verify Module 2: Next Action Alert
    expect(find.text('NEXT ACTION'), findsOneWidget);
    expect(find.textContaining('Review before driver dispatch'), findsOneWidget);

    // 5. Verify Module 3: Trip Health Radar
    expect(find.text('TRIP HEALTH & FEASIBILITY'), findsOneWidget);
    expect(find.textContaining('Feasible'), findsWidgets);

    // 6. Verify Module 4: Connected Timeline & Google Maps
    expect(find.text('Connected Timeline'), findsOneWidget);
    expect(find.text('Airport to Sigiriya Private Transfer'), findsOneWidget);
    expect(find.text('Sigiriya Water Garden Eco Villa'), findsOneWidget);
    expect(find.text('Google Maps'), findsWidgets);

    // 7. Verify Module 5: Budget Breakdown
    expect(find.text('BUDGET BREAKDOWN'), findsOneWidget);
    expect(find.text('Committed Spend (Services)'), findsOneWidget);
    expect(find.text('Paid in Escrow Ledger'), findsOneWidget);
    expect(find.text('Pending Provider Acceptance'), findsOneWidget);

    // 8. Verify AI Companion FAB
    expect(find.text('AI Companion'), findsOneWidget);
  });

  testWidgets('Journey Command Center: Autopilot tab renders 6-step loop and authorizes recovery plan', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: const JourneyCommandCenterScreen(initialTab: CommandCenterTab.autopilot),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify 6-Step Loop Visualizer
    expect(find.text('AUTOPILOT 6-STEP LOOP'), findsOneWidget);
    expect(find.text('1. Observe'), findsOneWidget);
    expect(find.text('2. Assess'), findsOneWidget);
    expect(find.text('3. Propose'), findsOneWidget);
    expect(find.text('4. Authorize'), findsOneWidget);
    expect(find.text('5. Execute'), findsOneWidget);
    expect(find.text('6. Verify'), findsOneWidget);

    // 2. Verify Active Disruption Incident
    expect(find.text('Active Disruption Events'), findsOneWidget);
    expect(find.textContaining('FLIGHT DELAY'), findsOneWidget);
    expect(find.text('⚡ Autopilot Proposed Plan'), findsOneWidget);
    expect(find.text('Cost Delta: LKR 0'), findsOneWidget);
    expect(find.text('PENDING APPROVAL'), findsOneWidget);

    // 3. Authorize Proposal
    await tester.tap(find.text('✓ Authorize & Update Itinerary'));
    await tester.pumpAndSettle();

    // 4. Verify Approved State & Step 6 Verification
    expect(find.text('APPROVED'), findsOneWidget);
    expect(find.textContaining('Step 6: Executed & Verified via TripGraph'), findsOneWidget);
  });

  testWidgets('Journey Command Center: Travel Wallet displays offline encrypted QR vouchers', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: const JourneyCommandCenterScreen(initialTab: CommandCenterTab.travelWallet),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Offline Sync Status Banner
    expect(find.textContaining('100% Offline Ready'), findsOneWidget);

    // 2. Verify Digital Vouchers
    expect(find.text('Digital Travel Vouchers'), findsOneWidget);
    expect(find.text('VOUCH-LK-TRANSFER-402'), findsOneWidget);
    expect(find.text('VOUCH-LK-EXCURSION-802'), findsOneWidget);
    expect(find.text('SLTDA Verified'), findsWidgets);
    expect(find.byIcon(Icons.qr_code_2_rounded), findsWidgets);

    // 3. Verify Offline Emergency Contacts
    expect(find.text('OFFLINE EMERGENCY CONTACTS'), findsOneWidget);
    expect(find.text('Sri Lanka Tourist Police'), findsOneWidget);
    expect(find.text('1912 (24/7 Toll-Free)'), findsOneWidget);
  });

  testWidgets('Journey Command Center: AI Companion sheet opens and answers grounded prompt', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: const JourneyCommandCenterScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap AI Companion FAB
    await tester.tap(find.text('AI Companion'));
    await tester.pumpAndSettle();

    // Verify AI Companion Sheet opened
    expect(find.text('AI Travel Companion'), findsOneWidget);
    expect(find.text('Grounded in TripGraph 2.0 & Live Booking Truth'), findsOneWidget);
    expect(find.text('What is my next action?'), findsOneWidget);

    // Tap quick prompt chip
    await tester.tap(find.text('What is my next action?'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Verify Grounded AI Response
    expect(find.text('TRIPGRAPH AUTHORITATIVE STATE'), findsOneWidget);
    expect(find.textContaining('Your current Next Action:'), findsOneWidget);
  });

  testWidgets('HomeScreen: active trip card renders without RenderFlex overflow on narrow 345px width', (tester) async {
    tester.view.physicalSize = const Size(345, 750);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(
          body: HomeScreen(
            hasActiveTrip: true,
            isHotelConfirmed: false,
            onNavigateToPlan: () {},
            onCategorySelected: (_) {},
            onNavigateToSafety: () {},
            onNavigateToCatalogue: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CONTINUE YOUR JOURNEY'), findsOneWidget);
    expect(find.text('COMMAND CENTER'), findsOneWidget);
    expect(find.text('Partially Confirmed (2/3)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
