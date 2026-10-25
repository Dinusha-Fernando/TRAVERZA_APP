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

    testWidgets('EditProfileSheet allows updating profile picture via AvatarPickerSheet', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final auth = TraverzaAuthService.instance;
      expect(auth.currentProfile.avatarUrl, isNull);

      await tester.pumpWidget(
        buildTestableWidget(
          EditProfileSheet(profile: auth.currentProfile),
        ),
      );
      await tester.pumpAndSettle();

      // Find Change Profile Picture button
      expect(find.text('Change Profile Picture'), findsOneWidget);

      await tester.tap(find.text('Change Profile Picture'));
      await tester.pumpAndSettle();

      // Verify AvatarPickerSheet modal opened
      expect(find.text('Update Profile Picture'), findsOneWidget);
      expect(find.text('CURATED SRI LANKA EXPLORER STYLES'), findsOneWidget);
      expect(find.text('Custom Photo URL'), findsOneWidget);
      expect(find.text('Apply Profile Picture'), findsOneWidget);

      // Tap on the Coastal Surfer avatar preset
      final coastalFinder = find.textContaining('Coastal Surfer');
      expect(coastalFinder, findsOneWidget);
      await tester.tap(coastalFinder);
      await tester.pumpAndSettle();

      // Tap Apply Profile Picture
      await tester.tap(find.text('Apply Profile Picture'));
      await tester.pumpAndSettle();

      // Tap Save Profile Changes
      await tester.tap(find.text('Save Profile Changes'));
      await tester.pumpAndSettle();

      // Verify profile in auth service now has avatarUrl
      expect(auth.currentProfile.avatarUrl, isNotNull);
      expect(auth.currentProfile.avatarUrl, contains('images.unsplash.com'));
    });

    testWidgets('updateAvatar helper method toggles and clears photo properly', (tester) async {
      final auth = TraverzaAuthService.instance;

      auth.updateAvatar('https://custom.photos/dinusha.jpg');
      expect(auth.currentProfile.avatarUrl, 'https://custom.photos/dinusha.jpg');

      // Clear avatar (reverts to monogram initial)
      auth.updateAvatar(null);
      expect(auth.currentProfile.avatarUrl, isNull);
    });
  });

  group('TRAVERZA Authentication Flow (Sign In, Demo Switch, Sign Out)', () {
    testWidgets('Signing out displays sign-in banner and updates passport', (tester) async {
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
      expect(find.text('Sign in to save digital passport and sync bookings.'), findsOneWidget);
      expect(find.text('Traveller'), findsAtLeastNWidgets(1));
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

    testWidgets('AuthSheet renders Sign In and Register tabs with real authentication forms', (tester) async {
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
      expect(find.text('Quick Pilot Login:'), findsNothing);
      expect(find.text('Continue with Google'), findsOneWidget);

      // Enter real credentials and submit
      final emailField = find.widgetWithText(TextFormField, 'Email Address');
      await tester.enterText(emailField, 'maya.rathnayake@traverza.lk');

      final passwordField = find.widgetWithText(TextFormField, 'Password');
      await tester.enterText(passwordField, 'MayaSecurePass123!');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In to Account'));
      await tester.pumpAndSettle();

      expect(TraverzaAuthService.instance.isAuthenticated, isTrue);
    });

    testWidgets('Deleting profile prompts confirmation dialog and resets session', (tester) async {
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
      expect(auth.currentProfile.fullName, 'Traveller');
    });

    testWidgets('Safety SOS Vault remains 100% accessible even when unauthenticated', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final auth = TraverzaAuthService.instance;
      auth.signOut(); // Ensure signed out

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
