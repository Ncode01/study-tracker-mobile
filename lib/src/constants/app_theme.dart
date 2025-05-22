import 'package:flutter/material.dart';
import 'package:study/src/constants/app_colors.dart';

/// The dark theme for the application.
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: AppColors.backgroundColor,
  cardColor: AppColors.cardColor,
  hintColor: AppColors.accentColor,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.textColor),
    bodyMedium: TextStyle(color: AppColors.textColor),
    titleMedium: TextStyle(color: AppColors.textColor),
    headlineSmall: TextStyle(color: AppColors.textColor),
    headlineMedium: TextStyle(
      color: AppColors.textColor,
    ), // Used for _counter in default app
    displaySmall: TextStyle(color: AppColors.textColor),
    displayMedium: TextStyle(color: AppColors.textColor),
    displayLarge: TextStyle(color: AppColors.textColor),
    titleLarge: TextStyle(color: AppColors.textColor),
  ),
  appBarTheme: const AppBarTheme(
    color: AppColors.backgroundColor,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.textColor),
    titleTextStyle: TextStyle(
      color: AppColors.textColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.cardColor,
    selectedItemColor: AppColors.primaryColor,
    unselectedItemColor: AppColors.secondaryTextColor,
    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
    type: BottomNavigationBarType.fixed,
  ),
  cardTheme: CardTheme(
    color: AppColors.cardColor,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: AppColors.textColor,
  ),
  iconTheme: const IconThemeData(color: AppColors.textColor),
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primaryColor,
    brightness: Brightness.dark,
    surface: AppColors.cardColor,
    primary: AppColors.primaryColor,
    secondary: AppColors.accentColor,
    onPrimary: AppColors.textColor,
    onSecondary: AppColors.textColor,
    onSurface: AppColors.textColor,
    onError: Colors.red, // Example error color
  ),
);
