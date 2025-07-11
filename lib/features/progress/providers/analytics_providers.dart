import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../study/data/hive_subject_repository_impl.dart';
import '../data/repositories/local_analytics_repository_impl.dart';
import '../data/services/analytics_service.dart';
import '../domain/models/study_analytics.dart';
import '../domain/repositories/analytics_repository.dart';

// Analytics Service Provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

// Analytics Repository Provider
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final analyticsService = ref.read(analyticsServiceProvider);
  final subjectRepository = ref.read(subjectRepositoryProvider);
  return LocalAnalyticsRepositoryImpl(analyticsService, subjectRepository);
});

// Subject Repository Provider (imported from study feature)
final subjectRepositoryProvider = Provider<HiveSubjectRepositoryImpl>((ref) {
  return HiveSubjectRepositoryImpl();
});

// Time Range State Provider
final selectedTimeRangeProvider = StateProvider<AnalyticsTimeRange>((ref) {
  return AnalyticsTimeRange.week;
});

// Analytics Data Provider
final analyticsDataProvider = FutureProvider.autoDispose
    .family<StudyAnalytics, AnalyticsTimeRange>((ref, timeRange) async {
      final repository = ref.read(analyticsRepositoryProvider);
      return repository.getAnalytics(timeRange);
    });

// Current Analytics Provider (uses selected time range)
final currentAnalyticsProvider = FutureProvider.autoDispose<StudyAnalytics>((
  ref,
) async {
  final timeRange = ref.watch(selectedTimeRangeProvider);
  final repository = ref.read(analyticsRepositoryProvider);
  return repository.getAnalytics(timeRange);
});

// Subject Analytics Provider
final subjectAnalyticsProvider = FutureProvider.autoDispose
    .family<List<SubjectAnalytics>, AnalyticsTimeRange>((ref, timeRange) async {
      final repository = ref.read(analyticsRepositoryProvider);
      return repository.getSubjectAnalytics(timeRange);
    });

// Study Insights Provider
final studyInsightsProvider = FutureProvider.autoDispose
    .family<StudyInsights, AnalyticsTimeRange>((ref, timeRange) async {
      final repository = ref.read(analyticsRepositoryProvider);
      return repository.getStudyInsights(timeRange);
    });

// Achievements Provider
final achievementsProvider = FutureProvider.autoDispose
    .family<List<Achievement>, ({AnalyticsTimeRange? timeRange, bool newOnly})>(
      (ref, params) async {
        final repository = ref.read(analyticsRepositoryProvider);
        return repository.getAchievements(
          timeRange: params.timeRange,
          newOnly: params.newOnly,
        );
      },
    );

// New Achievements Provider (only new achievements)
final newAchievementsProvider = FutureProvider.autoDispose<List<Achievement>>((
  ref,
) async {
  final repository = ref.read(analyticsRepositoryProvider);
  return repository.getAchievements(newOnly: true);
});

// Study Streak Provider
final studyStreakProvider = FutureProvider.autoDispose<StudyStreak>((
  ref,
) async {
  final repository = ref.read(analyticsRepositoryProvider);
  return repository.getCurrentStreak();
});

// Weekly Goal Progress Provider
final weeklyGoalProgressProvider = FutureProvider.autoDispose<double>((
  ref,
) async {
  final repository = ref.read(analyticsRepositoryProvider);
  return repository.getWeeklyGoalProgress();
});

// Daily Study Data Provider
final dailyStudyDataProvider = FutureProvider.autoDispose
    .family<List<DailyStudyData>, ({DateTime startDate, DateTime endDate})>((
      ref,
      params,
    ) async {
      final repository = ref.read(analyticsRepositoryProvider);
      return repository.getDailyData(params.startDate, params.endDate);
    });

// Chart Display Options State
class ChartDisplayOptions {
  final bool showDataPoints;
  final bool showGrid;
  final bool showTooltips;
  final bool animationsEnabled;

  const ChartDisplayOptions({
    this.showDataPoints = true,
    this.showGrid = true,
    this.showTooltips = true,
    this.animationsEnabled = true,
  });

  ChartDisplayOptions copyWith({
    bool? showDataPoints,
    bool? showGrid,
    bool? showTooltips,
    bool? animationsEnabled,
  }) {
    return ChartDisplayOptions(
      showDataPoints: showDataPoints ?? this.showDataPoints,
      showGrid: showGrid ?? this.showGrid,
      showTooltips: showTooltips ?? this.showTooltips,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
    );
  }
}

final chartDisplayOptionsProvider = StateProvider<ChartDisplayOptions>((ref) {
  return const ChartDisplayOptions();
});

// Subject Filter State (for filtering analytics by specific subjects)
final selectedSubjectsFilterProvider = StateProvider<List<String>>((ref) {
  return []; // Empty list means show all subjects
});

// Analytics View State (for tracking which view is currently active)
enum AnalyticsView { overview, charts, subjects, achievements, insights }

final currentAnalyticsViewProvider = StateProvider<AnalyticsView>((ref) {
  return AnalyticsView.overview;
});
