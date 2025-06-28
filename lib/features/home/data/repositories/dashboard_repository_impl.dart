import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/models/home_dashboard_data.dart';
import '../../domain/models/study_progress.dart';
import '../../domain/models/explorer_stats.dart';
import '../../../study/domain/repositories/subject_repository.dart';
import '../../../study/domain/repositories/study_session_repository.dart';
import '../../../study/domain/models/subject_model.dart';
import '../../../study/domain/models/study_session_model.dart';
import '../../../../models/user_model.dart';

/// Implementation of DashboardRepository using local data sources
/// Aggregates data from study repositories to create dashboard information
class DashboardRepositoryImpl implements DashboardRepository {
  final SubjectRepository _subjectRepository;
  final StudySessionRepository _sessionRepository;

  // Simple in-memory cache
  final Map<String, HomeDashboardData> _cache = {};

  DashboardRepositoryImpl({
    required SubjectRepository subjectRepository,
    required StudySessionRepository sessionRepository,
  }) : _subjectRepository = subjectRepository,
       _sessionRepository = sessionRepository;

  @override
  Future<HomeDashboardData> getDashboardData(String userId) async {
    // Check cache first
    final cached = getCachedDashboardData(userId);
    if (cached != null && !cached.needsRefresh) {
      return cached;
    }

    // Load fresh data
    return refreshDashboardData(userId);
  }

  @override
  Future<HomeDashboardData> refreshDashboardData(String userId) async {
    try {
      // Load data in parallel
      final futures = await Future.wait([
        getStudyProgress(userId),
        getExplorerStats(userId),
        _sessionRepository.getStudySessions(),
      ]);

      final studyProgress = futures[0] as List<StudyProgress>;
      final stats = futures[1] as ExplorerStats;
      final recentSessions = futures[2] as List<StudySession>;

      // Create user model (in real app, this would come from user repository)
      final user = UserModel(
        uid: userId,
        email: 'user@example.com', // Placeholder
        displayName: 'Explorer', // Placeholder
        level: _calculateLevelFromXP(stats.totalXP),
        xp: stats.totalXP,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastActiveAt: DateTime.now(),
      );

      final dashboardData = HomeDashboardData(
        user: user,
        subjectProgress: studyProgress,
        stats: stats,
        recentSessions: recentSessions.take(10).toList(), // Last 10 sessions
        hasActiveSession: false, // TODO: Check active session provider
        lastRefreshed: DateTime.now(),
      );

      // Cache the result
      _cache[userId] = dashboardData;

      return dashboardData;
    } catch (e) {
      // Return empty dashboard on error
      final user = UserModel.newUser(
        uid: userId,
        email: 'user@example.com',
        displayName: 'Explorer',
      );
      return HomeDashboardData.empty(user);
    }
  }

