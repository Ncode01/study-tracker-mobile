import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'journey_map_colors.dart';

/// Defines the application theme for the Journey Map design
/// This theme is specifically crafted to match the pixel-perfect design provided
final ThemeData journeyMapTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: JourneyMapColors.accent,
  scaffoldBackgroundColor: JourneyMapColors.background,
  textTheme: GoogleFonts.caveatTextTheme().copyWith(
    headlineLarge: GoogleFonts.caveat(
      color: JourneyMapColors.primaryText,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: GoogleFonts.caveat(
      color: JourneyMapColors.primaryText,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.caveat(
      color: JourneyMapColors.primaryText,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: GoogleFonts.caveat(
      color: JourneyMapColors.primaryText,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: GoogleFonts.caveat(
      color: JourneyMapColors.primaryText,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: GoogleFonts.caveat(
      color: JourneyMapColors.secondaryText,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    bodySmall: GoogleFonts.caveat(
      color: JourneyMapColors.secondaryText,
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    labelLarge: GoogleFonts.caveat(
      color: JourneyMapColors.primaryText,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  ),

  // App bar styling matching the design
  appBarTheme: AppBarTheme(
    elevation: 0,
    backgroundColor: JourneyMapColors.background,
    foregroundColor: JourneyMapColors.primaryText,
    centerTitle: true,
    titleTextStyle: GoogleFonts.caveat(
      color: JourneyMapColors.primaryText,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: const IconThemeData(
      color: JourneyMapColors.primaryText,
      size: 24,
    ),
  ),

  // Tab bar styling to match the design
  tabBarTheme: TabBarTheme(
    labelColor: JourneyMapColors.primaryText,
    unselectedLabelColor: JourneyMapColors.tabInactive,
    labelStyle: GoogleFonts.caveat(fontSize: 18, fontWeight: FontWeight.bold),
    unselectedLabelStyle: GoogleFonts.caveat(
      fontSize: 18,
      fontWeight: FontWeight.normal,
    ),
    indicator: const UnderlineTabIndicator(
      borderSide: BorderSide(color: JourneyMapColors.tabIndicator, width: 3.0),
    ),
    indicatorSize: TabBarIndicatorSize.label,
    dividerHeight: 0,
  ),

  // Button theme for the "Add New Stop" button
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: JourneyMapColors.buttonBackground,
      foregroundColor: JourneyMapColors.buttonText,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: JourneyMapColors.buttonBorder, width: 2),
      ),
      textStyle: GoogleFonts.caveat(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  ),

  // Card theme for itinerary items
  cardTheme: CardTheme(
    color: JourneyMapColors.cardBackground,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: JourneyMapColors.cardBorder, width: 2),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),

  // Color scheme
  colorScheme: const ColorScheme.light(
    primary: JourneyMapColors.accent,
    secondary: JourneyMapColors.buttonBackground,
    surface: JourneyMapColors.cardBackground,
    onSurface: JourneyMapColors.primaryText,
    onPrimary: JourneyMapColors.buttonText,
    onSecondary: JourneyMapColors.buttonText,
  ),
);
