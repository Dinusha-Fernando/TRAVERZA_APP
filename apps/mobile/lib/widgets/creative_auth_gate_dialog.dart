import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../features/auth/services/auth_service.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import 'animated_traverza_logo.dart';
import 'creative_google_button.dart';

/// Ultra-Modern Creative Authentication Clearance Gate
/// Creatively enforces verified traveller account creation before accessing
/// Community Pulse dispatches and government-regulated Bookings.
class CreativeAuthGateSheet extends StatefulWidget {
  final String featureTitle;
  final String actionMessage;
  final String clearanceReason;
  final IconData featureIcon;

  const CreativeAuthGateSheet({
    super.key,
    required this.featureTitle,
    required this.actionMessage,
    required this.clearanceReason,
    this.featureIcon = Icons.shield_outlined,
  });

  /// Shows the creative clearance sheet.
  /// Returns `true` if the user successfully completed authentication or registration.
  static Future<bool> show(
    BuildContext context, {
    required String featureTitle,
    required String actionMessage,
    required String clearanceReason,
    IconData featureIcon = Icons.shield_outlined,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreativeAuthGateSheet(
        featureTitle: featureTitle,
        actionMessage: actionMessage,
        clearanceReason: clearanceReason,
        featureIcon: featureIcon,
      ),
    );
    return result ?? false;
  }

  @override
  State<CreativeAuthGateSheet> createState() => _CreativeAuthGateSheetState();
}

class _CreativeAuthGateSheetState extends State<CreativeAuthGateSheet> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final success = await TraverzaAuthService.instance.signInWithGoogle();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success && TraverzaAuthService.instance.isAuthenticated) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ayubowan, ${TraverzaAuthService.instance.currentProfile.fullName}! Clearance granted.',
          ),
          backgroundColor: TraverzaColors.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openRegister() {
    RegisterScreen.show(context, onComplete: () {
      if (TraverzaAuthService.instance.isAuthenticated) {
        Navigator.of(context).pop(true);
      }
    });
  }

  void _openSignIn() {
    SignInScreen.show(context, onComplete: () {
      if (TraverzaAuthService.instance.isAuthenticated) {
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      constraints: BoxConstraints(maxHeight: size.height * 0.90),
      decoration: BoxDecoration(
        color: const Color(0xFF031622),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.50),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
          BoxShadow(
            color: TraverzaColors.secondary.withValues(alpha: 0.20),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ambient Decorative Glow
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    TraverzaColors.accent.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    TraverzaColors.secondary.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Scrollable Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(22, 14, 22, MediaQuery.of(context).viewInsets.bottom + 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Top SLTDA Clearance Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: TraverzaColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: TraverzaColors.accent.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.shield_outlined, size: 14, color: TraverzaColors.accent),
                      SizedBox(width: 6),
                      Text(
                        'SLTDA PASSPORT CLEARANCE REQUIRED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: TraverzaColors.sand,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Animated Brand Emblem
                const AnimatedTraverzaLogo(
                  size: 64,
                  borderRadius: 20,
                  showHalo: true,
                  showCompassRing: true,
                  showFloatingEffect: true,
                  heroTag: 'auth_gate_traverza_logo',
                ),
                const SizedBox(height: 14),

                // Main Headline
                Text(
                  'Account Required for ${widget.featureTitle}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  widget.clearanceReason,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.white70,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),

                // Target Action Pill Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: TraverzaColors.accent.withValues(alpha: 0.20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(widget.featureIcon, size: 16, color: TraverzaColors.accent),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'REQUESTED ACTION',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: TraverzaColors.sand,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.actionMessage,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.lock_outline_rounded, size: 16, color: Colors.white54),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Three Clearance Pillars
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniPillar(Icons.verified_outlined, 'Official ID', 'SLTDA Verified'),
                      Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.15)),
                      _buildMiniPillar(Icons.lock_clock_outlined, 'Double-Entry', 'Escrow Safety'),
                      Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.15)),
                      _buildMiniPillar(Icons.bolt_rounded, '1-Tap Sync', 'Instant Access'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Primary 1-Tap Google Sign-In with 4-Color Logo
                CreativeGoogleButton(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  isLoading: _isLoading,
                  text: 'Continue with Google',
                  subtitle: 'Instant SLTDA-Verified 1-Tap Clearance',
                  variant: CreativeGoogleVariant.pearl,
                ),
                const SizedBox(height: 12),

                // Secondary Create Free Account Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _openRegister,
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
                        Icon(Icons.person_add_alt_1_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Create Free Account (60s)',
                          style: TextStyle(
                            fontSize: 14,
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
                const SizedBox(height: 12),

                // Tertiary Sign In with Email
                Center(
                  child: InkWell(
                    onTap: _isLoading ? null : _openSignIn,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Already registered? ',
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                          Text(
                            'Sign In with Email',
                            style: TextStyle(
                              color: TraverzaColors.sand,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                              decorationColor: TraverzaColors.sand,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPillar(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(icon, size: 15, color: TraverzaColors.accent),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 8.5, color: Colors.white54),
        ),
      ],
    );
  }
}
