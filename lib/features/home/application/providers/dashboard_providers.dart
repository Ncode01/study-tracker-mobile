import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/models/home_dashboard_data.dart';
import '../../domain/models/study_progress.dart';
import '../../domain/models/explorer_stats.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../../study/providers/study_providers.dart';
import '../../../../providers/auth_provider.dart';

// Repository provider
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final subjectRepository = ref.watch(subjectRepositoryProvider);
  final sessionRepository = ref.watch(studySessionRepositoryProvider);

  return DashboardRepositoryImpl(
    subjectRepository: subjectRepository,
    sessionRepository: sessionRepository,
  );
});

// Main dashboard data provider
final dashboardDataProvider = FutureProvider<HomeDashboardData>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    throw Exception('User not authenticated');
  }

  return repository.getDashboardData(user.uid);
});

// Individual data providers for more granular updates
final studyProgressProvider = FutureProvider<List<StudyProgress>>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return [];
  }

  return repository.getStudyProgress(user.uid);
});

final explorerStatsProvider = FutureProvider<ExplorerStats>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return ExplorerStats.newUser();
  }

  return repository.getExplorerStats(user.uid);
});

// Convenience providers for UI state
final selectedTimeRangeProvider = StateProvider<TimeRange>(
  (ref) => TimeRange.thisWeek,
);

final dashboardRefreshProvider = StateProvider<bool>((ref) => false);

// Provider to trigger refresh
final refreshDashboardProvider = Provider<Future<void>>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  if (user != null) {
    await repository.clearCache(user.uid);
    // Invalidate the data provider to trigger refresh
    ref.invalidate(dashboardDataProvider);
  }
});

/// Time range enum for filtering dashboard data
enum TimeRange {
  thisWeek('This Week'),
  thisMonth('This Month'),
  allTime('All Time');

  const TimeRange(this.label);
  final String label;
}
