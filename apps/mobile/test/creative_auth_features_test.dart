import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/presentation/welcome_auth_screen.dart';
import 'package:mobile/features/auth/presentation/account_quick_sheet.dart';
import 'package:mobile/features/auth/presentation/auth_sheet.dart';
import 'package:mobile/features/auth/presentation/sign_in_screen.dart';
import 'package:mobile/features/auth/presentation/register_screen.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/theme/app_theme.dart';
import 'package:mobile/widgets/animated_traverza_logo.dart';
import 'package:mobile/widgets/google_logo.dart';
import 'package:mobile/widgets/creative_google_button.dart';
import 'package:mobile/widgets/creative_auth_tab_switcher.dart';
import 'package:mobile/widgets/creative_auth_gate_dialog.dart';
import 'package:mobile/features/bookings/presentation/bookings_tab_screen.dart';
import 'package:mobile/features/community/presentation/community_pulse_screen.dart';
import 'package:mobile/features/community/presentation/create_post_sheet.dart';

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

  group('Creative Authentication & Sign-In Features', () {
    testWidgets('WelcomeAuthScreen renders immersive branding, value pillars, and auth buttons', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(const WelcomeAuthScreen()));
      await tester.pumpAndSettle();

      expect(find.text('SLTDA VERIFIED GATEWAY'), findsOneWidget);
      expect(find.text('TRAVERZA'), findsOneWidget);
      expect(find.text('One island. One connected trip.'), findsOneWidget);
      expect(find.text('SLTDA Verified'), findsOneWidget);
      expect(find.text('Corridor Graph'), findsOneWidget);
      expect(find.text('Escrow Safety'), findsOneWidget);
      expect(find.text('Sign In with Email'), findsOneWidget);
      expect(find.text('Create Free Account'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
      expect(find.text('Continue as Guest Traveller'), findsNothing);
    });

    testWidgets('WelcomeAuthScreen 1-tap Google sign-in logs in user', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final auth = TraverzaAuthService.instance;
      auth.signOut();
      expect(auth.isAuthenticated, isFalse);

      await tester.pumpWidget(buildTestableWidget(const WelcomeAuthScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentProfile.fullName, 'Maya Rathnayake');
      expect(auth.currentProfile.membershipTier, 'Google Verified Traveller');
    });

    testWidgets('Apple Sign-In is cleanly omitted and Google auth is featured across screens', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(const WelcomeAuthScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Apple'), findsNothing);
      expect(find.text('Continue with Google'), findsOneWidget);

      await tester.pumpWidget(buildTestableWidget(const SignInScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Apple'), findsNothing);
      expect(find.text('Continue with Google'), findsOneWidget);

      await tester.pumpWidget(buildTestableWidget(const RegisterScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Apple'), findsNothing);
      expect(find.text('Register with Google'), findsOneWidget);
    });

    testWidgets('AccountQuickSheet displays authenticated user telemetry and actions', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final auth = TraverzaAuthService.instance;
      expect(auth.isAuthenticated, isTrue);

      await tester.pumpWidget(buildTestableWidget(const AccountQuickSheet()));
      await tester.pumpAndSettle();

      expect(find.text(auth.currentProfile.fullName), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('Digital Passport & Credentials'), findsOneWidget);
      expect(find.text('Welcome & Onboarding Portal'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('Sign Out to Guest Mode'), findsNothing);
      expect(find.text('Switch Demo Profile:'), findsNothing);
    });

    testWidgets('AuthSheet includes social login options alongside email forms', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(const AuthSheet(initialTabIndex: 0)));
      await tester.pumpAndSettle();

      expect(find.text('or continue with'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
      expect(find.text('Continue as Guest Traveller'), findsNothing);
      expect(find.text('Quick Pilot Login:'), findsNothing);
    });

    testWidgets('SignInScreen renders ambient branding and performs real email sign in action', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool completed = false;
      await tester.pumpWidget(buildTestableWidget(SignInScreen(onComplete: () => completed = true)));
      await tester.pumpAndSettle();

      expect(find.text('SLTDA SAFE CORRIDOR'), findsOneWidget);
      expect(find.text('TRAVERZA'), findsOneWidget);
      expect(find.text('Sign In to Account'), findsWidgets);
      expect(find.text('1-TAP PILOT ACCOUNT SELECTOR'), findsNothing);
      expect(find.text('New Traveller in Sri Lanka?'), findsOneWidget);

      // Enter real credentials
      final emailField = find.widgetWithText(TextFormField, 'name@example.com');
      await tester.enterText(emailField, 'verified.traveller@traverza.lk');

      final passwordField = find.widgetWithText(TextFormField, '••••••••');
      await tester.enterText(passwordField, 'SecurePassword123!');
      await tester.pumpAndSettle();

      // Tap Sign In Button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In to Account'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(TraverzaAuthService.instance.isAuthenticated, isTrue);
    });

    testWidgets('RegisterScreen renders live digital passport preview and updates dynamically with form input', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool completed = false;
      await tester.pumpWidget(buildTestableWidget(RegisterScreen(onComplete: () => completed = true)));
      await tester.pumpAndSettle();

      expect(find.text('INSTANT PASSPORT ISSUANCE'), findsOneWidget);
      expect(find.text('Register Traveller Account'), findsOneWidget);
      expect(find.text('DIGITAL PASSPORT PREVIEW'), findsOneWidget);
      expect(find.text('YOUR NAME HERE'), findsOneWidget);
      expect(find.text('SLTDA READY'), findsOneWidget);

      // Type name into Full Legal Name field
      final nameField = find.widgetWithText(TextFormField, 'e.g. Dinusha Wijesinghe');
      await tester.enterText(nameField, 'Aiden Gallagher');
      await tester.pumpAndSettle();

      // Verify the live passport preview immediately updated
      expect(find.text('Aiden Gallagher'), findsWidgets);

      // Select popular country chip (United Kingdom)
      await tester.tap(find.text('United Kingdom'));
      await tester.pumpAndSettle();

      expect(find.text('United Kingdom · Pilot Explorer'), findsOneWidget);

      // Enter remaining fields
      final emailField = find.widgetWithText(TextFormField, 'traveller@domain.com');
      await tester.enterText(emailField, 'aiden.g@traveler.org');

      final phoneField = find.widgetWithText(TextFormField, '+94 77 123 4567 or intl code');
      await tester.enterText(phoneField, '+44 7911 889900');

      final passwordField = find.widgetWithText(TextFormField, '••••••••');
      await tester.enterText(passwordField, 'SecurePassword123!');
      await tester.pumpAndSettle();

      // Check dynamic strength indicator
      expect(find.text('SLTDA Encrypted (Elite)'), findsOneWidget);

      // Submit registration
      await tester.tap(find.text('Register & Create Digital Passport'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(TraverzaAuthService.instance.isAuthenticated, isTrue);
      expect(TraverzaAuthService.instance.currentProfile.fullName, 'Aiden Gallagher');
    });

    testWidgets('SignInScreen and RegisterScreen render without RenderFlex overflow on narrow 340dp viewports', (tester) async {
      tester.view.physicalSize = const Size(340, 750);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // 1. Test SignInScreen on narrow viewport
      await tester.pumpWidget(buildTestableWidget(const SignInScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Sign In to Account'), findsWidgets);

      // 2. Test RegisterScreen on narrow viewport
      await tester.pumpWidget(buildTestableWidget(const RegisterScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Register Traveller Account'), findsOneWidget);
    });

    testWidgets('AnimatedTraverzaLogo renders logo image on Welcome, SignIn, and Register screens with tap response', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // 1. Welcome Screen
      await tester.pumpWidget(buildTestableWidget(const WelcomeAuthScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedTraverzaLogo), findsOneWidget);

      // 2. SignIn Screen
      await tester.pumpWidget(buildTestableWidget(const SignInScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedTraverzaLogo), findsOneWidget);

      // 3. Register Screen
      await tester.pumpWidget(buildTestableWidget(const RegisterScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedTraverzaLogo), findsOneWidget);

      // Tap on the logo to verify interactive micro-bounce
      await tester.tap(find.byType(AnimatedTraverzaLogo));
      await tester.pump(const Duration(milliseconds: 140));
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedTraverzaLogo), findsOneWidget);
    });

    testWidgets('CreativeGoogleButton renders 4-color Google logo, 1-TAP badge, and triggers tap', (tester) async {
      bool tapped = false;

      // 1. Pearl variant
      await tester.pumpWidget(buildTestableWidget(
        CreativeGoogleButton(
          onPressed: () => tapped = true,
          text: 'Continue with Google',
          subtitle: 'Instant 1-Tap Access',
          variant: CreativeGoogleVariant.pearl,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(GoogleColoredLogo), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Instant 1-Tap Access'), findsOneWidget);
      expect(find.text('1-TAP'), findsOneWidget);

      await tester.tap(find.byType(CreativeGoogleButton));
      expect(tapped, isTrue);

      // 2. Glass variant & Loading state
      await tester.pumpWidget(buildTestableWidget(
        CreativeGoogleButton(
          onPressed: () {},
          isLoading: true,
          variant: CreativeGoogleVariant.glass,
        ),
      ));
      await tester.pump();

      expect(find.text('Authenticating...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('WelcomeAuthScreen creative tab switcher dynamically morphs between Sign In and Register Account decks', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(const WelcomeAuthScreen()));
      await tester.pumpAndSettle();

      // Verify the CreativeAuthTabSwitcher is present with both tabs & micro-badges
      expect(find.byType(CreativeAuthTabSwitcher), findsOneWidget);
      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Register Account'), findsWidgets);
      expect(find.text('VAULT'), findsOneWidget);
      expect(find.text('FREE'), findsOneWidget);

      // Initially on Sign In deck
      expect(find.text('DIGITAL PASSPORT VAULT'), findsOneWidget);
      expect(find.text('2-FACTOR READY'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign In with Email'), findsOneWidget);

      // Tap 'Register Account' in CreativeAuthTabSwitcher
      await tester.tap(find.widgetWithText(InkWell, 'Register Account'));
      await tester.pumpAndSettle();

      // Now on Register deck
      expect(find.text('SLTDA VERIFIED PASSPORT'), findsOneWidget);
      expect(find.text('100% FREE'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Create Free Account'), findsOneWidget);

      // Tap 'Sign In' in CreativeAuthTabSwitcher to toggle back
      await tester.tap(find.widgetWithText(InkWell, 'Sign In'));
      await tester.pumpAndSettle();

      // Back to Sign In deck
      expect(find.text('DIGITAL PASSPORT VAULT'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign In with Email'), findsOneWidget);
    });

    testWidgets('CreativeAuthGateSheet renders clearance reasons, escrow badges, and 1-tap Google clearance', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(
        const CreativeAuthGateSheet(
          featureTitle: 'Verified Bookings',
          actionMessage: 'Reserve Sigiriya Luxury Transfer',
          clearanceReason: 'SLTDA consumer safety regulations require verified traveller registration.',
          featureIcon: Icons.confirmation_number_rounded,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('SLTDA PASSPORT CLEARANCE REQUIRED'), findsOneWidget);
      expect(find.text('Account Required for Verified Bookings'), findsOneWidget);
      expect(find.text('Reserve Sigiriya Luxury Transfer'), findsOneWidget);
      expect(find.text('Official ID'), findsOneWidget);
      expect(find.text('Double-Entry'), findsOneWidget);
      expect(find.text('1-Tap Sync'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Create Free Account (60s)'), findsOneWidget);
      expect(find.text('Sign In with Email'), findsOneWidget);
    });

    testWidgets('BookingsTabScreen gates My Bookings view behind creative locked vault when user is unauthenticated', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Sign out user
      TraverzaAuthService.instance.signOut();
      expect(TraverzaAuthService.instance.isAccountComplete, isFalse);

      await tester.pumpWidget(buildTestableWidget(
        const BookingsTabScreen(initialMode: BookingTabMode.myBookings),
      ));
      await tester.pumpAndSettle();

      // Check locked vault view is displayed
      expect(find.text('SLTDA Booking Vault Locked'), findsOneWidget);
      expect(find.text('SLTDA Escrow'), findsOneWidget);
      expect(find.text('Offline QR'), findsOneWidget);
      expect(find.text('Driver Sync'), findsOneWidget);
      expect(find.text('Create Account or Sign In'), findsOneWidget);
    });

    testWidgets('CommunityPulseScreen displays Guest Explorer Mode clearance banner when user is unauthenticated', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Sign out user
      TraverzaAuthService.instance.signOut();
      expect(TraverzaAuthService.instance.isAccountComplete, isFalse);

      await tester.pumpWidget(buildTestableWidget(const CommunityPulseScreen()));
      await tester.pumpAndSettle();

      // Check Guest Explorer Mode clearance banner
      expect(find.text('Guest Explorer Mode'), findsOneWidget);
      expect(find.text('Unlock'), findsOneWidget);
      expect(find.textContaining('Account required to publish moments'), findsOneWidget);
    });

    testWidgets('CreatePostSheet.show intercepts unauthenticated user with CreativeAuthGateSheet', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Sign out user
      TraverzaAuthService.instance.signOut();
      expect(TraverzaAuthService.instance.isAccountComplete, isFalse);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => CreatePostSheet.show(ctx),
                child: const Text('Trigger Post Sheet'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Trigger Post Sheet'));
      await tester.pumpAndSettle();

      // Verified clearance gate intercepted!
      expect(find.byType(CreativeAuthGateSheet), findsOneWidget);
      expect(find.text('Account Required for Community Pulse'), findsOneWidget);
      expect(find.text('Publish Live Moment & Field Reports'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
    });
  });
}

