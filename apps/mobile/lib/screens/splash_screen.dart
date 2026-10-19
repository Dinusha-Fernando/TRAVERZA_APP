import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  final Duration duration;
  final bool autoNavigate;

  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 2800),
    this.autoNavigate = true,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _haloAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _subtextFadeAnimation;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // 1. Logo Scale & Bounce Animation (0.0 -> 0.45)
    _scaleAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    // 2. Logo Fade In (0.0 -> 0.35)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    // 3. Glowing Compass Halo Pulse (0.25 -> 0.75)
    _haloAnimation = Tween<double>(begin: 0.8, end: 1.25).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.75, curve: Curves.easeInOut),
      ),
    );

    // 4. Main Title Slide Up & Fade (0.35 -> 0.7)
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.65, curve: Curves.easeIn),
      ),
    );

    // 5. Subtitle & Status Pill Fade (0.55 -> 0.9)
    _subtextFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.9, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    if (widget.autoNavigate) {
      _navigationTimer = Timer(widget.duration, _navigateToHome);
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainTripScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TraverzaColors.primary,
      body: InkWell(
        onTap: _navigateToHome, // Tap anywhere to skip directly
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ambient Radial Gradient Aura
            Center(
              child: Container(
                width: size.width * 0.9,
                height: size.width * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      TraverzaColors.oceanBlue.withValues(alpha: 0.22),
                      TraverzaColors.lagoonTeal.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Animated Center Content
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with Expanding Pulsing Compass Halo
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Expanding Halo Ring
                          Transform.scale(
                            scale: _haloAnimation.value,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: TraverzaColors.lagoonTeal
                                      .withValues(alpha: (1.25 - _haloAnimation.value) * 0.6),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          // Secondary Concentric Ring
                          Transform.scale(
                            scale: 0.95 + (_haloAnimation.value * 0.1),
                            child: Container(
                              width: 124,
                              height: 124,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: TraverzaColors.oceanBlue
                                      .withValues(alpha: 0.35),
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                          // Logo Emblem with Scale and Fade
                          Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: Container(
                                width: 104,
                                height: 104,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(26),
                                  boxShadow: [
                                    BoxShadow(
                                      color: TraverzaColors.oceanBlue
                                          .withValues(alpha: 0.5),
                                      blurRadius: 30,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: TraverzaColors.lagoonTeal
                                          .withValues(alpha: 0.25),
                                      blurRadius: 40,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(26),
                                  child: Image.asset(
                                    'assets/traverza_logo.jpg',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            TraverzaColors.oceanBlue,
                                            TraverzaColors.lagoonTeal,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(26),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'T',
                                        style: TextStyle(
                                          fontSize: 44,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Brand Typography Slide & Fade
                      SlideTransition(
                        position: _textSlideAnimation,
                        child: FadeTransition(
                          opacity: _textFadeAnimation,
                          child: Column(
                            children: [
                              const Text(
                                'TRAVERZA',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4.0,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 14,
                                    height: 1.5,
                                    color: TraverzaColors.lagoonTeal,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'SRI LANKA OPERATING PLATFORM',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2.0,
                                      color: TraverzaColors.lagoonTeal,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 14,
                                    height: 1.5,
                                    color: TraverzaColors.lagoonTeal,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tagline & Corridor Pill
                      FadeTransition(
                        opacity: _subtextFadeAnimation,
                        child: Column(
                          children: [
                            const Text(
                              'One island. One connected trip.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: TraverzaColors.warmSand,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 36),
                            // Corridor Status Indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: TraverzaColors.primaryHover,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.8,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        TraverzaColors.lagoonTeal,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Connecting Pilot Corridor: Colombo · Sigiriya · Kandy',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: TraverzaColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Bottom License & Trust Notice
            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: Center(
                child: FadeTransition(
                  opacity: _subtextFadeAnimation,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        size: 13,
                        color: TraverzaColors.emeraldSuccess,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'SLTDA Verified Travel Marketplace Standard',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.5),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
