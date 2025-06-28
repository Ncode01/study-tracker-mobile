import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

/// Placeholder screen for progress/analytics features
/// Will be replaced with full progress tracking implementation
class ProgressPlaceholderScreen extends StatelessWidget {
  const ProgressPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Journey Progress"),
        backgroundColor: AppColors.skyBlue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up, size: 80, color: AppColors.skyBlue),
              SizedBox(height: 24),
              Text(
                "Progress Analytics",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.inkBlack,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Track your learning journey with detailed analytics, progress charts, and achievement milestones.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.fadeGray,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        "Coming Soon Features:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkBlack,
                        ),
                      ),
                      SizedBox(height: 12),
                      _FeatureItem(
                        icon: Icons.bar_chart,
                        text: "Study time analytics",
                      ),
                      _FeatureItem(
                        icon: Icons.show_chart,
                        text: "Progress trends",
                      ),
                      _FeatureItem(
                        icon: Icons.emoji_events,
                        text: "Achievement tracking",
                      ),
                      _FeatureItem(
                        icon: Icons.calendar_today,
                        text: "Study streak counters",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.skyBlue),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: AppColors.fadeGray),
          ),
        ],
      ),
    );
  }
}
