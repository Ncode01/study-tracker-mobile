import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/data/local/app_database.dart';

class HubCountdown {
  const HubCountdown({
    required this.title,
    required this.daysRemaining,
    required this.accentColor,
  });

  final String title;
  final int daysRemaining;
  final Color accentColor;
}

class HubSession {
  const HubSession({
    required this.title,
    required this.timeLabel,
    required this.durationLabel,
  });

  final String title;
  final String timeLabel;
  final String durationLabel;
}

class HubSubject {
  const HubSubject({
    required this.id,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.goalLabel,
    required this.progress,
    required this.sessions,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color accentColor;
  final String goalLabel;
  final double progress;
  final List<HubSession> sessions;
}

class HubViewState {
  const HubViewState({
    required this.countdowns,
    required this.subjects,
    required this.expandedSubjectId,
  });

  final List<HubCountdown> countdowns;
  final List<HubSubject> subjects;
  final String? expandedSubjectId;
}

class HubViewNotifier extends AsyncNotifier<HubViewState> {
  @override
  Future<HubViewState> build() async {
    return _loadState();
  }

  void toggleSubjectExpansion(String subjectId) {
    final HubViewState? current = state.valueOrNull;
    if (current == null) {
      return;
    }

    state = AsyncData(
      HubViewState(
        countdowns: current.countdowns,
        subjects: current.subjects,
        expandedSubjectId:
            current.expandedSubjectId == subjectId ? null : subjectId,
      ),
    );
  }

  Future<HubViewState> _loadState() async {
    final db = await AppDatabase.instance.database;

    final List<Map<String, Object?>> categoryRows = await db.query(
      'categories',
      orderBy: 'rowid ASC',
    );
    final List<Map<String, Object?>> sessionRows = await db.query(
      'sessions',
      orderBy: 'endedAt DESC',
      limit: 180,
    );

    if (sessionRows.isEmpty) {
      return const HubViewState(
        countdowns: <HubCountdown>[],
        subjects: <HubSubject>[],
        expandedSubjectId: null,
      );
    }

    final Map<String, ({String title, IconData icon, Color color})>
    categoryMeta = <String, ({String title, IconData icon, Color color})>{
      for (final Map<String, Object?> row in categoryRows)
        (row['id'] as String): (
          title: row['title'] as String? ?? 'Study',
          icon: IconData(
            row['iconCodePoint'] as int? ??
                Icons.auto_awesome_rounded.codePoint,
            fontFamily: row['iconFontFamily'] as String? ?? 'MaterialIcons',
          ),
          color: Color(row['accentColorValue'] as int? ?? 0xFF64748B),
        ),
    };

    final DateTime now = DateTime.now();
    final DateTime startOfToday = DateTime(now.year, now.month, now.day);

    final Map<String, List<_HubSessionRow>> sessionsByCategory =
        <String, List<_HubSessionRow>>{};
    for (final Map<String, Object?> row in sessionRows) {
      final String categoryId = row['categoryId'] as String? ?? 'idle';
      final int durationSeconds = row['durationSeconds'] as int? ?? 0;
      if (durationSeconds <= 0) {
        continue;
      }

      final DateTime endedAt = DateTime.parse(row['endedAt'] as String);
      sessionsByCategory
          .putIfAbsent(categoryId, () => <_HubSessionRow>[])
          .add(
            _HubSessionRow(endedAt: endedAt, durationSeconds: durationSeconds),
          );
    }

    final List<HubSubject> subjects = <HubSubject>[];
    final Map<String, int> trackedSecondsByCategory = <String, int>{};

    sessionsByCategory.forEach((String categoryId, List<_HubSessionRow> rows) {
      final meta =
          categoryMeta[categoryId] ??
          (
            title: _titleFromId(categoryId),
            icon: Icons.auto_awesome_rounded,
            color: const Color(0xFF64748B),
          );

      int todaySeconds = 0;
      int totalSeconds = 0;
      for (final _HubSessionRow row in rows) {
        totalSeconds += row.durationSeconds;
        if (!row.endedAt.isBefore(startOfToday)) {
          todaySeconds += row.durationSeconds;
        }
      }

      trackedSecondsByCategory[categoryId] = totalSeconds;

      final List<HubSession> sessions = rows
          .take(3)
          .map(
            (_HubSessionRow row) => HubSession(
              title: '${meta.title} focus block',
              timeLabel: _timeLabelFor(row.endedAt, startOfToday),
              durationLabel: _formatDuration(row.durationSeconds),
            ),
          )
          .toList(growable: false);

      final double progress = (todaySeconds / (2.5 * 3600)).clamp(0.0, 1.0);

      subjects.add(
        HubSubject(
          id: categoryId,
          title: meta.title,
          icon: meta.icon,
          accentColor: meta.color,
          goalLabel:
              todaySeconds == 0
                  ? 'No sessions logged today'
                  : 'Today ${_formatDuration(todaySeconds)}',
          progress: progress,
          sessions: sessions,
        ),
      );
    });

    subjects.sort((HubSubject a, HubSubject b) {
      final int aSeconds = trackedSecondsByCategory[a.id] ?? 0;
      final int bSeconds = trackedSecondsByCategory[b.id] ?? 0;
      return bSeconds.compareTo(aSeconds);
    });

    final List<HubCountdown> countdowns = subjects
        .take(4)
        .map((HubSubject s) {
          final int trackedSeconds = trackedSecondsByCategory[s.id] ?? 0;
          final int focusedHours = trackedSeconds ~/ 3600;
          final int nextMilestoneHours = ((focusedHours ~/ 5) + 1) * 5;
          final int daysRemaining = ((nextMilestoneHours - focusedHours) / 2)
              .ceil()
              .clamp(1, 30);

          return HubCountdown(
            title: s.title,
            daysRemaining: daysRemaining,
            accentColor: s.accentColor,
          );
        })
        .toList(growable: false);

    return HubViewState(
      countdowns: countdowns,
      subjects: subjects,
      expandedSubjectId: subjects.isEmpty ? null : subjects.first.id,
    );
  }

  static String _timeLabelFor(DateTime dateTime, DateTime startOfToday) {
    final String prefix =
        dateTime.isBefore(startOfToday)
            ? DateFormat('MMM d').format(dateTime)
            : 'Today';
    return '$prefix · ${DateFormat('HH:mm').format(dateTime)}';
  }

  static String _formatDuration(int seconds) {
    final Duration duration = Duration(seconds: seconds);
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);

    if (hours <= 0) {
      return '${minutes}m';
    }

    if (minutes == 0) {
      return '${hours}h';
    }

    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  static String _titleFromId(String categoryId) {
    if (categoryId.isEmpty) {
      return 'Study';
    }

    final String withSpaces = categoryId.replaceAll('-', ' ').trim();
    if (withSpaces.isEmpty) {
      return 'Study';
    }

    return withSpaces
        .split(' ')
        .map(
          (String word) =>
              word.isEmpty
                  ? ''
                  : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}

class _HubSessionRow {
  const _HubSessionRow({required this.endedAt, required this.durationSeconds});

  final DateTime endedAt;
  final int durationSeconds;
}
