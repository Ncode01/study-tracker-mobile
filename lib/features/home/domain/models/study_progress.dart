import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../study/domain/models/subject_model.dart';

part 'study_progress.freezed.dart';
part 'study_progress.g.dart';

/// Represents the study progress for a specific subject
/// Used in the home dashboard to show subject-specific progress
@freezed
class StudyProgress with _$StudyProgress {
  const factory StudyProgress({
    required Subject subject,
    required Duration weeklyTime,
    required Duration targetTime,
    required int sessionsThisWeek,
    required DateTime lastStudied,
    required double completionPercentage,
    required String nextSuggestedTopic,
    required String continentEmoji,
    required int level,
    required int xpEarned,
  }) = _StudyProgress;

  factory StudyProgress.fromJson(Map<String, dynamic> json) =>
      _$StudyProgressFromJson(json);
}

/// Extension methods for StudyProgress calculations
extension StudyProgressExtensions on StudyProgress {
  /// Whether the subject was studied today
  bool get studiedToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStudiedDay = DateTime(
      lastStudied.year,
      lastStudied.month,
      lastStudied.day,
    );
    return lastStudiedDay.isAtSameMomentAs(today);
  }

  /// Days since last study session
  int get daysSinceLastStudy {
    final now = DateTime.now();
    return now.difference(lastStudied).inDays;
  }

  /// Progress percentage clamped between 0 and 1
  double get clampedProgress => completionPercentage.clamp(0.0, 1.0);

  /// Time remaining to reach weekly target
  Duration get timeToTarget {
    if (weeklyTime >= targetTime) return Duration.zero;
    return targetTime - weeklyTime;
  }

  /// Whether weekly target is achieved
  bool get targetAchieved => weeklyTime >= targetTime;

  /// Get continent emoji based on subject name
  static String getContinentEmoji(String subjectName) {
    final lower = subjectName.toLowerCase();
    if (lower.contains('math') ||
        lower.contains('algebra') ||
        lower.contains('geometry')) {
      return '🗻'; // Mathematics - Mountain
    } else if (lower.contains('science') ||
        lower.contains('physics') ||
        lower.contains('chemistry')) {
      return '🌊'; // Science - Ocean
    } else if (lower.contains('history') || lower.contains('social')) {
      return '🏛️'; // History - Ancient structures
    } else if (lower.contains('language') ||
        lower.contains('english') ||
        lower.contains('literature')) {
      return '📚'; // Language - Books
    } else if (lower.contains('art') || lower.contains('creative')) {
      return '🎨'; // Art - Palette
    } else if (lower.contains('computer') ||
        lower.contains('coding') ||
        lower.contains('programming')) {
      return '💻'; // Computer Science - Laptop
    } else {
      return '🌍'; // General - World
    }
  }
}
