import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Main theme configuration for Project Atlas
/// Implements the traveler's diary aesthetic with Caveat and Nunito Sans fonts
class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness:
          Brightness
              .light, // Color scheme based on our traveler's diary palette
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBrown,
        secondary: AppColors.primaryGold,
        surface: AppColors.backgroundLight, // Was background
        onSurface: AppColors.textPrimary, // Was onBackground
        error: AppColors.errorRed,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnSecondary,
        onError: AppColors.parchmentWhite,
      ),

      // Typography - Caveat for headings, Nunito Sans for body
      textTheme: TextTheme(
        // Display styles - Large headings with Caveat
        displayLarge: GoogleFonts.caveat(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.12,
        ),
        displayMedium: GoogleFonts.caveat(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.16,
        ),
        displaySmall: GoogleFonts.caveat(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.22,
        ),

        // Headline styles - Medium headings with Caveat
        headlineLarge: GoogleFonts.caveat(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.25,
        ),
        headlineMedium: GoogleFonts.caveat(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.29,
        ),
        headlineSmall: GoogleFonts.caveat(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.33,
        ),

        // Title styles - Smaller headings with Caveat
        titleLarge: GoogleFonts.caveat(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.27,
        ),
        titleMedium: GoogleFonts.caveat(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.50,
        ),
        titleSmall: GoogleFonts.caveat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.43,
        ),

        // Body styles - UI text with Nunito Sans
        bodyLarge: GoogleFonts.nunitoSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.50,
        ),
        bodyMedium: GoogleFonts.nunitoSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.43,
        ),
        bodySmall: GoogleFonts.nunitoSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.33,
        ),

        // Label styles - Small UI text with Nunito Sans
        labelLarge: GoogleFonts.nunitoSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.43,
        ),
        labelMedium: GoogleFonts.nunitoSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.33,
        ),
        labelSmall: GoogleFonts.nunitoSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          height: 1.45,
        ),
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryBrown,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.caveat(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnPrimary,
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBrown,
          foregroundColor: AppColors.textOnPrimary,
          textStyle: GoogleFonts.nunitoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBrown, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
        labelStyle: GoogleFonts.nunitoSans(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.nunitoSans(color: AppColors.fadeGray),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        color: AppColors.surfaceLight,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  /// Dark theme configuration (for future implementation)
  static ThemeData get darkTheme {
    // For now, return a basic dark theme
    // This can be expanded later with proper dark mode colors
    return ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGold,
        secondary: AppColors.primaryBrown,
        surface:
            AppColors.backgroundDark, // Was background - using surface instead
      ),
    );
  }
}
