import '../models/home_dashboard_data.dart';
import '../models/study_progress.dart';
import '../models/explorer_stats.dart';

/// Repository interface for home dashboard data
/// Aggregates data from multiple sources to provide dashboard information
abstract class DashboardRepository {
  /// Get complete dashboard data for a user
  Future<HomeDashboardData> getDashboardData(String userId);

  /// Get study progress for all user's subjects
  Future<List<StudyProgress>> getStudyProgress(String userId);

  /// Get explorer statistics and achievements
  Future<ExplorerStats> getExplorerStats(String userId);

  /// Refresh dashboard data (force reload from all sources)
  Future<HomeDashboardData> refreshDashboardData(String userId);

  /// Get cached dashboard data if available
  HomeDashboardData? getCachedDashboardData(String userId);

  /// Clear cached data for a user
  Future<void> clearCache(String userId);
}
