import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../../study/domain/models/subject_model.dart';
import '../../../study/providers/study_providers.dart';

/// Quick action buttons for navigation shortcuts
/// Provides easy access to common app features
class QuickActionsRow extends ConsumerWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Start Session action
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.play_circle_outline,
              label: "Start Session",
              color: AppColors.treasureGreen,
              onTap: () => _startSession(context, ref),
            ),
          ),

          const SizedBox(width: 12),

          // View Progress action
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.trending_up,
              label: "Progress",
              color: AppColors.skyBlue,
              onTap: () => _viewProgress(context),
            ),
          ),

          const SizedBox(width: 12),

          // Set Goals action
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.flag_outlined,
              label: "Goals",
              color: AppColors.primaryGold,
              onTap: () => _setGoals(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual action button
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Handle start session action
  Future<void> _startSession(BuildContext context, WidgetRef ref) async {
    final subjects = await ref.read(subjectRepositoryProvider).getSubjects();

    if (!context.mounted) return;

    if (subjects.isEmpty) {
      // No subjects available, prompt to create one
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Create a subject first to start studying!"),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    } // Show subject selector dialog
    final selectedSubject = await showDialog<Subject>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Choose Subject"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  subjects
                      .map(
                        (subject) => ListTile(
                          leading: const Icon(Icons.book),
                          title: Text(subject.name),
                          onTap: () => Navigator.of(context).pop(subject),
                        ),
                      )
                      .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
            ],
          ),
    );

    if (selectedSubject != null && context.mounted) {
      context.go('/study/session', extra: selectedSubject);
    }
  }

  /// Handle view progress action
  void _viewProgress(BuildContext context) {
    context.go('/progress');
  }

  /// Handle set goals action
  void _setGoals(BuildContext context) {
    context.go('/goals');
  }
}
