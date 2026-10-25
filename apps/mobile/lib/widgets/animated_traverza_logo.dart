import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile/theme/app_theme.dart';

/// Creative Animated TRAVERZA Brand Logo
///
/// Features:
/// - High-resolution tourism emblem ('assets/traverza_logo.jpg') with elegant squircle curvature.
/// - Atmospheric breathing glow aura in Ceylon Ocean cyan and coastal sand gold.
/// - Weightless floating sinusoidal animation.
/// - Optional rotating nautical compass ring with cardinal coordinate ticks.
/// - Interactive spring tap feedback.
/// - Test-safe execution (auto-settles when running in widget test runners).
class AnimatedTraverzaLogo extends StatefulWidget {
  final double size;
  final double? borderRadius;
  final bool showHalo;
  final bool showCompassRing;
  final bool showFloatingEffect;
  final bool? enableContinuousAnimation;
  final VoidCallback? onTap;
  final String? heroTag;

  const AnimatedTraverzaLogo({
    super.key,
    this.size = 64,
    this.borderRadius,
    this.showHalo = true,
    this.showCompassRing = false,
    this.showFloatingEffect = true,
    this.enableContinuousAnimation,
    this.onTap,
    this.heroTag,
  });

  @override
  State<AnimatedTraverzaLogo> createState() => _AnimatedTraverzaLogoState();
}

class _AnimatedTraverzaLogoState extends State<AnimatedTraverzaLogo>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _floatController;
  late final AnimationController _rotationController;
  late final AnimationController _tapController;

  late final Animation<double> _haloScale;
  late final Animation<double> _haloOpacity;
  late final Animation<double> _floatY;
  late final Animation<double> _tapScale;

  bool get _isTestEnvironment =>
      WidgetsBinding.instance.runtimeType.toString().contains('Test');

  bool get _shouldLoop =>
      (widget.enableContinuousAnimation ?? !_isTestEnvironment);

  @override
  void initState() {
    super.initState();

    // 1. Halo Pulse Controller (3.0s breathing rhythm)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _haloScale = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
    _haloOpacity = Tween<double>(begin: 0.45, end: 0.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // 2. Floating Sinusoidal Controller (2.4s gentle ocean wave float)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _floatY = Tween<double>(begin: -3.5, end: 3.5).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutQuad),
    );

    // 3. Rotating Compass Ring (16s slow 360-degree rotation)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16000),
    );

    // 4. Spring Tap Scale Controller
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _tapScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOutCubic),
    );

    if (_shouldLoop) {
      _pulseController.repeat(reverse: true);
      if (widget.showFloatingEffect) {
        _floatController.repeat(reverse: true);
      }
      if (widget.showCompassRing) {
        _rotationController.repeat();
      }
    } else {
      // One-shot entrance animation for widget test safety
      _pulseController.forward();
      _floatController.forward();
      _rotationController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _rotationController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (widget.onTap != null) {
      widget.onTap!();
    }
    await _tapController.forward();
    if (mounted) {
      await _tapController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double radius = widget.borderRadius ?? (widget.size * 0.28);
    final double haloSize = widget.size * 1.34;
    final double compassSize = widget.size * 1.48;

    Widget logoImage = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F4C6E),
            TraverzaColors.primary,
            Color(0xFF072C42),
          ],
        ),
        border: Border.all(
          color: TraverzaColors.sand.withValues(alpha: 0.65),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: TraverzaColors.accent.withValues(alpha: 0.40),
            blurRadius: 22,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1.2),
        child: Image.asset(
          'assets/traverza_logo.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [TraverzaColors.accent, TraverzaColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.travel_explore_rounded,
              size: widget.size * 0.52,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    if (widget.heroTag != null) {
      logoImage = Hero(
        tag: widget.heroTag!,
        child: logoImage,
      );
    }

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseController,
          _floatController,
          _rotationController,
          _tapController,
        ]),
        builder: (context, child) {
          final double currentFloat = widget.showFloatingEffect ? _floatY.value : 0.0;
          final double currentTapScale = _tapScale.value;

          return Transform.translate(
            offset: Offset(0, currentFloat),
            child: Transform.scale(
              scale: currentTapScale,
              child: SizedBox(
                width: widget.showCompassRing ? compassSize : (widget.showHalo ? haloSize : widget.size),
                height: widget.showCompassRing ? compassSize : (widget.showHalo ? haloSize : widget.size),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // 1. Subtle Outer Rotating Nautical Compass Ring
                    if (widget.showCompassRing)
                      Transform.rotate(
                        angle: _rotationController.value * 2 * math.pi,
                        child: Container(
                          width: compassSize,
                          height: compassSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: TraverzaColors.sand.withValues(alpha: 0.30),
                              width: 1.1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  width: 3.5,
                                  height: 6,
                                  margin: const EdgeInsets.only(top: 1),
                                  decoration: BoxDecoration(
                                    color: TraverzaColors.sand,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: 3.5,
                                  height: 6,
                                  margin: const EdgeInsets.only(bottom: 1),
                                  decoration: BoxDecoration(
                                    color: TraverzaColors.sand.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 6,
                                  height: 3.5,
                                  margin: const EdgeInsets.only(left: 1),
                                  decoration: BoxDecoration(
                                    color: TraverzaColors.accent.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: 6,
                                  height: 3.5,
                                  margin: const EdgeInsets.only(right: 1),
                                  decoration: BoxDecoration(
                                    color: TraverzaColors.accent.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // 2. Breathing Ocean Glowing Halo Aura
                    if (widget.showHalo)
                      Transform.scale(
                        scale: _haloScale.value,
                        child: Container(
                          width: haloSize,
                          height: haloSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                TraverzaColors.accent.withValues(alpha: _haloOpacity.value),
                                TraverzaColors.secondary.withValues(alpha: _haloOpacity.value * 0.5),
                                Colors.transparent,
                              ],
                              stops: const [0.2, 0.6, 1.0],
                            ),
                          ),
                        ),
                      ),

                    // 3. Central Brand Logo Image Badge
                    logoImage,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
