import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../study/domain/models/subject_model.dart';

/// Placeholder screen for study sessions
/// This will be replaced with a full implementation in Phase 2C
class StudySessionPlaceholderScreen extends StatelessWidget {
  final Subject? subject;

  const StudySessionPlaceholderScreen({super.key, this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          subject != null ? 'Exploring ${subject!.name}' : 'Study Session',
        ),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.textOnSecondary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Show subject info if available
              if (subject != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGold.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primaryGold,
                        child: Text(
                          subject!.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.textOnSecondary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        subject!.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              Icon(
                Icons.timer_outlined,
                size: 80,
                color: AppColors.primaryGold,
              ),
              const SizedBox(height: 24),
              Text(
                'Study Timer Coming Soon!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryBrown,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'This feature will include:\n\n'
                '• Pomodoro-style study timer\n'
                '• Progress tracking and XP rewards\n'
                '• Study notes and session analytics\n'
                '• Achievement unlocks',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrown,
                  foregroundColor: AppColors.parchmentWhite,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
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
