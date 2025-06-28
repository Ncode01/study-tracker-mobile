import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

/// Quick action buttons for navigation shortcuts
/// Provides easy access to common app features
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
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
              onTap: () => _startSession(context),
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
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
                color: color.withOpacity(0.2),
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
  void _startSession(BuildContext context) {
    // TODO: Navigate to study session start
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Study session feature coming soon!"),
        backgroundColor: AppColors.treasureGreen,
      ),
    );
  }

  /// Handle view progress action
  void _viewProgress(BuildContext context) {
    // TODO: Navigate to progress/analytics screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Progress analytics coming soon!"),
        backgroundColor: AppColors.skyBlue,
      ),
    );
  }

  /// Handle set goals action
  void _setGoals(BuildContext context) {
    // TODO: Navigate to goals setting screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Goals setting coming soon!"),
        backgroundColor: AppColors.primaryGold,
      ),
    );
  }
}
