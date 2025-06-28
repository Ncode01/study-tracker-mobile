import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/dashboard_providers.dart';
import '../widgets/explorer_welcome_card.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/continent_progress_card.dart';
import '../widgets/journey_log_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_skeleton.dart';
import '../../../../theme/app_colors.dart';
import '../../../study/providers/study_providers.dart';
import '../../../study/domain/models/subject_model.dart';

/// Home screen displaying the explorer's dashboard
/// Shows personalized greeting, study progress, and recent activity
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsyncValue = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(context, ref),
      body: RefreshIndicator(
        onRefresh: () => _refreshDashboard(ref),
        child: dashboardAsyncValue.when(
          loading: () => const LoadingSkeleton(),
          error: (error, stack) => _buildErrorState(context, ref, error),
          data: (dashboardData) {
            if (dashboardData.subjectProgress.isEmpty &&
                dashboardData.recentSessions.isEmpty) {
              return const EmptyStateWidget();
            }

            return _buildDashboardContent(context, ref, dashboardData);
          },
        ),
      ),
      floatingActionButton: _buildCompassFAB(context),
    );
  }

  /// Build the app bar with explorer theme
  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      title: Text(
        "Explorer's Journal",
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.primaryBrown,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline, color: AppColors.primaryBrown),
          onPressed: () => _navigateToProfile(context),
        ),
        IconButton(
          icon: const Icon(
            Icons.settings_outlined,
            color: AppColors.primaryBrown,
          ),
          onPressed: () => _navigateToSettings(context),
        ),
      ],
    );
  }

  /// Build the main dashboard content
  Widget _buildDashboardContent(
    BuildContext context,
    WidgetRef ref,
    dashboardData,
  ) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Welcome card with greeting and streak
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ExplorerWelcomeCard(dashboardData: dashboardData),
          ),
        ),

        // Quick actions row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: QuickActionsRow(),
          ),
        ),

        // Section header for subjects
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              "Your Exploration Map",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Subject progress cards
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: _buildSubjectProgressList(ref, dashboardData.subjectProgress),
        ),

        // Recent activity section
        if (dashboardData.recentSessions.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                "Recent Discoveries",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryBrown,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: JourneyLogWidget(sessions: dashboardData.recentSessions),
            ),
          ),
        ],

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  /// Build subject progress list
  Widget _buildSubjectProgressList(WidgetRef ref, List subjectProgress) {
    if (subjectProgress.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.explore_outlined,
                size: 64,
                color: AppColors.primaryBrown.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                "No subjects added yet",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Add your first subject to start tracking your learning journey!",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final progress = subjectProgress[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ContinentProgressCard(progress: progress),
        );
      }, childCount: subjectProgress.length),
    );
  }

  /// Build error state
  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.errorRed.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              "Oops! Something went wrong",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              "We couldn't load your dashboard. Please try again.",
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _refreshDashboard(ref),
              icon: const Icon(Icons.refresh),
              label: const Text("Try Again"),
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
    );
  }

  /// Build floating action button (compass)
  Widget _buildCompassFAB(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return FloatingActionButton.extended(
          onPressed: () => _startStudySession(context, ref),
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.textOnSecondary,
          elevation: 8,
          icon: const Icon(Icons.explore, size: 24),
          label: const Text(
            "Start Quest",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }

  /// Refresh dashboard data
  Future<void> _refreshDashboard(WidgetRef ref) async {
    await ref.read(refreshDashboardProvider);
  }

  /// Navigate to profile screen
  void _navigateToProfile(BuildContext context) {
    context.push('/profile');
  }

  /// Navigate to settings screen
  void _navigateToSettings(BuildContext context) {
    context.push('/settings');
  }

  /// Start new study session
  void _startStudySession(BuildContext context, WidgetRef ref) async {
    try {
      // Get available subjects
      final subjects = await ref.read(subjectsProvider.future);

      if (!context.mounted) return;

      if (subjects.isEmpty) {
        // No subjects available - redirect to subject creation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Create your first subject to start studying!"),
            backgroundColor: AppColors.primaryBrown,
          ),
        );
        // Navigate to subject creation
        if (context.mounted) {
          context.push('/subjects/create');
        }
        return;
      }

      // Show subject selector dialog
      final selectedSubject = await _showSubjectSelector(context, subjects);

      if (selectedSubject != null && context.mounted) {
        // Navigate to study session screen
        context.push('/study/session', extra: selectedSubject);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to load subjects. Please try again."),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  /// Show subject selector dialog
  Future<Subject?> _showSubjectSelector(
    BuildContext context,
    List<Subject> subjects,
  ) async {
    return showDialog<Subject>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Choose Your Quest',
            style: TextStyle(
              color: AppColors.primaryBrown,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryGold,
                    child: Text(
                      subject.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: AppColors.textOnSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    subject.name,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text('Tap to start exploring'),
                  onTap: () => Navigator.of(context).pop(subject),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
