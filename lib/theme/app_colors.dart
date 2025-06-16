import 'package:flutter/material.dart';

/// Color palette for Project Atlas - Traveler's Diary theme
/// Inspired by vintage maps, parchment, and adventure aesthetics
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors - Warm earth tones
  static const Color primaryBrown = Color(0xFF8B4513); // Saddle brown
  static const Color primaryGold = Color(0xFFD4AF37); // Vintage gold
  static const Color primaryCream = Color(0xFFFDF5E6); // Old lace/parchment

  // Secondary Colors - Adventure-inspired
  static const Color compassRed = Color(0xFFB22222); // Fire brick red
  static const Color treasureGreen = Color(0xFF228B22); // Forest green
  static const Color skyBlue = Color(0xFF4682B4); // Steel blue

  // Neutral Colors - Paper and ink tones
  static const Color parchmentWhite = Color(0xFFFAF0E6); // Linen
  static const Color inkBlack =
      Color(0xFF2F2F2F); // Dark gray (softer than pure black)
  static const Color fadeGray = Color(0xFF696969); // Dim gray
  static const Color lightGray = Color(0xFFD3D3D3); // Light gray

  // Status Colors - Themed for the app
  static const Color successGreen = Color(0xFF32CD32); // Lime green
  static const Color errorRed = Color(0xFFDC143C); // Crimson
  static const Color warningOrange = Color(0xFFFF8C00); // Dark orange
  static const Color infoBlue = Color(0xFF1E90FF); // Dodger blue

  // Background Colors
  static const Color backgroundLight = parchmentWhite;
  static const Color backgroundDark = Color(0xFF1C1C1C);
  static const Color surfaceLight = Color(0xFFFFFBF0); // Slightly warmer white
  static const Color surfaceDark = Color(0xFF2C2C2C);

  // Text Colors
  static const Color textPrimary = inkBlack;
  static const Color textSecondary = fadeGray;
  static const Color textOnPrimary = parchmentWhite;
  static const Color textOnSecondary = inkBlack;
}
