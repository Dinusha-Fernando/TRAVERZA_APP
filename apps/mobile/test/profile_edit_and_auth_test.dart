import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/presentation/auth_sheet.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/profile/presentation/profile_tab_screen.dart';
import 'package:mobile/features/profile/presentation/widgets/edit_profile_sheet.dart';
import 'package:mobile/features/profile/presentation/widgets/delete_profile_dialog.dart';
import 'package:mobile/theme/app_theme.dart';

void main() {
  setUp(() {
    TraverzaAuthService.instance.resetToDefault();
  });

  tearDown(() {
    TraverzaAuthService.instance.resetToDefault();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.theme,
      home: Scaffold(body: child),
    );
  }

  group('TRAVERZA Profile Editing & Updating', () {
    testWidgets('EditProfileSheet allows updating legal name and contact details', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final auth = TraverzaAuthService.instance;
      expect(auth.currentProfile.fullName, 'Dinusha Wijesinghe');

      await tester.pumpWidget(
        buildTestableWidget(
          EditProfileSheet(profile: auth.currentProfile),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Traveller Profile'), findsOneWidget);
      expect(find.text('Save Profile Changes'), findsOneWidget);

      // Find the name text field and enter a new name
      final nameField = find.widgetWithText(TextFormField, 'Dinusha Wijesinghe');
      expect(nameField, findsOneWidget);

      await tester.enterText(nameField, 'Dinusha K. Wijesinghe');
      await tester.pump();

      // Tap Save Profile Changes
      await tester.tap(find.text('Save Profile Changes'));
      await tester.pumpAndSettle();

      // Verify the auth service profile was updated
      expect(auth.currentProfile.fullName, 'Dinusha K. Wijesinghe');
    });

    testWidgets('Direct profile update via TraverzaAuthService reflects in UI', (tester) async {
      final auth = TraverzaAuthService.instance;

      await tester.pumpWidget(buildTestableWidget(const ProfileTabScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Dinusha Wijesinghe'), findsAtLeastNWidgets(1));

      // Update profile dynamically
      auth.updateProfile(
        auth.currentProfile.copyWith(fullName: 'Captain Dinusha'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Captain Dinusha'), findsAtLeastNWidgets(1));
    });
  });

  group('TRAVERZA Authentication Flow (Sign In, Demo Switch, Sign Out)', () {
    testWidgets('Signing out to Guest Mode displays guest banner and updates passport', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final auth = TraverzaAuthService.instance;

      await tester.pumpWidget(buildTestableWidget(const ProfileTabScreen()));
      await tester.pumpAndSettle();

      expect(auth.isAuthenticated, isTrue);

      // Trigger sign out
      auth.signOut();
      await tester.pumpAndSettle();

      expect(auth.isAuthenticated, isFalse);
      expect(find.text('Guest Explorer Mode · Sign in to save digital passport and sync bookings.'), findsOneWidget);
      expect(find.text('Guest Traveller'), findsAtLeastNWidgets(1));
    });

    testWidgets('Switching to Demo Account updates profile immediately', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final auth = TraverzaAuthService.instance;

      await tester.pumpWidget(buildTestableWidget(const ProfileTabScreen()));
      await tester.pumpAndSettle();

      // Switch to Sarah Jenkins (index 1: Solo Backpacker)
      auth.switchDemoAccount(1);
      await tester.pumpAndSettle();

      expect(auth.currentProfile.fullName, 'Sarah Jenkins');
      expect(auth.currentProfile.nationality, 'United Kingdom');
      expect(find.text('Sarah Jenkins'), findsAtLeastNWidgets(1));

      // Switch to Alexander Wright (index 2: Luxury Couple)
      auth.switchDemoAccount(2);
      await tester.pumpAndSettle();

      expect(auth.currentProfile.fullName, 'Alexander Wright');
      expect(auth.currentProfile.nationality, 'United States');
      expect(find.text('Alexander Wright'), findsAtLeastNWidgets(1));
    });

    testWidgets('AuthSheet renders Sign In and Register tabs with 1-tap demo logins', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestableWidget(
          const AuthSheet(initialTabIndex: 0),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TRAVERZA'), findsOneWidget);
      expect(find.text('One island. One connected trip.'), findsOneWidget);
      expect(find.text('Sign In'), findsAtLeastNWidgets(1));
      expect(find.text('Register Account'), findsOneWidget);
      expect(find.text('Quick Pilot Login:'), findsOneWidget);
      expect(find.text('Sarah'), findsOneWidget);
      expect(find.text('Alexander'), findsOneWidget);

      // Tap Sarah demo button
      await tester.tap(find.text('Sarah'));
      await tester.pumpAndSettle();

      expect(TraverzaAuthService.instance.currentProfile.fullName, 'Sarah Jenkins');
      expect(TraverzaAuthService.instance.isAuthenticated, isTrue);
    });

    testWidgets('Deleting profile prompts confirmation dialog and resets to guest state', (tester) async {
      final auth = TraverzaAuthService.instance;
      expect(auth.isAuthenticated, isTrue);

      await tester.pumpWidget(
        buildTestableWidget(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => DeleteProfileDialog.show(ctx),
              child: const Text('Open Delete Dialog'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Delete Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Traveller Profile?'), findsOneWidget);
      expect(find.text('Delete Profile'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.text('Delete Profile'));
      await tester.pumpAndSettle();

      expect(auth.isAuthenticated, isFalse);
      expect(auth.currentProfile.fullName, 'Guest Traveller');
    });

    testWidgets('Safety SOS Vault remains 100% accessible even in Guest mode', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final auth = TraverzaAuthService.instance;
      auth.signOut(); // Ensure guest mode

      await tester.pumpWidget(buildTestableWidget(const ProfileTabScreen(initialSegment: 0)));
      await tester.pumpAndSettle();

      // Check offline emergency vault elements remain intact
      expect(find.text('Offline SOS & Emergency Vault'), findsOneWidget);
      expect(find.text('Nearest Emergency Facilities'), findsOneWidget);
      expect(find.text('Sigiriya Tourist Police Station'), findsOneWidget);
      expect(find.text('1912'), findsOneWidget);
      expect(find.text('1990'), findsOneWidget);
    });
  });
}
