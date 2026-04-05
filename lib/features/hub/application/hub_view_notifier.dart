import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/theme/material_category_icon_resolver.dart';
import '../../calendar/presentation/providers/calendar_providers.dart';
import '../domain/models/hub_class_schedule.dart';
import '../domain/repositories/hub_repository.dart';

class HubClassCreationOutcome {
  const HubClassCreationOutcome({
    required this.historicalSessions,
    required this.missedSessions,
    required this.watchedSessions,
    required this.pendingRecordings,
  });

  final int historicalSessions;
  final int missedSessions;
  final int watchedSessions;
  final int pendingRecordings;

  bool get hasHeavyBacklog => pendingRecordings >= 3;
}

enum HubWeeklyAttendanceAction {
  attendedLive,
  watchedRecording,
  missedNeedsCatchUp,
}

class HubWeeklyAttendancePrompt {
  const HubWeeklyAttendancePrompt({
    required this.classId,
    required this.subjectId,
    required this.subjectTitle,
    required this.teacherName,
    required this.occurrenceDate,
    required this.startMinutes,
    required this.durationMinutes,
  });

  final int classId;
  final String subjectId;
  final String subjectTitle;
  final String teacherName;
  final DateTime occurrenceDate;
  final int startMinutes;
  final int durationMinutes;

  String get occurrenceKey {
    final DateTime day = DateTime(
      occurrenceDate.year,
      occurrenceDate.month,
      occurrenceDate.day,
    );
    return '$classId|${day.toIso8601String()}';
  }
}

class HubWeeklyAttendanceResolveResult {
  const HubWeeklyAttendanceResolveResult({required this.pendingRecordings});

  final int pendingRecordings;

  bool get hasHeavyBacklog => pendingRecordings >= 3;
}

class HubClassEntry {
  const HubClassEntry({
    required this.id,
    required this.subjectId,
    required this.teacherName,
    required this.startDate,
    required this.endDate,
    required this.weekday,
    required this.startMinutes,
    required this.durationMinutes,
    required this.attendanceStatus,
    required this.recordingPlannedAt,
    required this.recordingDurationMinutes,
    required this.recordingCompleted,
    required this.pendingRecordingCount,
    required this.completedRecordingCount,
  });

  final int id;
  final String subjectId;
  final String teacherName;
  final DateTime startDate;
  final DateTime? endDate;
  final int weekday;
  final int startMinutes;
  final int durationMinutes;
  final HubAttendanceStatus attendanceStatus;
  final DateTime? recordingPlannedAt;
  final int? recordingDurationMinutes;
  final bool recordingCompleted;
  final int pendingRecordingCount;
  final int completedRecordingCount;

  bool get canPlanRecording => attendanceStatus == HubAttendanceStatus.missed;

  bool get hasRecordingBacklog {
    return pendingRecordingCount > 0 || completedRecordingCount > 0;
  }

  bool get isStopped {
    if (endDate == null) {
      return false;
    }
    final DateTime today = DateTime.now();
    final DateTime normalizedToday = DateTime(
      today.year,
      today.month,
      today.day,
    );
    return endDate!.isBefore(normalizedToday);
  }
}

