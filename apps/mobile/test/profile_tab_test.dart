import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/profile/presentation/profile_tab_screen.dart';
import 'package:mobile/theme/app_theme.dart';

void main() {
  Widget buildTestableProfileTab({int initialSegment = 0}) {
    return MaterialApp(
      theme: AppTheme.theme,
      home: Scaffold(
        body: ProfileTabScreen(initialSegment: initialSegment),
      ),
    );
  }

  testWidgets('ProfileTabScreen: renders Digital Passport, milestone metrics, and default Safety & SOS Vault', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableProfileTab());
    await tester.pumpAndSettle();

    // 1. Digital Passport Card
    expect(find.text('TRAVERZA PASSPORT'), findsOneWidget);
    expect(find.text('PILOT ELITE MEMBER'), findsOneWidget);
    expect(find.text('Dinusha Wijesinghe'), findsOneWidget);
    expect(find.text('Independent International Traveller • Pilot Member'), findsOneWidget);
    expect(find.text('SLTDA Verified'), findsOneWidget);
    expect(find.text('Digital QR Pass'), findsOneWidget);

    // 2. Milestone Metrics
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Trips'), findsOneWidget);
    expect(find.text('4/9'), findsOneWidget);
    expect(find.text('Provinces'), findsOneWidget);
    expect(find.text('98%'), findsOneWidget);
    expect(find.text('Safety Score'), findsOneWidget);
    expect(find.text('48.5kg'), findsOneWidget);
    expect(find.text('CO₂ Offset'), findsOneWidget);

    // 3. Segmented Navigation Bar
    expect(find.text('Safety & SOS'), findsOneWidget);
    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Vault'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // 4. Default View: Safety & SOS
    expect(find.text('Offline SOS & Emergency Vault'), findsOneWidget);
    expect(find.text('Emergency GPS Beacon'), findsOneWidget);
    expect(find.text('Nearest Emergency Facilities'), findsOneWidget);
    expect(find.text('Sigiriya Tourist Police Station'), findsOneWidget);
    expect(find.text('Dambulla Base General Hospital (24/7 ER)'), findsOneWidget);
    expect(find.text('1912'), findsOneWidget);
    expect(find.text('1990'), findsOneWidget);
    expect(find.text('+94 11 289 0123'), findsOneWidget);
    expect(find.text('Dilani Wijesinghe'), findsOneWidget); // Next-of-Kin
  });

  testWidgets('ProfileTabScreen: switching to Preferences segment allows toggling pacing, spice, and currency', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableProfileTab());
    await tester.pumpAndSettle();

    // Tap "Preferences" segment
    await tester.tap(find.text('Preferences'));
    await tester.pumpAndSettle();

    // Verify Preferences View renders
    expect(find.text('Corridor Travel Preferences'), findsOneWidget);
    expect(find.text('Hill Country Route Pacing'), findsOneWidget);
    expect(find.text('Preferred Vehicle Class'), findsOneWidget);
    expect(find.text('Dietary & Spice Tolerance'), findsOneWidget);
    expect(find.text('Settlement Currency & Guide Language'), findsOneWidget);

    // Toggle Hill Country Pacing from Scenic Buffers to Direct Express
    expect(find.text('Direct Express'), findsOneWidget);
    await tester.tap(find.text('Direct Express'));
    await tester.pumpAndSettle();

    expect(find.text('Updated Route Pacing to Direct Express'), findsOneWidget);

    // Toggle Spice Sensitivity to Fiery Sri Lankan
    expect(find.text('Fiery Sri Lankan'), findsOneWidget);
    await tester.tap(find.text('Fiery Sri Lankan'));
    await tester.pumpAndSettle();

    expect(find.text('Spice tolerance set to Fiery Sri Lankan'), findsOneWidget);

    // Toggle Currency to LKR (Rs)
    expect(find.text('LKR (Rs)'), findsOneWidget);
    await tester.tap(find.text('LKR (Rs)'));
    await tester.pumpAndSettle();

    expect(find.text('Default billing currency switched to LKR (Rs)'), findsOneWidget);
  });

  testWidgets('ProfileTabScreen: switching to Vault segment displays encrypted documents and inspection modal', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableProfileTab());
    await tester.pumpAndSettle();

    // Tap "Vault" segment
    await tester.tap(find.text('Vault'));
    await tester.pumpAndSettle();

    // Verify Documents
    expect(find.text('Digital Documents Vault'), findsOneWidget);
    expect(find.text('Sri Lanka Electronic Travel Authorization (ETA)'), findsOneWidget);
    expect(find.text('Allianz Global Travel Insurance Policy'), findsOneWidget);
    expect(find.text('International Passport'), findsOneWidget);
    expect(find.text('Automobile Association Ceylon (AAC) Permit'), findsOneWidget);

    // Tap "View Details" on ETA visa
    final viewDetailsButtons = find.text('View Details');
    expect(viewDetailsButtons, findsWidgets);
    await tester.tap(viewDetailsButtons.first);
    await tester.pumpAndSettle();

    // Verify Document Inspection Modal
    expect(find.text('Universal Check-in Token'), findsNothing);
    expect(find.text('Document Number'), findsOneWidget);
    expect(find.text('ETA-2026-LK-88319'), findsOneWidget);
    expect(find.text('Offline PDF'), findsOneWidget);
  });

  testWidgets('ProfileTabScreen: switching to Settings segment manages biometric app lock and offline cache', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableProfileTab());
    await tester.pumpAndSettle();

    // Tap "Settings" segment
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Verify Settings View
    expect(find.text('Account & Device Security'), findsOneWidget);
    expect(find.text('Biometric App Lock'), findsOneWidget);
    expect(find.text('Offline Route & Map Caching'), findsOneWidget);
    expect(find.text('Motion Sickness Assistance Kit'), findsOneWidget);
    expect(find.text('PayHere Visa •••• 4022'), findsOneWidget);
    expect(find.text('Clear Offline Corridor Cache (142 MB)'), findsOneWidget);

    // Tap Clear Cache
    await tester.tap(find.text('Clear Offline Corridor Cache (142 MB)'));
    await tester.pumpAndSettle();

    expect(find.text('Local cache cleared (142 MB freed)'), findsOneWidget);
  });

  testWidgets('ProfileTabScreen: Digital QR Pass modal opens universal check-in token and SLTDA accreditation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableProfileTab());
    await tester.pumpAndSettle();

    // Tap "Digital QR Pass" button on DigitalPassportCard
    await tester.tap(find.text('Digital QR Pass'));
    await tester.pumpAndSettle();

    // Verify QR Pass Modal
    expect(find.text('TRAVERZA DIGITAL PASS'), findsOneWidget);
    expect(find.text('Universal Check-in Token'), findsOneWidget);
    expect(find.text('ACTIVE & VERIFIED'), findsOneWidget);
    expect(find.text('TRV-LK-9041-INTL'), findsOneWidget);
    expect(find.text('Add to Digital Wallet'), findsOneWidget);
  });

  testWidgets('ProfileTabScreen: SOS Beacon modal opens live GPS telemetry with Sigiriya coordinates', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableProfileTab());
    await tester.pumpAndSettle();

    // Tap SOS button in emergency beacon card
    await tester.tap(find.text('SOS'));
    await tester.pumpAndSettle();

    // Verify Alert Dialog
    expect(find.text('Trigger SOS Beacon?'), findsOneWidget);
    expect(find.text('Current GPS Telemetry:'), findsOneWidget);
    expect(find.text('Dispatch SOS Now'), findsOneWidget);

    // Tap Dispatch SOS Now
    await tester.tap(find.text('Dispatch SOS Now'));
    await tester.pumpAndSettle();

    expect(find.text('SOS Beacon Dispatched to Rescue Desk (+94 11 289 0123) & 1990 Ambulance'), findsOneWidget);
  });

  testWidgets('ProfileTabScreen: renders seamlessly on narrow mobile screens (340dp width) without RenderFlex overflow', (WidgetTester tester) async {
    // Exact screen width constraints where overflow was observed (e.g. 339.4dp width)
    tester.view.physicalSize = const Size(340, 750);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 1. Tab 0: Safety & SOS
    await tester.pumpWidget(buildTestableProfileTab(initialSegment: 0));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Nearest Emergency Facilities'), findsOneWidget);
    expect(find.text('TRAVERZA PASSPORT'), findsOneWidget);

    // 2. Tab 1: Preferences
    await tester.tap(find.text('Preferences'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Corridor Travel Preferences'), findsOneWidget);

    // 3. Tab 2: Vault
    await tester.tap(find.text('Vault'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Digital Documents Vault'), findsOneWidget);

    // 4. Tab 3: Settings
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Account & Device Security'), findsOneWidget);
  });
}
