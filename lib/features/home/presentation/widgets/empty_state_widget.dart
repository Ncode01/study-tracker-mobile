import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

/// Empty state widget for new users
/// Shows when user has no subjects or study sessions yet
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),

          // Main illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGold.withOpacity(0.1),
              border: Border.all(
                color: AppColors.primaryGold.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.explore,
              size: 80,
              color: AppColors.primaryGold,
            ),
          ),

          const SizedBox(height: 32),

          // Welcome title
          Text(
            "Welcome, Explorer!",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.primaryBrown,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            "Your learning adventure begins here! Add your first subject to start tracking your educational journey.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // Getting started steps
          _buildGettingStartedCard(context),

          const SizedBox(height: 32),

          // Primary action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _addFirstSubject(context),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Add Your First Subject"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrown,
                foregroundColor: AppColors.parchmentWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Secondary action
          TextButton.icon(
            onPressed: () => _exploreFeatures(context),
            icon: Icon(
              Icons.help_outline,
              color: AppColors.primaryBrown.withOpacity(0.7),
            ),
            label: Text(
              "Learn How It Works",
              style: TextStyle(color: AppColors.primaryBrown.withOpacity(0.7)),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Build the getting started guidance card
  Widget _buildGettingStartedCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBrown.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBrown.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primaryGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Getting Started",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryBrown,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ..._buildSteps(context),
        ],
      ),
    );
  }

  /// Build the getting started steps
  List<Widget> _buildSteps(BuildContext context) {
    final steps = [
      {
        'icon': Icons.subject,
        'title': 'Add Subjects',
        'description': 'Create subjects for different topics you want to learn',
      },
      {
        'icon': Icons.timer,
        'title': 'Track Study Time',
        'description': 'Start study sessions and track your learning progress',
      },
      {
        'icon': Icons.trending_up,
        'title': 'Level Up',
        'description': 'Earn XP, maintain streaks, and unlock achievements',
      },
    ];

    return steps.map((step) => _buildStepItem(context, step)).toList();
  }

  /// Build individual step item
  Widget _buildStepItem(BuildContext context, Map<String, dynamic> step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryBrown.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              step['icon'] as IconData,
              size: 16,
              color: AppColors.primaryBrown,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step['title'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  step['description'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Handle add first subject action
  void _addFirstSubject(BuildContext context) {
    // TODO: Navigate to add subject screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Add subject feature coming soon!"),
        backgroundColor: AppColors.primaryBrown,
      ),
    );
  }

  /// Handle explore features action
  void _exploreFeatures(BuildContext context) {
    // TODO: Show app tour or help screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Help guide coming soon!"),
        backgroundColor: AppColors.infoBlue,
      ),
    );
  }
}
