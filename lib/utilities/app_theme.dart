import 'package:flutter/material.dart';

/// App theme configuration with a student-friendly color scheme.
class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation

  // Primary colors
  static const Color primaryColor = Color(0xFF4A6FFC); // Bright blue
  static const Color primaryDarkColor = Color(0xFF3157DD); // Darker blue
  static const Color primaryLightColor = Color(0xFF8AA5FF); // Light blue

  // Accent colors
  static const Color accentColor = Color(0xFF3DDC97); // Mint green
  static const Color accentDarkColor = Color(0xFF2DB67D); // Darker green
  static const Color accentLightColor = Color(0xFF7EECC1); // Light green

  // Background colors
  static const Color backgroundLight = Color(0xFFF8F9FC);
  static const Color backgroundDark = Color(0xFF17182E);

  // Neutral colors
  static const Color textPrimary = Color(0xFF242633);
  static const Color textSecondary = Color(0xFF6C7081);
  static const Color divider = Color(0xFFE5E7ED);

  // Success, warning, error colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);

  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: Colors.white,
      background: backgroundLight,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onBackground: textPrimary,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: backgroundLight,
    dividerColor: divider,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: backgroundLight,
      foregroundColor: textPrimary,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      buttonColor: primaryColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: const Color(0xFF242633),
      background: backgroundDark,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    dividerColor: const Color(0xFF3D3E50),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: backgroundDark,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      color: const Color(0xFF242633),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      buttonColor: primaryColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF242633),
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
