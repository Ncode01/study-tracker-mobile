import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../models/user_model.dart';
import '../../../study/domain/models/study_session_model.dart';
import 'study_progress.dart';
import 'explorer_stats.dart';

part 'home_dashboard_data.freezed.dart';
part 'home_dashboard_data.g.dart';

/// Aggregated data for the home dashboard screen
/// Contains all the information needed to render the explorer's dashboard
@freezed
class HomeDashboardData with _$HomeDashboardData {
  const factory HomeDashboardData({
    required UserModel user,
    required List<StudyProgress> subjectProgress,
    required ExplorerStats stats,
    required List<StudySession> recentSessions,
    required bool hasActiveSession,
    required DateTime lastRefreshed,
  }) = _HomeDashboardData;

  factory HomeDashboardData.fromJson(Map<String, dynamic> json) =>
      _$HomeDashboardDataFromJson(json);

  /// Create empty dashboard data for new users
  factory HomeDashboardData.empty(UserModel user) {
    return HomeDashboardData(
      user: user,
      subjectProgress: [],
      stats: ExplorerStats.newUser(),
      recentSessions: [],
      hasActiveSession: false,
      lastRefreshed: DateTime.now(),
    );
  }
}

/// Extension methods for HomeDashboardData
extension HomeDashboardDataExtensions on HomeDashboardData {
  /// Whether the user has any study data
  bool get hasStudyData =>
      subjectProgress.isNotEmpty || recentSessions.isNotEmpty;

  /// Whether to show the empty state
  bool get shouldShowEmptyState =>
      subjectProgress.isEmpty && recentSessions.isEmpty;

  /// Total subjects the user is tracking
  int get totalSubjects => subjectProgress.length;

  /// Total study time this week across all subjects
  Duration get totalWeeklyTime => subjectProgress.fold(
    Duration.zero,
    (total, progress) => total + progress.weeklyTime,
  );

  /// Subjects that haven't been studied recently (more than 3 days)
  List<StudyProgress> get neglectedSubjects =>
      subjectProgress
          .where((progress) => progress.daysSinceLastStudy > 3)
          .toList();

  /// Subjects that achieved their weekly target
  List<StudyProgress> get targetAchievedSubjects =>
      subjectProgress.where((progress) => progress.targetAchieved).toList();

  /// Most recently studied subject
  StudyProgress? get mostRecentSubject {
    if (subjectProgress.isEmpty) return null;

    return subjectProgress.reduce(
      (a, b) => a.lastStudied.isAfter(b.lastStudied) ? a : b,
    );
  }

  /// Greeting message based on time of day and user data
  String get greetingMessage {
    final hour = DateTime.now().hour;
    final name = user.displayName;

    if (hour < 12) {
      return "Good morning, $name! Ready for today's adventure?";
    } else if (hour < 17) {
      return "Good afternoon, $name! How's your exploration going?";
    } else {
      return "Good evening, $name! Time for some evening discoveries?";
    }
  }

  /// Motivational message based on recent activity
  String get motivationalMessage {
    if (stats.currentStreak > 0) {
      return "🔥 ${stats.currentStreak} day streak! You're on fire!";
    } else if (recentSessions.isNotEmpty) {
      return "Welcome back! Ready to continue your journey?";
    } else {
      return "Every expert was once a beginner. Start your journey today!";
    }
  }

  /// Whether data needs refreshing (older than 5 minutes)
  bool get needsRefresh {
    final now = DateTime.now();
    return now.difference(lastRefreshed).inMinutes > 5;
  }
}
