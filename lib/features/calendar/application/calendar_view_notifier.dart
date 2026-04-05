import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/data/local/app_database.dart';

class CalendarEvent {
  const CalendarEvent({
    required this.title,
    required this.start,
    required this.duration,
    required this.accentColor,
    required this.note,
    this.isCurrent = false,
  });

  final String title;
  final DateTime start;
  final Duration duration;
  final Color accentColor;
  final String note;
  final bool isCurrent;
}

class CalendarDay {
  const CalendarDay({
    required this.date,
    required this.label,
    required this.events,
    this.isToday = false,
  });

  final DateTime date;
  final String label;
  final List<CalendarEvent> events;
  final bool isToday;
}

class CalendarViewState {
  const CalendarViewState({required this.days, required this.selectedDayIndex});

  final List<CalendarDay> days;
  final int selectedDayIndex;

  CalendarDay? get selectedDay {
    if (days.isEmpty) {
      return null;
    }
    final int safeIndex = selectedDayIndex.clamp(0, days.length - 1);
    return days[safeIndex];
  }

  CalendarViewState copyWith({List<CalendarDay>? days, int? selectedDayIndex}) {
    return CalendarViewState(
      days: days ?? this.days,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
    );
  }
}

class CalendarViewNotifier extends AsyncNotifier<CalendarViewState> {
  @override
  Future<CalendarViewState> build() async {
    return _loadState();
  }

  void selectDay(int index) {
    final CalendarViewState? current = state.valueOrNull;
    if (current == null || current.days.isEmpty) {
      return;
    }

    final int clamped = index.clamp(0, current.days.length - 1);
    state = AsyncData(current.copyWith(selectedDayIndex: clamped));
  }

  Future<CalendarViewState> _loadState() async {
    final db = await AppDatabase.instance.database;
    final List<Map<String, Object?>> rows = await db.rawQuery('''
      SELECT
        s.categoryId,
        s.startedAt,
        s.durationSeconds,
        c.title AS categoryTitle,
        c.accentColorValue AS accentColorValue
      FROM sessions s
      LEFT JOIN categories c ON c.id = s.categoryId
      ORDER BY s.startedAt ASC
    ''');

    if (rows.isEmpty) {
      return const CalendarViewState(
        days: <CalendarDay>[],
        selectedDayIndex: 0,
      );
    }

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final Map<DateTime, List<CalendarEvent>> byDay =
        <DateTime, List<CalendarEvent>>{};

    for (final Map<String, Object?> row in rows) {
      final DateTime start = DateTime.parse(row['startedAt'] as String);
      final int durationSeconds = row['durationSeconds'] as int? ?? 0;
      if (durationSeconds <= 0) {
        continue;
      }

      final Duration duration = Duration(seconds: durationSeconds);
      final DateTime end = start.add(duration);
      final DateTime dayKey = DateTime(start.year, start.month, start.day);
      final String categoryTitle = row['categoryTitle'] as String? ?? 'Study';
      final Color color = Color(row['accentColorValue'] as int? ?? 0xFF64748B);

      byDay
          .putIfAbsent(dayKey, () => <CalendarEvent>[])
          .add(
            CalendarEvent(
              title: '$categoryTitle Session',
              start: start,
              duration: duration,
              accentColor: color,
              note:
                  '${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}',
              isCurrent: now.isAfter(start) && now.isBefore(end),
            ),
          );
    }

    final List<DateTime> orderedDays = byDay.keys.toList(growable: false)
      ..sort((DateTime a, DateTime b) => a.compareTo(b));

    final List<CalendarDay> days = orderedDays
        .map((DateTime date) {
          final List<CalendarEvent> events = List<CalendarEvent>.from(
            byDay[date] ?? const <CalendarEvent>[],
          )..sort(
            (CalendarEvent a, CalendarEvent b) => a.start.compareTo(b.start),
          );

          return CalendarDay(
            date: date,
            label: DateFormat('EEE d').format(date),
            events: events,
            isToday: _isSameDate(date, today),
          );
        })
        .toList(growable: false);

    final int todayIndex = days.indexWhere((CalendarDay day) => day.isToday);

    return CalendarViewState(
      days: days,
      selectedDayIndex: todayIndex >= 0 ? todayIndex : days.length - 1,
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
