import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Data model for an item in [CreativeExperienceTabSwitcher].
class CreativeExperienceTabItem {
  final String label;
  final IconData icon;
  final String? badge;
  final Color? activeColor;
  final List<Color>? gradientColors;

  const CreativeExperienceTabItem({
    required this.label,
    required this.icon,
    this.badge,
    this.activeColor,
    this.gradientColors,
  });
}

/// Ultra-Modern Creative Glassmorphic Segmented Tab Switcher for Travel Experiences
/// Features smooth animated sliding pill indicator, ambient neon glow, micro-badges,
/// and tactile haptic response.
class CreativeExperienceTabSwitcher extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final List<CreativeExperienceTabItem> items;
  final double height;
  final bool isDarkTheme;

  const CreativeExperienceTabSwitcher({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.items,
    this.height = 50.0,
    this.isDarkTheme = true,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final bgBoxColor = isDarkTheme
        ? const Color(0xFF031826).withValues(alpha: 0.75)
        : TraverzaColors.background;
    final borderColor = isDarkTheme
        ? Colors.white.withValues(alpha: 0.16)
        : TraverzaColors.border;

    return Container(
      height: height,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: bgBoxColor,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkTheme ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
          if (isDarkTheme)
            BoxShadow(
              color: TraverzaColors.secondary.withValues(alpha: 0.12),
              blurRadius: 10,
              spreadRadius: 1,
            ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabCount = items.length;
          final tabWidth = (constraints.maxWidth - 4) / tabCount;
          final activeItem = items[selectedIndex.clamp(0, tabCount - 1)];

          final gradientColors = activeItem.gradientColors ??
              const [
                TraverzaColors.secondary,
                Color(0xFF0E7490),
                Color(0xFF0284C7),
              ];

          return Stack(
            children: [
              // 1. Sliding Glowing Pill Indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: selectedIndex * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    borderRadius: BorderRadius.circular((height - 8) / 2),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.40),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withValues(alpha: 0.45),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Interactive Tab Buttons
              Row(
                children: List.generate(tabCount, (index) {
                  final item = items[index];
                  final isSelected = selectedIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (!isSelected) {
                          HapticFeedback.selectionClick();
                          onTabChanged(index);
                        }
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDarkTheme
                                    ? Colors.white.withValues(alpha: 0.65)
                                    : TraverzaColors.textMuted),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedScale(
                                duration: const Duration(milliseconds: 240),
                                scale: isSelected ? 1.08 : 0.95,
                                child: Icon(
                                  item.icon,
                                  size: 15.5,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDarkTheme
                                          ? Colors.white.withValues(alpha: 0.65)
                                          : TraverzaColors.textMuted),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (item.badge != null) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.28)
                                        : (isDarkTheme
                                            ? Colors.white.withValues(alpha: 0.12)
                                            : Colors.black.withValues(alpha: 0.06)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.badge!,
                                    style: TextStyle(
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.3,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDarkTheme
                                              ? Colors.white.withValues(alpha: 0.8)
                                              : TraverzaColors.primary),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
