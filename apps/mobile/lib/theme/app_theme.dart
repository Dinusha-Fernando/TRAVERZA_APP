import 'package:flutter/material.dart';

/// Traverza — Ocean Blue Color Palette
/// Official Design System
class TraverzaColors {
  // Primary & Secondary Brand Tokens
  static const Color primary = Color(0xFF073B5C); // PRIMARY — Deep Ocean Blue (Navigation, headers, primary buttons)
  static const Color primaryHover = Color(0xFF052B43); // Button hover / pressed
  static const Color secondary = Color(0xFF087E8B); // SECONDARY — Tropical Teal (Secondary buttons, interactive, selected nav)
  static const Color accent = Color(0xFF22B8CF); // ACCENT — Crystal Sea (Highlights, links, active states)
  static const Color sand = Color(0xFFF4E7D0); // BACKGROUND ACCENT — Coastal Sand (Destination cards, warm surfaces)
  static const Color background = Color(0xFFF7FAFC); // MAIN BACKGROUND — Sea Mist (App screens, cards, content areas)
  static const Color surface = Color(0xFFFFFFFF); // Card background & Bottom navigation
  static const Color text = Color(0xFF102A43); // Main text
  static const Color textMuted = Color(0xFF627D98); // Secondary text
  static const Color border = Color(0xFFD9E5EC); // Borders and dividers
  static const Color rating = Color(0xFFF59E0B); // OPTIONAL ACCENT — Sunset Gold (Ratings, special offers)

  // Semantic
  static const Color emeraldSuccess = Color(0xFF10B981);
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color roseEmergency = Color(0xFFE11D48);

  // Cohesive backward-compatible aliases mapped to Ocean Blue palette
  static const Color oceanBlue = primary;
  static const Color deepNavy = text;
  static const Color lagoonTeal = secondary;
  static const Color crystalSea = accent;
  static const Color warmSand = sand;
  static const Color darkScaffold = background;
  static const Color surfaceNavy = surface;
  static const Color surfaceElevated = surface;
  static const Color borderSubtle = border;
  static const Color textPrimary = text;
  static const Color textSecondary = textMuted;
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: TraverzaColors.background,
      primaryColor: TraverzaColors.primary,
      colorScheme: const ColorScheme.light(
        primary: TraverzaColors.primary,
        secondary: TraverzaColors.secondary,
        surface: TraverzaColors.surface,
        error: TraverzaColors.roseEmergency,
      ),
      cardTheme: CardThemeData(
        color: TraverzaColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: TraverzaColors.border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TraverzaColors.surface,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: TraverzaColors.text),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: TraverzaColors.surface,
        selectedItemColor: TraverzaColors.secondary,
        unselectedItemColor: TraverzaColors.textMuted,
      ),
    );
  }

  // Alias for backward compatibility
  static ThemeData get darkTheme => theme;
}
