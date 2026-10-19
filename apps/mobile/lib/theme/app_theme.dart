import 'package:flutter/material.dart';

/// TRAVERZA Design Tokens & Brand System
/// Primary Palette: Ocean Blue, Deep Navy, Lagoon Teal, Warm Sand
class TraverzaColors {
  // Brand Core Colors
  static const Color oceanBlue = Color(0xFF0B6E8E); // Primary brand, buttons, active states
  static const Color deepNavy = Color(0xFF102A43); // Foundational dark, contrasts, overlays
  static const Color lagoonTeal = Color(0xFF1BA6A6); // Supporting accents, badges, discovery
  static const Color warmSand = Color(0xFFF4E7D3); // Neutral landscape warmth, subtitles
  
  // Dark Surfaces & Backgrounds
  static const Color darkScaffold = Color(0xFF070F1A); // Deep Ceylon night background
  static const Color surfaceNavy = Color(0xFF0C1929); // Primary card surface
  static const Color surfaceElevated = Color(0xFF14243B); // Elevated bento cards & popups
  static const Color borderSubtle = Color(0xFF1E3A5F); // Subtle border lines
  
  // Semantic Accents
  static const Color emeraldSuccess = Color(0xFF10B981); // Confirmed, SLTDA verified
  static const Color amberWarning = Color(0xFFF59E0B); // Action needed, pending approval
  static const Color roseEmergency = Color(0xFFE11D48); // SOS, emergency helpline
  
  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TraverzaColors.darkScaffold,
      primaryColor: TraverzaColors.oceanBlue,
      colorScheme: const ColorScheme.dark(
        primary: TraverzaColors.oceanBlue,
        secondary: TraverzaColors.lagoonTeal,
        surface: TraverzaColors.surfaceNavy,
        error: TraverzaColors.roseEmergency,
      ),
      cardTheme: CardThemeData(
        color: TraverzaColors.surfaceNavy,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: TraverzaColors.borderSubtle, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TraverzaColors.darkScaffold,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: TraverzaColors.textPrimary),
      ),
    );
  }
}
