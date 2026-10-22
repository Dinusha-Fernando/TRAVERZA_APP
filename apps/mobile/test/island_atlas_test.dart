import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/atlas/presentation/destination_details_screen.dart';
import 'package:mobile/features/atlas/presentation/district_overview_screen.dart';
import 'package:mobile/features/atlas/presentation/district_passport_screen.dart';
import 'package:mobile/features/atlas/presentation/island_atlas_screen.dart';
import 'package:mobile/features/atlas/services/island_atlas_service.dart';
import 'package:mobile/screens/home_screen.dart';
import 'package:mobile/theme/app_theme.dart';

void main() {
  setUp(() {
    IslandAtlasService().resetToBaseline();
  });

  group('IslandAtlasService Unit Tests', () {
    test('Official Sri Lanka administrative hierarchy: 9 provinces and 25 districts', () {
      final service = IslandAtlasService();
      expect(service.provinces.length, equals(9));
      expect(service.districts.length, equals(25));

      // Ensure every district belongs to a valid province
      final provinceIds = service.provinces.map((p) => p.id).toSet();
      for (final district in service.districts) {
        expect(provinceIds.contains(district.provinceId), isTrue,
            reason: 'District ${district.name} has invalid provinceId ${district.provinceId}');
      }
    });

    test('Multi-lingual destination search works across English, Sinhala, and Tamil', () {
      final service = IslandAtlasService();

      // Search by English
      final sigiriyaResults = service.searchDestinations(query: 'Sigiriya');
      expect(sigiriyaResults.isNotEmpty, isTrue);
      expect(sigiriyaResults.first.slug, equals('sigiriya-ancient-citadel'));

      // Search by Sinhala
      final sinhalaResults = service.searchDestinations(query: 'සීගිරිය');
      expect(sinhalaResults.isNotEmpty, isTrue);

      // Search by Tamil
      final tamilResults = service.searchDestinations(query: 'யாழ்ப்பாணம்');
      expect(tamilResults.isNotEmpty, isTrue);
      expect(tamilResults.first.districtId, equals('jaffna'));
    });

    test('District Passport: stamping records date, journal notes, and increments count', () {
      final service = IslandAtlasService();
      expect(service.stampedCount, equals(4)); // Colombo, Kandy, Matale, Nuwara Eliya stamped by default

      final success = service.stampDistrict(
        'galle',
        notes: 'Explored the Dutch Ramparts at sunset with cinnamon tea.',
      );

      expect(success, isTrue);
      expect(service.stampedCount, equals(5));
      expect(service.isDistrictStamped('galle'), isTrue);
      expect(service.passportProgress, closeTo(5 / 25, 0.01));

      final galleStamp = service.getStamp('galle');
      expect(galleStamp, isNotNull);
      expect(galleStamp!.notes, contains('Dutch Ramparts'));
    });

    test('TripGraph Day Planner: generates feasible sequential itinerary with road buffers', () {
      final service = IslandAtlasService();
      final dayPlan = service.buildDistrictDayPlan(
        districtId: 'matale',
        availableHours: 8,
      );

      expect(dayPlan['districtName'], equals('Matale'));
      expect((dayPlan['stops'] as List).length, greaterThanOrEqualTo(2));
      expect(dayPlan['totalDurationMins'], greaterThan(0));
      expect(dayPlan['feasibility'], equals('FEASIBLE'));
      expect(dayPlan['notes'].toString(), contains('mountain & coastal'));
    });
  });

  group('Island Atlas UI & Widget Tests', () {
    testWidgets('IslandAtlasScreen: renders 9 provinces carousel, 25 districts chips, and places',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const IslandAtlasScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header & Passport Banner
      expect(find.text('TRAVERZA Island Atlas'), findsOneWidget);
      expect(find.text('DISTRICT PASSPORT'), findsOneWidget);
      expect(find.text('4 of 25 Districts Explored (16%)'), findsOneWidget);

      // Verify 9 Provinces Section
      expect(find.text('Nine Official Provinces'), findsOneWidget);
      expect(find.textContaining('Central'), findsWidgets);
      expect(find.textContaining('Southern'), findsWidgets);
      expect(find.textContaining('Northern'), findsWidgets);

      // Verify Curated Collections Rail
      expect(find.text('Curated Island Themes'), findsOneWidget);
      expect(find.text('Ancient Kingdoms & Sacred Cities'), findsOneWidget);

      // Verify Places Feed
      expect(find.textContaining('Verified Places'), findsOneWidget);
      expect(find.text('Sigiriya Ancient Citadel & Water Gardens'), findsOneWidget);

      // Test Search Filter
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'Nallur');
      await tester.pumpAndSettle();

      expect(find.text('Nallur Kandaswamy Kovil'), findsOneWidget);
      expect(find.text('Sigiriya Ancient Citadel & Water Gardens'), findsNothing);
    });

    testWidgets('DistrictOverviewScreen: renders stories, specialties, and day planner button',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const DistrictOverviewScreen(districtId: 'matale'),
        ),
      );
      await tester.pumpAndSettle();

      // Header and Story
      expect(find.text('Matale'), findsOneWidget);
      expect(find.textContaining('Scenic spice estate corridor'), findsOneWidget);
      expect(find.text('OFFICIAL 25-DISTRICT SCOPE'), findsOneWidget);

      // What makes this district special rail
      expect(find.text('What Makes This District Special?'), findsOneWidget);
      expect(find.text('Sigiriya Lion Rock Citadel & Spice Valleys'), findsOneWidget);

      // Build Day Plan button
      expect(find.text('Build Day Plan'), findsOneWidget);

      // Tap "Build Day Plan" to open modal sheet
      await tester.tap(find.text('Build Day Plan'));
      await tester.pumpAndSettle();

      // Verify DistrictDayPlanSheet modal is presented
      expect(find.text('Build a Day in Matale'), findsOneWidget);
      expect(find.text('TripGraph validated timing & buffer feasibility'), findsOneWidget);
      expect(find.text('Add Plan to My Trip'), findsOneWidget);
    });

    testWidgets('DestinationDetailsScreen: displays verified SLTDA license, fees, safety, and action',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final service = IslandAtlasService();
      final destination = service.getDestinationBySlug('sigiriya-ancient-citadel')!;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: DestinationDetailsScreen(destination: destination),
        ),
      );
      await tester.pumpAndSettle();

      // Title and Tag
      expect(find.text('Sigiriya Ancient Citadel & Water Gardens'), findsOneWidget);
      expect(find.textContaining('UNESCO World Heritage 5th Century Citadel'), findsOneWidget);

      // SLTDA Evidence Badge
      expect(find.text('SLTDA Verified Travel Record'), findsOneWidget);

      // Practical Details: Hours & Fees
      expect(find.text('06:30 - 17:30 daily'), findsOneWidget);
      expect(find.text('LKR 100 (Locals) / \$36 USD (Foreigners)'), findsOneWidget);

      // Safety & Terrain Caution
      expect(find.text('Terrain & Safety Guidance'), findsOneWidget);
      expect(find.textContaining('1,200 steep spiral metal steps'), findsWidgets);

      // Add to Trip Button
      final addButton = find.text('Add to My Trip');
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verify SnackBar confirmation
      expect(find.textContaining('added to your draft trip!'), findsOneWidget);
    });

    testWidgets('DistrictPassportScreen: shows 25-district stamp grid and enables check-in',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const DistrictPassportScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Title & Progress Bar
      expect(find.text('District Passport'), findsWidgets);
      expect(find.text('Sri Lanka 25-District Journal'), findsOneWidget);
      expect(find.text('4 of 25 Districts Explored'), findsOneWidget);

      // Colombo, Kandy, Matale, Nuwara Eliya should show VISITED badge
      expect(find.text('VISITED'), findsNWidgets(4));

      // Tap on an unstamped district e.g. Galle to open check-in dialog
      final galleCard = find.text('Galle');
      expect(galleCard, findsOneWidget);
      await tester.tap(galleCard);
      await tester.pumpAndSettle();

      // Check-in dialog
      expect(find.text('Galle'), findsWidgets);
      expect(find.text('Stamp Visit'), findsOneWidget);

      // Fill in travel memory and confirm stamp
      final noteField = find.byType(TextField);
      await tester.enterText(noteField, 'Sunset walk along ramparts');
      await tester.tap(find.text('Stamp Visit'));
      await tester.pumpAndSettle();

      // Progress should now be 5 of 25
      expect(find.text('5 of 25 Districts Explored'), findsOneWidget);
      expect(find.text('VISITED'), findsNWidgets(5));
    });

    testWidgets('HomeScreen: Island Atlas banner is visible and taps into IslandAtlasScreen',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: Scaffold(
            body: HomeScreen(
              hasActiveTrip: true,
              isHotelConfirmed: true,
              onNavigateToPlan: () {},
              onCategorySelected: (_) {},
              onNavigateToSafety: () {},
              onNavigateToCatalogue: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Banner presence
      expect(find.byKey(const Key('home_island_atlas_card')), findsOneWidget);
      expect(find.text('ISLAND ATLAS'), findsWidgets);
      expect(find.text('Discover Sri Lanka District by District'), findsOneWidget);

      // Drag to scroll down past the hero card
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -600));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('home_explore_atlas_button')));
      await tester.pumpAndSettle();

      // Verify we navigated into IslandAtlasScreen
      expect(find.text('TRAVERZA Island Atlas'), findsOneWidget);
      expect(find.text('Nine Official Provinces'), findsOneWidget);
    });
  });
}
