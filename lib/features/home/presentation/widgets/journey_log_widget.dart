import 'package:flutter/material.dart';
import '../../../study/domain/models/study_session_model.dart';
import '../../../../theme/app_colors.dart';

/// Widget showing recent study sessions as journey log entries
/// Displays recent activity in diary entry style
class JourneyLogWidget extends StatelessWidget {
  final List<StudySession> sessions;

  const JourneyLogWidget({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBrown.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBrown.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.skyBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_stories,
                  size: 18,
                  color: AppColors.skyBlue,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Recent Discoveries",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primaryBrown,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _viewAllSessions(context),
                child: Text(
                  "View All",
                  style: TextStyle(
                    color: AppColors.primaryBrown.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Session entries
          ...sessions
              .take(5)
              .map((session) => _buildLogEntry(context, session)),
        ],
      ),
    );
  }

  /// Build individual log entry
  Widget _buildLogEntry(BuildContext context, StudySession session) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.parchmentWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryBrown.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Time indicator
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _getSessionColor(session),
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 12),

            // Session info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getSessionTitle(session),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        _formatRelativeTime(session.startTime),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${session.durationMinutes} minutes",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      if (session.notes.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.note,
                          size: 12,
                          color: AppColors.primaryGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Notes",
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryGold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // XP earned
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.treasureGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars, size: 10, color: AppColors.treasureGreen),
                  const SizedBox(width: 2),
                  Text(
                    "+${_calculateXP(session.durationMinutes)}",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.treasureGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get session color based on duration
  Color _getSessionColor(StudySession session) {
    if (session.durationMinutes >= 60) {
      return AppColors.treasureGreen; // Long session
    } else if (session.durationMinutes >= 30) {
      return AppColors.primaryGold; // Medium session
    } else {
      return AppColors.skyBlue; // Short session
    }
  }

  /// Get session title (placeholder - would normally come from subject name)
  String _getSessionTitle(StudySession session) {
    // In real implementation, would fetch subject name by ID
    return "Study Session"; // Placeholder
  }

  /// Format relative time (e.g., "2 hours ago")
  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d ago";
    } else {
      return "${(difference.inDays / 7).floor()}w ago";
    }
  }

  /// Calculate XP earned from duration
  int _calculateXP(int minutes) {
    return (minutes / 10).floor(); // 1 XP per 10 minutes
  }

  /// Handle view all sessions
  void _viewAllSessions(BuildContext context) {
    // TODO: Navigate to full session history
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Full session history coming soon!"),
        backgroundColor: AppColors.skyBlue,
      ),
    );
  }
}
