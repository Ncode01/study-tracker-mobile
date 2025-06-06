import 'package:flutter/material.dart';

/// Defines the color palette for the application.
// This file is now the single source of truth for the app's colors. All color references should use app_colors.dart.
class AppColors {
  /// The primary color of the application.
  static const Color primaryColor = Colors.teal;

  /// The background color of the application.
  static const Color backgroundColor = Color(0xFF121212);

  /// The card color used in the application.
  static const Color cardColor = Color(0xFF1E1E1E);

  /// The accent color of the application.
  static const Color accentColor = Colors.tealAccent;

  /// The primary text color.
  static const Color textColor = Colors.white;

  /// The secondary text color.
  static final Color? secondaryTextColor = Colors.grey[400];
}
