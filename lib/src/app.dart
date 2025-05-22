import 'package:flutter/material.dart';
import 'package:study/src/constants/app_theme.dart';
import 'package:study/src/features/core_ui/screens/main_screen.dart';

/// The root widget of the application.
class AppRoot extends StatelessWidget {
  /// Creates an [AppRoot] widget.
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      home: const MainScreen(),
    );
  }
}