class HubSubject {
  const HubSubject({
    required this.id,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.classes,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color accentColor;
  final List<HubClassEntry> classes;

  int get attendedCount {
    return classes
        .where(
          (HubClassEntry item) =>
              item.attendanceStatus == HubAttendanceStatus.attended,
        )
        .length;
  }

  int get missedCount {
    return classes
        .where(
          (HubClassEntry item) =>
              item.attendanceStatus == HubAttendanceStatus.missed,
        )
        .length;
  }

  int get pendingCount {
    return classes
        .where(
          (HubClassEntry item) =>
              item.attendanceStatus == HubAttendanceStatus.pending,
        )
        .length;
  }
}

class HubViewState {
  const HubViewState({required this.subjects, required this.expandedSubjectId});

  final List<HubSubject> subjects;
  final String? expandedSubjectId;

  HubViewState copyWith({
    List<HubSubject>? subjects,
    String? expandedSubjectId,
  }) {
    return HubViewState(
      subjects: subjects ?? this.subjects,
      expandedSubjectId: expandedSubjectId ?? this.expandedSubjectId,
    );
  }
}

class HubViewNotifier extends AsyncNotifier<HubViewState> {
  static const List<String> _subjectOrder = <String>[
    'maths',
    'physics',
    'chemistry',
  ];
  static const String _weeklyPromptProgressPrefix =
      'hub_weekly_prompt_upto_class_';

  HubRepository? _repository;

  HubRepository get _repo {
    return _repository ??= SqliteHubRepository(
      database: ref.read(databaseProvider),
    );
  }

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
      current.copyWith(
        expandedSubjectId:
            current.expandedSubjectId == subjectId ? null : subjectId,
      ),
    );
  }

  Future<void> refresh() async {
    final HubViewState? current = state.valueOrNull;
    await _reload(preferredExpandedSubjectId: current?.expandedSubjectId);
  }

