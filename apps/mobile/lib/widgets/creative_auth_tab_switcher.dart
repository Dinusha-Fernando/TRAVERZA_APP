import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Ultra-Modern Creative Glassmorphic Segmented Tab Switcher for Authentication
/// Smooth animated pill indicator, subtle lagoon glow, micro-badges, and tactile response.
class CreativeAuthTabSwitcher extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<int>? onTabReselected;
  final String leftLabel;
  final String rightLabel;
  final IconData leftIcon;
  final IconData rightIcon;
  final String? leftBadge;
  final String? rightBadge;
  final double height;

  const CreativeAuthTabSwitcher({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    this.onTabReselected,
    this.leftLabel = 'Sign In',
    this.rightLabel = 'Register Account',
    this.leftIcon = Icons.login_rounded,
    this.rightIcon = Icons.person_add_alt_1_rounded,
    this.leftBadge = 'FAST',
    this.rightBadge = 'FREE',
    this.height = 54.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: const Color(0xFF021622).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: TraverzaColors.secondary.withValues(alpha: 0.12),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth - 4) / 2;

          return Stack(
            children: [
              // 1. Sliding Glowing Pill Indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                left: selectedIndex == 0 ? 0 : tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: selectedIndex == 0
                          ? const [
                              TraverzaColors.secondary,
                              Color(0xFF0E7490),
                              Color(0xFF0284C7),
                            ]
                          : const [
                              Color(0xFF0A7B83),
                              TraverzaColors.secondary,
                              Color(0xFF047857),
                            ],
                    ),
                    borderRadius: BorderRadius.circular((height - 8) / 2),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.40),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (selectedIndex == 0
                                ? TraverzaColors.secondary
                                : const Color(0xFF0A7B83))
                            .withValues(alpha: 0.45),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular((height - 8) / 2),
                    child: Stack(
                      children: [
                        // Top Glass Specular Sheen
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 1.5,
                          child: Container(
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Interactive Tab Targets Row
              Row(
                children: [
                  Expanded(
                    child: _buildTabItem(
                      index: 0,
                      label: leftLabel,
                      icon: leftIcon,
                      badge: leftBadge,
                      isSelected: selectedIndex == 0,
                    ),
                  ),
                  Expanded(
                    child: _buildTabItem(
                      index: 1,
                      label: rightLabel,
                      icon: rightIcon,
                      badge: rightBadge,
                      isSelected: selectedIndex == 1,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String label,
    required IconData icon,
    String? badge,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        if (isSelected && onTabReselected != null) {
          onTabReselected!(index);
        } else {
          onTabChanged(index);
        }
      },
      borderRadius: BorderRadius.circular((height - 8) / 2),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            fontSize: isSelected ? 13.0 : 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: isSelected ? 0.3 : 0.1,
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.65),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.20)
                      : Colors.transparent,
                ),
                child: Icon(
                  icon,
                  size: isSelected ? 16 : 15,
                  color: isSelected ? TraverzaColors.sand : Colors.white.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 5),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TraverzaColors.accent.withValues(alpha: 0.90)
                        : Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: TraverzaColors.accent.withValues(alpha: 0.4),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: isSelected ? const Color(0xFF042033) : Colors.white70,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
