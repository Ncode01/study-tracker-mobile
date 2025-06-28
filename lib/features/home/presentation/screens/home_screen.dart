import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/dashboard_providers.dart';
import '../widgets/explorer_welcome_card.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/continent_progress_card.dart';
import '../widgets/journey_log_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_skeleton.dart';
import '../../../../theme/app_colors.dart';

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
                color: AppColors.primaryBrown.withOpacity(0.5),
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
              color: AppColors.errorRed.withOpacity(0.7),
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
    return FloatingActionButton.extended(
      onPressed: () => _startStudySession(context),
      backgroundColor: AppColors.primaryGold,
      foregroundColor: AppColors.textOnSecondary,
      elevation: 8,
      icon: const Icon(Icons.explore, size: 24),
      label: const Text(
        "Start Quest",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  /// Refresh dashboard data
  Future<void> _refreshDashboard(WidgetRef ref) async {
    await ref.read(refreshDashboardProvider);
  }

  /// Navigate to profile screen
  void _navigateToProfile(BuildContext context) {
    // TODO: Implement navigation to profile
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile navigation coming soon!")),
    );
  }

  /// Navigate to settings screen
  void _navigateToSettings(BuildContext context) {
    // TODO: Implement navigation to settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Settings navigation coming soon!")),
    );
  }

  /// Start new study session
  void _startStudySession(BuildContext context) {
    // TODO: Implement study session start
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Study session starting coming soon!")),
    );
  }
}