  Future<HubClassCreationOutcome> addClassSession({
    required String subjectId,
    required String teacherName,
    required DateTime startDate,
    required int weekday,
    required int startMinutes,
    required int durationMinutes,
    required int historicalMissedSessions,
    required int historicalWatchedSessions,
  }) async {
    final String normalizedTeacher = teacherName.trim();
    if (normalizedTeacher.isEmpty) {
      throw const FormatException('Teacher name cannot be empty.');
    }
    if (weekday < 1 || weekday > 7) {
      throw const FormatException('Weekday must be between Monday and Sunday.');
    }
    if (startMinutes < 0 || startMinutes > 1439) {
      throw const FormatException('Class start time is invalid.');
    }
    if (durationMinutes <= 0) {
      throw const FormatException('Class duration must be greater than zero.');
    }
    if (historicalMissedSessions < 0 || historicalWatchedSessions < 0) {
      throw const FormatException(
        'Historical attendance values cannot be negative.',
      );
    }
    if (historicalWatchedSessions > historicalMissedSessions) {
      throw const FormatException(
        'Watched recordings cannot exceed missed sessions.',
      );
    }

    final HubViewState? current = state.valueOrNull;
    final String? expandedId = current?.expandedSubjectId ?? subjectId;

    state = const AsyncLoading<HubViewState>().copyWithPrevious(state);

    try {
      final int classId = await _repo.addClassSchedule(
        subjectId: subjectId,
        teacherName: normalizedTeacher,
        startDate: DateTime(startDate.year, startDate.month, startDate.day),
        weekday: weekday,
        startMinutes: startMinutes,
        durationMinutes: durationMinutes,
      );

      final HubHistoricalAttendanceSeedResult seedResult = await _repo
          .seedHistoricalAttendance(
            classId: classId,
            missedSessions: historicalMissedSessions,
            watchedSessions: historicalWatchedSessions,
          );

      await _reload(preferredExpandedSubjectId: expandedId);
      ref.invalidate(calendarViewProvider);

      return HubClassCreationOutcome(
        historicalSessions: seedResult.historicalSessions,
        missedSessions: seedResult.missedSessions,
        watchedSessions: seedResult.watchedSessions,
        pendingRecordings: seedResult.pendingRecordings,
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateAttendance({
    required int classId,
    required HubAttendanceStatus status,
  }) async {
    await _runMutation(() {
      return _repo.updateClassAttendance(classId: classId, status: status);
    });
  }

  Future<void> planRecording({
    required int classId,
    required DateTime plannedAt,
    required int durationMinutes,
  }) async {
    if (durationMinutes <= 0) {
      throw const FormatException(
        'Recording duration must be greater than zero.',
      );
    }

    await _runMutation(() {
      return _repo.scheduleRecording(
        classId: classId,
        plannedAt: plannedAt,
        durationMinutes: durationMinutes,
      );
    });
  }

  Future<void> setRecordingCompleted({
    required int classId,
    required bool completed,
  }) async {
    await _runMutation(() {
      return _repo.setRecordingCompleted(
        classId: classId,
        completed: completed,
      );
    });
  }

  Future<void> deleteClassSession({required int classId}) async {
    await _runMutation(() {
      return _repo.deleteClassSchedule(classId);
    });
  }

  Future<void> stopClassSession({
    required int classId,
    required DateTime endDate,
  }) async {
    await _runMutation(() {
      return _repo.stopClassSchedule(classId: classId, endDate: endDate);
    });
  }

  Future<List<HubWeeklyAttendancePrompt>> loadDueWeeklyAttendancePrompts({
    int limit = 12,
  }) async {
    final HubViewState? current = state.valueOrNull;
    if (current == null || limit <= 0) {
      return const <HubWeeklyAttendancePrompt>[];
    }

    final SharedPreferences preferences = ref.read(sharedPreferencesProvider);
    final DateTime now = DateTime.now();
    final DateTime today = _dateOnly(now);

    final List<HubWeeklyAttendancePrompt> prompts =
        <HubWeeklyAttendancePrompt>[];

    for (final HubSubject subject in current.subjects) {
      for (final HubClassEntry entry in subject.classes) {
        final String key = _weeklyPromptProgressKey(entry.id);
        final DateTime? lastPrompted = _parsePromptDate(
          preferences.getString(key),
        );

        final DateTime classStart = _dateOnly(entry.startDate);
        final DateTime classEndBoundary = _dateOnly(entry.endDate ?? today);
        final DateTime endDate =
            classEndBoundary.isAfter(today) ? today : classEndBoundary;

        if (classStart.isAfter(endDate)) {
          continue;
        }

        DateTime cursor = _firstOccurrenceOnOrAfter(
          startDate: classStart,
          weekday: entry.weekday,
        );

        while (!cursor.isAfter(endDate)) {
          if (lastPrompted != null && !cursor.isAfter(lastPrompted)) {
            cursor = cursor.add(const Duration(days: 7));
            continue;
          }

          if (_hasOccurrenceFinished(
            occurrenceDate: cursor,
            startMinutes: entry.startMinutes,
            durationMinutes: entry.durationMinutes,
            now: now,
          )) {
            prompts.add(
              HubWeeklyAttendancePrompt(
                classId: entry.id,
                subjectId: entry.subjectId,
                subjectTitle: subject.title,
                teacherName: entry.teacherName,
                occurrenceDate: cursor,
                startMinutes: entry.startMinutes,
                durationMinutes: entry.durationMinutes,
              ),
            );
          }

          if (prompts.length >= limit) {
            prompts.sort((
              HubWeeklyAttendancePrompt a,
              HubWeeklyAttendancePrompt b,
            ) {
              final int byDate = a.occurrenceDate.compareTo(b.occurrenceDate);
              if (byDate != 0) {
                return byDate;
              }
              return a.startMinutes.compareTo(b.startMinutes);
            });
            return prompts;
          }

          cursor = cursor.add(const Duration(days: 7));
        }
      }
    }

    prompts.sort((HubWeeklyAttendancePrompt a, HubWeeklyAttendancePrompt b) {
      final int byDate = a.occurrenceDate.compareTo(b.occurrenceDate);
      if (byDate != 0) {
        return byDate;
      }
      return a.startMinutes.compareTo(b.startMinutes);
    });
    return prompts;
  }

  Future<HubWeeklyAttendanceResolveResult> resolveWeeklyAttendancePrompt({
    required HubWeeklyAttendancePrompt prompt,
    required HubWeeklyAttendanceAction action,
  }) async {
    final HubViewState? current = state.valueOrNull;
    final String? expandedId = current?.expandedSubjectId;
    final SharedPreferences preferences = ref.read(sharedPreferencesProvider);
    int pendingRecordings = 0;

    switch (action) {
      case HubWeeklyAttendanceAction.attendedLive:
        await _repo.updateClassAttendance(
          classId: prompt.classId,
          status: HubAttendanceStatus.attended,
        );
        break;
      case HubWeeklyAttendanceAction.watchedRecording:
        await _repo.setRecordingCompleted(
          classId: prompt.classId,
          completed: true,
        );
        await _repo.updateClassAttendance(
          classId: prompt.classId,
          status: HubAttendanceStatus.attended,
        );
        break;
      case HubWeeklyAttendanceAction.missedNeedsCatchUp:
        pendingRecordings = await _repo.scheduleAutomaticRecordingCatchUp(
          classId: prompt.classId,
          occurrenceDate: prompt.occurrenceDate,
        );
        break;
    }

    await preferences.setString(
      _weeklyPromptProgressKey(prompt.classId),
      _dateOnly(prompt.occurrenceDate).toIso8601String(),
    );

    await _reload(preferredExpandedSubjectId: expandedId);
    ref.invalidate(calendarViewProvider);

    if (pendingRecordings == 0) {
      pendingRecordings = _pendingRecordingsForClass(prompt.classId);
    }

    return HubWeeklyAttendanceResolveResult(
      pendingRecordings: pendingRecordings,
    );
  }

  Future<void> _runMutation(Future<Object?> Function() mutation) async {
    final HubViewState? current = state.valueOrNull;
    final String? expandedId = current?.expandedSubjectId;

    await mutation();
    await _reload(preferredExpandedSubjectId: expandedId);
    ref.invalidate(calendarViewProvider);
  }

  int _pendingRecordingsForClass(int classId) {
    final HubViewState? current = state.valueOrNull;
    if (current == null) {
      return 0;
    }

    for (final HubSubject subject in current.subjects) {
      for (final HubClassEntry entry in subject.classes) {
        if (entry.id == classId) {
          return entry.pendingRecordingCount;
        }
      }
    }
    return 0;
  }

  String _weeklyPromptProgressKey(int classId) {
    return '$_weeklyPromptProgressPrefix$classId';
  }

  DateTime? _parsePromptDate(String? raw) {
    final DateTime? parsed = DateTime.tryParse(raw ?? '');
    if (parsed == null) {
      return null;
    }
    return _dateOnly(parsed);
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime _firstOccurrenceOnOrAfter({
    required DateTime startDate,
    required int weekday,
  }) {
    final int offset = (weekday - startDate.weekday + 7) % 7;
    return startDate.add(Duration(days: offset));
  }

  bool _hasOccurrenceFinished({
    required DateTime occurrenceDate,
    required int startMinutes,
    required int durationMinutes,
    required DateTime now,
  }) {
    final DateTime startAt = _dateOnly(
      occurrenceDate,
    ).add(Duration(minutes: startMinutes.clamp(0, 1439)));
    final DateTime endAt = startAt.add(
      Duration(minutes: durationMinutes.clamp(1, 720)),
    );
    return !endAt.isAfter(now);
  }

  Future<void> _reload({String? preferredExpandedSubjectId}) async {
    state = const AsyncLoading<HubViewState>().copyWithPrevious(state);

    try {
      final HubViewState loaded = await _loadState(
        preferredExpandedSubjectId: preferredExpandedSubjectId,
      );
      state = AsyncData(loaded);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<HubViewState> _loadState({String? preferredExpandedSubjectId}) async {
    final db = await ref.read(databaseProvider).database;

    final List<Map<String, Object?>> categoryRows = await db.query(
      'categories',
      orderBy: 'rowid ASC',
    );
    final List<HubClassSchedule> schedules = await _repo.loadClassSchedules();

    final Map<String, _HubSubjectMeta> categoryMeta = <String, _HubSubjectMeta>{
      for (final Map<String, Object?> row in categoryRows)
        (row['id'] as String? ?? ''): _HubSubjectMeta(
          title: row['title'] as String? ?? 'Study',
          icon: MaterialCategoryIconResolver.resolve(
            categoryId: row['id'] as String?,
            iconCodePoint: row['iconCodePoint'] as int?,
            iconFontFamily: row['iconFontFamily'] as String?,
            fallback: Icons.auto_awesome_rounded,
          ),
          accentColor: Color(row['accentColorValue'] as int? ?? 0xFF64748B),
        ),
    };

    final Map<String, List<HubClassSchedule>> bySubject =
        <String, List<HubClassSchedule>>{};
    for (final HubClassSchedule schedule in schedules) {
      bySubject
          .putIfAbsent(schedule.subjectId, () => <HubClassSchedule>[])
          .add(schedule);
    }

    final List<HubSubject> subjects = <HubSubject>[];
    for (final String subjectId in _subjectOrder) {
      final _HubSubjectMeta meta =
          categoryMeta[subjectId] ?? _fallbackMetaForSubject(subjectId);

      final List<HubClassEntry> classes = (bySubject[subjectId] ??
            const <HubClassSchedule>[])
        .map(_mapSchedule)
        .toList(growable: true)..sort((HubClassEntry a, HubClassEntry b) {
        final int dayCompare = a.weekday.compareTo(b.weekday);
        if (dayCompare != 0) {
          return dayCompare;
        }
        return a.startMinutes.compareTo(b.startMinutes);
      });

      subjects.add(
        HubSubject(
          id: subjectId,
          title: meta.title,
          icon: meta.icon,
          accentColor: meta.accentColor,
          classes: classes,
        ),
      );
    }

    final String? expandedSubjectId = _resolveExpandedSubjectId(
      subjects: subjects,
      preferredExpandedSubjectId: preferredExpandedSubjectId,
    );

    return HubViewState(
      subjects: subjects,
      expandedSubjectId: expandedSubjectId,
    );
  }

  HubClassEntry _mapSchedule(HubClassSchedule schedule) {
    return HubClassEntry(
      id: schedule.id,
      subjectId: schedule.subjectId,
      teacherName: schedule.teacherName,
      startDate: schedule.startDate,
      endDate: schedule.endDate,
      weekday: schedule.weekday,
      startMinutes: schedule.startMinutes,
      durationMinutes: schedule.durationMinutes,
      attendanceStatus: schedule.attendanceStatus,
      recordingPlannedAt: schedule.recordingPlannedAt,
      recordingDurationMinutes: schedule.recordingDurationMinutes,
      recordingCompleted: schedule.recordingCompleted,
      pendingRecordingCount: schedule.pendingRecordingCount,
      completedRecordingCount: schedule.completedRecordingCount,
    );
  }

  String? _resolveExpandedSubjectId({
    required List<HubSubject> subjects,
    required String? preferredExpandedSubjectId,
  }) {
    if (subjects.isEmpty) {
      return null;
    }

    if (preferredExpandedSubjectId != null &&
        subjects.any((HubSubject s) => s.id == preferredExpandedSubjectId)) {
      return preferredExpandedSubjectId;
    }

    return subjects.first.id;
  }

  _HubSubjectMeta _fallbackMetaForSubject(String subjectId) {
    return switch (subjectId) {
      'maths' => const _HubSubjectMeta(
        title: 'Maths',
        icon: Icons.calculate_outlined,
        accentColor: Color(0xFFF43F5E),
      ),
      'physics' => const _HubSubjectMeta(
        title: 'Physics',
        icon: Icons.bolt_outlined,
        accentColor: Color(0xFF3B82F6),
      ),
      'chemistry' => const _HubSubjectMeta(
        title: 'Chemistry',
        icon: Icons.science_outlined,
        accentColor: Color(0xFF22C55E),
      ),
      _ => const _HubSubjectMeta(
        title: 'Study',
        icon: Icons.auto_awesome_rounded,
        accentColor: Color(0xFF64748B),
      ),
    };
  }
}

class _HubSubjectMeta {
  const _HubSubjectMeta({
    required this.title,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final IconData icon;
  final Color accentColor;
}
