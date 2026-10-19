import 'dart:async';
import 'dart:math' as math;
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
  late Animation<double> _compassRotation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _subtextFadeAnimation;
  late Animation<double> _corridorProgress;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // 1. Logo Scale & Spring Bounce (0.0 -> 0.45)
    _scaleAnimation = Tween<double>(begin: 0.60, end: 1.0).animate(
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

    // 3. Glowing Wave Halo Pulse (0.2 -> 0.8)
    _haloAnimation = Tween<double>(begin: 0.85, end: 1.35).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.80, curve: Curves.easeInOut),
      ),
    );

    // 4. Subtle Compass Rose Rotation (0.1 -> 0.9)
    _compassRotation = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.10, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    // 5. Main Title Slide Up & Fade (0.35 -> 0.70)
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.65, curve: Curves.easeIn),
      ),
    );

    // 6. Subtitle, Corridor Visualizer & Status Pill Fade (0.50 -> 0.90)
    _subtextFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 0.90, curve: Curves.easeIn),
      ),
    );

    // 7. Route Traveler Progress (0.45 -> 1.0)
    _corridorProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 1.0, curve: Curves.easeInOut),
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
        onTap: _navigateToHome, // Tap anywhere to seamlessly transition
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Tropical Wave & Elevation Contour Background
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: TropicalWavePainter(
                    wavePhase: _controller.value * 2 * math.pi,
                  ),
                );
              },
            ),

            // 2. Ambient Radial Lighting Orbs
            Center(
              child: Container(
                width: size.width * 0.95,
                height: size.width * 0.95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      TraverzaColors.accent.withValues(alpha: 0.18),
                      TraverzaColors.secondary.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),

            // 3. Animated Center Content
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Center(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // A. Centerpiece: Tourism Emblem with Compass Halo Pulse
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer expanding ocean halo ring
                              Transform.scale(
                                scale: _haloAnimation.value,
                                child: Container(
                                  width: 154,
                                  height: 154,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: TraverzaColors.accent.withValues(
                                        alpha: (1.35 - _haloAnimation.value) * 0.7,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              // Rotating compass rose ring with golden markers
                              Transform.rotate(
                                angle: _compassRotation.value,
                                child: Container(
                                  width: 136,
                                  height: 136,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: TraverzaColors.rating.withValues(alpha: 0.35),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          width: 4,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: TraverzaColors.rating,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          width: 4,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: TraverzaColors.rating,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Center Emblem (with bounce scale and glowing aura)
                              Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Container(
                                    width: 112,
                                    height: 112,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: TraverzaColors.accent.withValues(alpha: 0.40),
                                          blurRadius: 36,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 8),
                                        ),
                                        BoxShadow(
                                          color: TraverzaColors.primaryHover.withValues(alpha: 0.8),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(28),
                                      child: Image.asset(
                                        'assets/traverza_logo.jpg',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                TraverzaColors.primary,
                                                TraverzaColors.secondary,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(28),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.travel_explore_rounded,
                                            size: 54,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // B. Brand Typography & Tourism Platform Title
                          SlideTransition(
                            position: _textSlideAnimation,
                            child: FadeTransition(
                              opacity: _textFadeAnimation,
                              child: Column(
                                children: [
                                  const Text(
                                    'TRAVERZA',
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 4.5,
                                      color: Colors.white,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 1.5,
                                        color: TraverzaColors.accent,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'SRI LANKA OPERATING PLATFORM',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 2.2,
                                          color: TraverzaColors.accent,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 16,
                                        height: 1.5,
                                        color: TraverzaColors.accent,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // C. Tagline & Connected Island Journey Visualizer
                          FadeTransition(
                            opacity: _subtextFadeAnimation,
                            child: Column(
                              children: [
                                const Text(
                                  'One island. One connected trip.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: TraverzaColors.sand,
                                    letterSpacing: 0.4,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Animated Corridor Waypoint Strip
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: TraverzaColors.primaryHover.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: TraverzaColors.accent.withValues(alpha: 0.18),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      // Waypoint Node Row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildWaypoint(
                                            icon: Icons.flight_takeoff_rounded,
                                            label: 'Colombo',
                                            isActive: _corridorProgress.value >= 0.0,
                                          ),
                                          _buildRouteConnector(_corridorProgress.value >= 0.35),
                                          _buildWaypoint(
                                            icon: Icons.fort_rounded,
                                            label: 'Sigiriya',
                                            isActive: _corridorProgress.value >= 0.45,
                                          ),
                                          _buildRouteConnector(_corridorProgress.value >= 0.70),
                                          _buildWaypoint(
                                            icon: Icons.terrain_rounded,
                                            label: 'Kandy',
                                            isActive: _corridorProgress.value >= 0.85,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Corridor Status Text
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 10,
                                            height: 10,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.6,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                TraverzaColors.accent,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Connecting Pilot Corridor: Colombo · Sigiriya · Kandy',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              color: TraverzaColors.sand,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // 4. Bottom SLTDA Verified Badge
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
                        color: TraverzaColors.rating,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'SLTDA Verified Travel Marketplace Standard',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.65),
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

  Widget _buildWaypoint({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? TraverzaColors.accent.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.06),
            border: Border.all(
              color: isActive ? TraverzaColors.accent : Colors.white.withValues(alpha: 0.15),
              width: 1.2,
            ),
          ),
          child: Icon(
            icon,
            size: 15,
            color: isActive ? TraverzaColors.accent : Colors.white54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? Colors.white : Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteConnector(bool isPassed) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.only(bottom: 14, left: 4, right: 4),
        decoration: BoxDecoration(
          color: isPassed
              ? TraverzaColors.accent
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

/// Custom painter rendering dynamic oceanic wave contour lines
class TropicalWavePainter extends CustomPainter {
  final double wavePhase;

  TropicalWavePainter({required this.wavePhase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = TraverzaColors.accent.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final paint2 = Paint()
      ..color = TraverzaColors.secondary.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw top undulating wave
    final path1 = Path();
    path1.moveTo(0, size.height * 0.18);
    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.18 +
          math.sin((x / size.width * 2 * math.pi) + wavePhase) * 22;
      path1.lineTo(x, y);
    }
    canvas.drawPath(path1, paint1);

    // Draw bottom ocean tide wave
    final path2 = Path();
    path2.moveTo(0, size.height * 0.82);
    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.82 +
          math.cos((x / size.width * 2 * math.pi) + wavePhase * 0.8) * 26;
      path2.lineTo(x, y);
    }
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant TropicalWavePainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase;
  }
}
