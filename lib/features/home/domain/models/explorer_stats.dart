import 'package:freezed_annotation/freezed_annotation.dart';

part 'explorer_stats.freezed.dart';
part 'explorer_stats.g.dart';

/// Represents the user's explorer statistics and achievements
/// Used to display gamification elements on the home dashboard
@freezed
class ExplorerStats with _$ExplorerStats {
  const factory ExplorerStats({
    required int currentStreak,
    required int longestStreak,
    required int totalSessionsThisWeek,
    required Duration totalTimeThisWeek,
    required List<String> recentAchievements,
    required double progressToNextLevel,
    required String currentRank,
    required int totalXP,
    required int xpToNextLevel,
  }) = _ExplorerStats;

  factory ExplorerStats.fromJson(Map<String, dynamic> json) =>
      _$ExplorerStatsFromJson(json);

  /// Create default stats for new users
  factory ExplorerStats.newUser() {
    return const ExplorerStats(
      currentStreak: 0,
      longestStreak: 0,
      totalSessionsThisWeek: 0,
      totalTimeThisWeek: Duration.zero,
      recentAchievements: [],
      progressToNextLevel: 0.0,
      currentRank: "Novice Explorer",
      totalXP: 0,
      xpToNextLevel: 100,
    );
  }
}

/// Extension methods for ExplorerStats
extension ExplorerStatsExtensions on ExplorerStats {
  /// Whether the user has an active streak
  bool get hasActiveStreak => currentStreak > 0;

  /// Motivational message based on streak
  String get streakMessage {
    if (currentStreak == 0) {
      return "Start your exploration journey today!";
    } else if (currentStreak == 1) {
      return "Great start! Keep the momentum going!";
    } else if (currentStreak < 7) {
      return "Building momentum! $currentStreak days strong!";
    } else if (currentStreak < 30) {
      return "Incredible dedication! $currentStreak day streak!";
    } else {
      return "Legendary explorer! $currentStreak day streak!";
    }
  }

  /// Weekly progress summary
  String get weeklyProgressSummary {
    if (totalSessionsThisWeek == 0) {
      return "Ready to start your week of discovery?";
    } else if (totalSessionsThisWeek == 1) {
      return "1 session completed this week";
    } else {
      return "$totalSessionsThisWeek sessions completed this week";
    }
  }

  /// Time formatted as hours and minutes
  String get formattedTotalTime {
    final hours = totalTimeThisWeek.inHours;
    final minutes = totalTimeThisWeek.inMinutes % 60;

    if (hours == 0) {
      return "${minutes}m";
    } else if (minutes == 0) {
      return "${hours}h";
    } else {
      return "${hours}h ${minutes}m";
    }
  }

  /// Progress percentage for next level (0.0 to 1.0)
  double get nextLevelProgress => progressToNextLevel.clamp(0.0, 1.0);

  /// Whether user has recent achievements to show
  bool get hasRecentAchievements => recentAchievements.isNotEmpty;

  /// Get explorer rank based on level/XP
  static String getRankForLevel(int level) {
    if (level >= 50) return "Master Explorer";
    if (level >= 40) return "Legendary Pathfinder";
    if (level >= 30) return "Expert Navigator";
    if (level >= 20) return "Seasoned Adventurer";
    if (level >= 15) return "Skilled Traveler";
    if (level >= 10) return "Confident Explorer";
    if (level >= 5) return "Budding Adventurer";
    return "Novice Explorer";
  }
}
