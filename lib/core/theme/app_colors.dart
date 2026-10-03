import 'package:flutter/material.dart';

/// Centralized color palette for the EnergyWatch application.
/// Provides rich, accessible, energy-focused tones with support for both light & dark modes.
class AppColors {
  // Primary Palette (Emerald / Deep Forest)
  static const Color primary = Color(0xFF047857); // Emerald 700
  static const Color primaryLight = Color(0xFF10B981); // Emerald 500
  static const Color primaryDark = Color(0xFF064E3B); // Emerald 900
  static const Color primaryContainer = Color(0xFFD1FAE5); // Emerald 100
  static const Color onPrimaryContainer = Color(0xFF065F46);

  // Secondary Palette (Teal & Cyan)
  static const Color secondary = Color(0xFF0D9488); // Teal 600
  static const Color secondaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color secondaryContainer = Color(0xFFCCFBF1); // Teal 100
  static const Color onSecondaryContainer = Color(0xFF115E59);

  // Status & Semantic Colors
  static const Color success = Color(0xFF10B981); // Positive savings
  static const Color successBg = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B); // Amber / peak usage
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color alert = Color(0xFFEF4444); // High consumption / alert
  static const Color alertBg = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF3B82F6); // Blue info
  static const Color infoBg = Color(0xFFEFF6FF);

  // Neutrals - Light Theme
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate 200
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF475569); // Slate 600
  static const Color lightTextMuted = Color(0xFF94A3B8); // Slate 400

  // Neutrals - Dark Theme
  static const Color darkBackground = Color(0xFF0B1320); // Deep Navy-Slate
  static const Color darkSurface = Color(0xFF152238);
  static const Color darkSurfaceVariant = Color(0xFF1E2E4A);
  static const Color darkBorder = Color(0xFF283B5E);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Chart & Metric Gradients
  static const List<Color> energyGradient = [
    Color(0xFF047857),
    Color(0xFF10B981),
    Color(0xFF34D399),
  ];

  static const List<Color> savingsGradient = [
    Color(0xFF0D9488),
    Color(0xFF14B8A6),
  ];

  static const List<Color> peakGradient = [
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
  ];
}
