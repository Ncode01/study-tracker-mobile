import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

/// Placeholder screen for goals setting features
/// Will be replaced with full goal management implementation
class GoalsPlaceholderScreen extends StatelessWidget {
  const GoalsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quest Goals"),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flag_outlined, size: 80, color: AppColors.primaryGold),
              SizedBox(height: 24),
              Text(
                "Set Your Goals",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.inkBlack,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Define your learning objectives and track your progress towards mastering new subjects.",
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
                        icon: Icons.schedule,
                        text: "Daily study time goals",
                      ),
                      _FeatureItem(
                        icon: Icons.auto_stories,
                        text: "Subject mastery targets",
                      ),
                      _FeatureItem(
                        icon: Icons.calendar_view_week,
                        text: "Weekly learning streaks",
                      ),
                      _FeatureItem(
                        icon: Icons.emoji_events,
                        text: "Achievement milestones",
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
          Icon(icon, size: 20, color: AppColors.primaryGold),
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