  @override
  Future<List<StudyProgress>> getStudyProgress(String userId) async {
    try {
      final subjects = await _subjectRepository.getSubjects();
      final sessions = await _sessionRepository.getStudySessions();

      return subjects.map((subject) {
        final subjectSessions =
            sessions
                .where((session) => session.subjectId == subject.id)
                .toList();

        return _calculateStudyProgress(subject, subjectSessions);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<ExplorerStats> getExplorerStats(String userId) async {
    try {
      final sessions = await _sessionRepository.getStudySessions();
      return _calculateExplorerStats(sessions);
    } catch (e) {
      return ExplorerStats.newUser();
    }
  }

  @override
  HomeDashboardData? getCachedDashboardData(String userId) {
    return _cache[userId];
  }

  @override
  Future<void> clearCache(String userId) async {
    _cache.remove(userId);
  }

  /// Calculate study progress for a specific subject
  StudyProgress _calculateStudyProgress(
    Subject subject,
    List<StudySession> sessions,
  ) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    // Sessions this week
    final weekSessions =
        sessions
            .where((session) => session.startTime.isAfter(weekStart))
            .toList();

    // Calculate weekly time
    final weeklyTime = weekSessions.fold<Duration>(
      Duration.zero,
      (total, session) => total + Duration(minutes: session.durationMinutes),
    );

    // Last studied
    final lastStudied =
        sessions.isNotEmpty
            ? sessions
                .map((s) => s.startTime)
                .reduce((a, b) => a.isAfter(b) ? a : b)
            : DateTime.now().subtract(const Duration(days: 365));

    // Target time (2 hours per week per subject)
    const targetTime = Duration(hours: 2);
    final completionPercentage = weeklyTime.inMinutes / targetTime.inMinutes;

    return StudyProgress(
      subject: subject,
      weeklyTime: weeklyTime,
      targetTime: targetTime,
      sessionsThisWeek: weekSessions.length,
      lastStudied: lastStudied,
      completionPercentage: completionPercentage,
      nextSuggestedTopic: _getNextTopic(subject.name),
      continentEmoji: _getContinentEmoji(subject.name),
      level: _calculateSubjectLevel(weeklyTime),
      xpEarned: _calculateXPFromTime(weeklyTime),
    );
  }

  /// Calculate explorer statistics from all sessions
  ExplorerStats _calculateExplorerStats(List<StudySession> sessions) {
    if (sessions.isEmpty) {
      return ExplorerStats.newUser();
    }

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    // Sessions this week
    final weekSessions =
        sessions
            .where((session) => session.startTime.isAfter(weekStart))
            .toList();

    // Calculate total time this week
    final totalTimeThisWeek = weekSessions.fold<Duration>(
      Duration.zero,
      (total, session) => total + Duration(minutes: session.durationMinutes),
    );

    // Calculate streak
    final streak = _calculateStreak(sessions);
    final longestStreak = _calculateLongestStreak(sessions);

    // Calculate total XP
    final totalXP = sessions.fold<int>(
      0,
      (total, session) =>
          total + _calculateXPFromMinutes(session.durationMinutes),
    );

    final level = _calculateLevelFromXP(totalXP);
    final progressToNextLevel = _calculateProgressToNextLevel(totalXP);

    return ExplorerStats(
      currentStreak: streak,
      longestStreak: longestStreak,
      totalSessionsThisWeek: weekSessions.length,
      totalTimeThisWeek: totalTimeThisWeek,
      recentAchievements: _getRecentAchievements(sessions),
      progressToNextLevel: progressToNextLevel,
      currentRank: _getRankForLevel(level),
      totalXP: totalXP,
      xpToNextLevel: _getXPToNextLevel(level),
    );
  }

  /// Calculate current study streak
  int _calculateStreak(List<StudySession> sessions) {
    if (sessions.isEmpty) return 0;

    final sessionsByDate = <DateTime, List<StudySession>>{};
    for (final session in sessions) {
      final date = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      sessionsByDate.putIfAbsent(date, () => []).add(session);
    }

    final sortedDates =
        sessionsByDate.keys.toList()..sort((a, b) => b.compareTo(a));

    int streak = 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    for (final date in sortedDates) {
      final daysDiff = todayDate.difference(date).inDays;
      if (daysDiff == streak) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Calculate longest streak ever
  int _calculateLongestStreak(List<StudySession> sessions) {
    if (sessions.isEmpty) return 0;

    final sessionsByDate = <DateTime, List<StudySession>>{};
    for (final session in sessions) {
      final date = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      sessionsByDate.putIfAbsent(date, () => []).add(session);
    }

    final sortedDates = sessionsByDate.keys.toList()..sort();

    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final date in sortedDates) {
      if (lastDate == null || date.difference(lastDate).inDays == 1) {
        currentStreak++;
      } else {
        currentStreak = 1;
      }
      maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
      lastDate = date;
    }

    return maxStreak;
  }

  /// Get recent achievements based on sessions
  List<String> _getRecentAchievements(List<StudySession> sessions) {
    final achievements = <String>[];

    if (sessions.length >= 10) {
      achievements.add("10 Sessions Completed!");
    }
    if (sessions.length >= 50) {
      achievements.add("Study Marathon - 50 Sessions!");
    }

    return achievements.take(3).toList();
  }

  /// Calculate level from total XP
  int _calculateLevelFromXP(int xp) {
    return (xp / 100).floor() + 1;
  }

  /// Calculate progress to next level (0.0 to 1.0)
  double _calculateProgressToNextLevel(int xp) {
    final currentLevel = _calculateLevelFromXP(xp);
    final xpForCurrentLevel = (currentLevel - 1) * 100;
    final xpForNextLevel = currentLevel * 100;
    final progressXP = xp - xpForCurrentLevel;
    final levelXPRange = xpForNextLevel - xpForCurrentLevel;

    return progressXP / levelXPRange;
  }

  /// Get XP required to reach next level
  int _getXPToNextLevel(int level) {
    return level * 100;
  }

  /// Calculate XP from study time
  int _calculateXPFromTime(Duration time) {
    return (time.inMinutes / 10).floor(); // 1 XP per 10 minutes
  }

  /// Calculate XP from minutes
  int _calculateXPFromMinutes(int minutes) {
    return (minutes / 10).floor(); // 1 XP per 10 minutes
  }

  /// Calculate subject level from total study time
  int _calculateSubjectLevel(Duration totalTime) {
    return (totalTime.inHours / 2).floor() + 1; // Level up every 2 hours
  }

  /// Get next suggested topic for a subject
  String _getNextTopic(String subjectName) {
    final topics = {
      'Mathematics': [
        'Algebra Basics',
        'Geometry Fundamentals',
        'Calculus Introduction',
      ],
      'Science': ['Chemistry Lab', 'Physics Experiments', 'Biology Research'],
      'History': ['Ancient Civilizations', 'Modern History', 'World Wars'],
      'Language': [
        'Grammar Rules',
        'Vocabulary Building',
        'Conversation Practice',
      ],
    };

    final subjectTopics =
        topics[subjectName] ??
        ['General Study', 'Practice Exercises', 'Review Session'];
    return subjectTopics.first;
  }

  /// Get continent emoji based on subject name
  String _getContinentEmoji(String subjectName) {
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

  /// Get explorer rank based on level
  String _getRankForLevel(int level) {
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
