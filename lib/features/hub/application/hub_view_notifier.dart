import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../calendar/presentation/providers/calendar_providers.dart';
import '../domain/models/hub_class_schedule.dart';
import '../domain/repositories/hub_repository.dart';

class HubClassEntry {
  const HubClassEntry({
    required this.id,
    required this.subjectId,
    required this.teacherName,
    required this.weekday,
    required this.startMinutes,
    required this.durationMinutes,
    required this.attendanceStatus,
    required this.recordingPlannedAt,
    required this.recordingDurationMinutes,
    required this.recordingCompleted,
  });

  final int id;
  final String subjectId;
  final String teacherName;
  final int weekday;
  final int startMinutes;
  final int durationMinutes;
  final HubAttendanceStatus attendanceStatus;
  final DateTime? recordingPlannedAt;
  final int? recordingDurationMinutes;
  final bool recordingCompleted;

  bool get canPlanRecording => attendanceStatus == HubAttendanceStatus.missed;
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

  Future<void> addClassSession({
    required String subjectId,
    required String teacherName,
    required int weekday,
    required int startMinutes,
    required int durationMinutes,
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

    await _runMutation(() {
      return _repo.addClassSchedule(
        subjectId: subjectId,
        teacherName: normalizedTeacher,
        weekday: weekday,
        startMinutes: startMinutes,
        durationMinutes: durationMinutes,
      );
    });
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

  Future<void> _runMutation(Future<Object?> Function() mutation) async {
    final HubViewState? current = state.valueOrNull;
    final String? expandedId = current?.expandedSubjectId;

    await mutation();
    await _reload(preferredExpandedSubjectId: expandedId);
    ref.invalidate(calendarViewProvider);
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
          icon: IconData(
            row['iconCodePoint'] as int? ??
                Icons.auto_awesome_rounded.codePoint,
            fontFamily: row['iconFontFamily'] as String? ?? 'MaterialIcons',
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
      weekday: schedule.weekday,
      startMinutes: schedule.startMinutes,
      durationMinutes: schedule.durationMinutes,
      attendanceStatus: schedule.attendanceStatus,
      recordingPlannedAt: schedule.recordingPlannedAt,
      recordingDurationMinutes: schedule.recordingDurationMinutes,
      recordingCompleted: schedule.recordingCompleted,
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
