import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/animated_traverza_logo.dart';
import '../../../../widgets/creative_google_button.dart';
import '../../../../widgets/creative_auth_tab_switcher.dart';
import '../services/auth_service.dart';
import 'sign_in_screen.dart';
import 'register_screen.dart';

/// Full-screen Creative Welcome & Authentication Portal for TRAVERZA Sri Lanka
class WelcomeAuthScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const WelcomeAuthScreen({
    super.key,
    this.onComplete,
  });

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WelcomeAuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<WelcomeAuthScreen> createState() => _WelcomeAuthScreenState();
}

class _WelcomeAuthScreenState extends State<WelcomeAuthScreen> {
  bool _isSocialLoading = false;
  int _selectedTabIndex = 0; // 0: Sign In, 1: Register Account

  void _finishAuth([String? welcomeName]) {
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      Navigator.of(context).pop();
    }

    if (welcomeName != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ayubowan, $welcomeName! Welcome to TRAVERZA Sri Lanka.'),
          backgroundColor: TraverzaColors.secondary,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _openSignIn() {
    SignInScreen.show(context, onComplete: () {
      if (TraverzaAuthService.instance.isAuthenticated) {
        _finishAuth(TraverzaAuthService.instance.currentProfile.fullName);
      }
    });
  }

  void _openRegister() {
    RegisterScreen.show(context, onComplete: () {
      if (TraverzaAuthService.instance.isAuthenticated) {
        _finishAuth(TraverzaAuthService.instance.currentProfile.fullName);
      }
    });
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isSocialLoading = true);
    await TraverzaAuthService.instance.signInWithGoogle();
    if (!mounted) return;
    setState(() => _isSocialLoading = false);
    _finishAuth(TraverzaAuthService.instance.currentProfile.fullName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TraverzaColors.primary,
      body: Stack(
        children: [
          // 1. Ambient Background Gradients & Lagoon Tides
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF042033),
                    TraverzaColors.primary,
                    Color(0xFF064E68),
                    Color(0xFF087E8B),
                  ],
                  stops: [0.0, 0.35, 0.70, 1.0],
                ),
              ),
            ),
          ),

          // 2. Decorative Ambient Floating Radial Glows
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TraverzaColors.accent.withValues(alpha: 0.18),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.25,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TraverzaColors.secondary.withValues(alpha: 0.15),
              ),
            ),
          ),

          // 3. Foreground Interactive Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Navigation Bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.shield_outlined, size: 13, color: TraverzaColors.accent),
                                      SizedBox(width: 6),
                                      Text(
                                        'SLTDA VERIFIED GATEWAY',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                                  tooltip: 'Close',
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),

                            const Spacer(flex: 2),

                            // Brand Hero Emblem with Creative Animations
                            const AnimatedTraverzaLogo(
                              size: 72,
                              borderRadius: 22,
                              showHalo: true,
                              showCompassRing: true,
                              showFloatingEffect: true,
                              heroTag: 'welcome_traverza_logo',
                            ),
                            const SizedBox(height: 18),

                            // Title & Island Tagline
                            const Text(
                              'TRAVERZA',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'One island. One connected trip.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: TraverzaColors.accent,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Curated multi-stop Sri Lanka journeys with verified boutique stays, licensed chauffeur transfers, and certified cultural guides.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: Colors.white70,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Value Pillars Badges
                            _buildPillarsRow(),

                            const Spacer(flex: 3),

                            // Creative Animated Segmented Tab Switcher (Login vs Register)
                            CreativeAuthTabSwitcher(
                              selectedIndex: _selectedTabIndex,
                              onTabChanged: (index) {
                                setState(() => _selectedTabIndex = index);
                              },
                              onTabReselected: (index) {
                                if (index == 0) {
                                  _openSignIn();
                                } else {
                                  _openRegister();
                                }
                              },
                              leftLabel: 'Sign In',
                              rightLabel: 'Register Account',
                              leftBadge: 'VAULT',
                              rightBadge: 'FREE',
                              leftIcon: Icons.login_rounded,
                              rightIcon: Icons.person_add_alt_1_rounded,
                            ),

                            const SizedBox(height: 12),

                            // Animated Dynamic Action Deck
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 320),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(_selectedTabIndex == 0 ? -0.04 : 0.04, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: _selectedTabIndex == 0
                                  ? _buildSignInDeck()
                                  : _buildRegisterDeck(),
                            ),

                            const SizedBox(height: 14),

                            // Or Separator
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.18))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    'or 1-tap instant connect',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.50),
                                      fontSize: 11,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.18))),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Creative 1-Tap Google Sign-In with 4-Color Logo
                            CreativeGoogleButton(
                              onPressed: _isSocialLoading ? null : _handleGoogleSignIn,
                              isLoading: _isSocialLoading,
                              text: 'Continue with Google',
                              subtitle: 'Instant SLTDA-Verified 1-Tap Login',
                              variant: CreativeGoogleVariant.pearl,
                            ),

                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInDeck() {
    return Container(
      key: const ValueKey('sign_in_deck'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: TraverzaColors.secondary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.shield_outlined, size: 13, color: TraverzaColors.accent),
              ),
              const SizedBox(width: 8),
              const Text(
                'DIGITAL PASSPORT VAULT',
                style: TextStyle(
                  color: TraverzaColors.accent,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              const Text(
                '2-FACTOR READY',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Access verified Sri Lanka trips, offline emergency vault, and chauffeur transfers.',
            style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.35),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: TraverzaColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.login_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Sign In with Email',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: InkWell(
              onTap: () => setState(() => _selectedTabIndex = 1),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'New traveller in Sri Lanka? ',
                      style: TextStyle(color: Colors.white60, fontSize: 11.5),
                    ),
                    Text(
                      'Create Free Account',
                      style: TextStyle(
                        color: TraverzaColors.sand,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        decoration: TextDecoration.underline,
                        decorationColor: TraverzaColors.sand,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterDeck() {
    return Container(
      key: const ValueKey('register_deck'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TraverzaColors.secondary.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: TraverzaColors.secondary.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: TraverzaColors.accent.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.stars_rounded, size: 13, color: TraverzaColors.sand),
              ),
              const SizedBox(width: 8),
              const Text(
                'SLTDA VERIFIED PASSPORT',
                style: TextStyle(
                  color: TraverzaColors.sand,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: TraverzaColors.emeraldSuccess.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '100% FREE',
                  style: TextStyle(
                    color: Color(0xFF6EE7B7),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Instant digital passport with QR clearance, SOS vault, and direct chauffeur booking.',
            style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.35),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: TraverzaColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.badge_outlined, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Create Free Account',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: InkWell(
              onTap: () => setState(() => _selectedTabIndex = 0),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.white60, fontSize: 11.5),
                    ),
                    Text(
                      'Sign In with Email',
                      style: TextStyle(
                        color: TraverzaColors.accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        decoration: TextDecoration.underline,
                        decorationColor: TraverzaColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarsRow() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPillarItem(Icons.verified_outlined, 'SLTDA Verified', 'Stays & Guides'),
          Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.15)),
          _buildPillarItem(Icons.route_outlined, 'Corridor Graph', 'Real-Time Sync'),
          Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.15)),
          _buildPillarItem(Icons.lock_clock_outlined, 'Escrow Safety', 'Double-Entry'),
        ],
      ),
    );
  }

  Widget _buildPillarItem(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(icon, size: 18, color: TraverzaColors.accent),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 9, color: Colors.white60),
        ),
      ],
    );
  }
}
