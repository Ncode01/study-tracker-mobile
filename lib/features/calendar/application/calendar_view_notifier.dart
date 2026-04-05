import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/models/planned_item.dart';
import '../domain/repositories/calendar_repository.dart';
import '../presentation/providers/calendar_providers.dart';
import 'calendar_time_math.dart';

enum CalendarTimelineMode { planned, actual, both }

enum CalendarEventType { planned, actual }

class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.categoryId,
    required this.categoryTitle,
    required this.title,
    required this.start,
    required this.end,
    required this.duration,
    required this.accentColor,
    required this.note,
    required this.type,
    this.plannedItemId,
    this.isCurrent = false,
    this.isLive = false,
    this.plannedSource,
    this.isEditable = false,
  });

  final String id;
  final String categoryId;
  final String categoryTitle;
  final String title;
  final DateTime start;
  final DateTime end;
  final Duration duration;
  final Color accentColor;
  final String note;
  final CalendarEventType type;
  final int? plannedItemId;
  final bool isCurrent;
  final bool isLive;
  final PlannedItemSource? plannedSource;
  final bool isEditable;

  bool get isPlanned => type == CalendarEventType.planned;
}

class CalendarCategorySummary {
  const CalendarCategorySummary({
    required this.categoryId,
    required this.categoryTitle,
    required this.accentColor,
    required this.plannedDuration,
    required this.actualDuration,
    required this.overlapDuration,
  });

  final String categoryId;
  final String categoryTitle;
  final Color accentColor;
  final Duration plannedDuration;
  final Duration actualDuration;
  final Duration overlapDuration;

  Duration get variance => actualDuration - plannedDuration;
}

class CalendarDaySummary {
  const CalendarDaySummary({
    required this.plannedDuration,
    required this.actualDuration,
    required this.overlapDuration,
    required this.byCategory,
  });

  final Duration plannedDuration;
  final Duration actualDuration;
  final Duration overlapDuration;
  final List<CalendarCategorySummary> byCategory;

  Duration get variance => actualDuration - plannedDuration;

  double get completionRatio {
    if (plannedDuration <= Duration.zero) {
      return 0;
    }

    final double ratio = overlapDuration.inSeconds / plannedDuration.inSeconds;
    return ratio.clamp(0, 1);
  }
}

class CalendarDay {
  const CalendarDay({
    required this.date,
    required this.label,
    required this.plannedEvents,
    required this.actualEvents,
    required this.summary,
    this.isToday = false,
  });

  final DateTime date;
  final String label;
  final List<CalendarEvent> plannedEvents;
  final List<CalendarEvent> actualEvents;
  final CalendarDaySummary summary;
  final bool isToday;

  List<CalendarEvent> eventsForMode(CalendarTimelineMode mode) {
    return switch (mode) {
      CalendarTimelineMode.planned => plannedEvents,
      CalendarTimelineMode.actual => actualEvents,
      CalendarTimelineMode.both => <CalendarEvent>[
        ...plannedEvents,
        ...actualEvents,
      ]..sort((CalendarEvent a, CalendarEvent b) => a.start.compareTo(b.start)),
    };
  }
}

class CalendarViewState {
  const CalendarViewState({
    required this.selectedDate,
    required this.categories,
    required this.plannedItems,
    required this.day,
    required this.mode,
  });

  final DateTime selectedDate;
  final List<CalendarCategoryOption> categories;
  final List<PlannedItem> plannedItems;
  final CalendarDay day;
  final CalendarTimelineMode mode;

  CalendarDay get selectedDay => day;

  CalendarViewState copyWith({
    DateTime? selectedDate,
    List<CalendarCategoryOption>? categories,
    List<PlannedItem>? plannedItems,
    CalendarDay? day,
    CalendarTimelineMode? mode,
  }) {
    return CalendarViewState(
      selectedDate: selectedDate ?? this.selectedDate,
      categories: categories ?? this.categories,
      plannedItems: plannedItems ?? this.plannedItems,
      day: day ?? this.day,
      mode: mode ?? this.mode,
    );
  }
}

class CalendarViewNotifier extends AsyncNotifier<CalendarViewState> {
  late final CalendarRepository _repository;
  late final DateTime Function() _now;

  @override
  Future<CalendarViewState> build() async {
    _repository = ref.read(calendarRepositoryProvider);
    _now = ref.read(calendarNowProvider);

    final DateTime initialDate = dayKey(_now());
    return _loadState(selectedDate: initialDate);
  }

  void setTimelineMode(CalendarTimelineMode mode) {
    final CalendarViewState? current = state.valueOrNull;
    if (current == null || current.mode == mode) {
      return;
    }

    state = AsyncData(current.copyWith(mode: mode));
  }

  Future<void> selectDate(DateTime date) async {
    final CalendarViewState? current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final DateTime selectedDate = dayKey(date);
    if (_isSameDate(current.selectedDate, selectedDate)) {
      return;
    }

    await _reload(selectedDate: selectedDate);
  }

  Future<void> refresh() async {
    final CalendarViewState? current = state.valueOrNull;
    if (current == null) {
      return;
    }

    await _reload(selectedDate: current.selectedDate);
  }

  Future<void> createPlannedItem(PlannedItemDraft draft) async {
    _validateTitleAndRange(
      title: draft.title,
      startAt: draft.startAt,
      endAt: draft.endAt,
    );

    await _repository.createPlannedItem(draft);
    await _reload(selectedDate: dayKey(draft.startAt));
  }

  Future<void> updatePlannedItem(PlannedItem item) async {
    _validateTitleAndRange(
      title: item.title,
      startAt: item.startAt,
      endAt: item.endAt,
    );

    await _repository.updatePlannedItem(item);
    await _reload(selectedDate: dayKey(item.startAt));
  }

  Future<void> deletePlannedItem({
    required int plannedItemId,
    DateTime? preferredDay,
  }) async {
    await _repository.deletePlannedItem(plannedItemId);

    final CalendarViewState? current = state.valueOrNull;
    await _reload(
      selectedDate: dayKey(preferredDay ?? current?.selectedDate ?? _now()),
    );
  }

  Future<void> _reload({required DateTime selectedDate}) async {
    final CalendarViewState? previous = state.valueOrNull;
    state = const AsyncLoading<CalendarViewState>().copyWithPrevious(state);

    try {
      final CalendarViewState loaded = await _loadState(
        selectedDate: selectedDate,
        selectedMode: previous?.mode,
      );
      state = AsyncData(loaded);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<CalendarViewState> _loadState({
    required DateTime selectedDate,
    CalendarTimelineMode? selectedMode,
  }) async {
    final DateTime normalizedDate = dayKey(selectedDate);

    final List<Object> loaded = await Future.wait<Object>(<Future<Object>>[
      _repository.loadCategories(),
      _repository.loadActualSessions(selectedDate: normalizedDate),
      _repository.loadPlannedItems(selectedDate: normalizedDate),
    ]);

    final List<CalendarCategoryOption> categories =
        loaded[0] as List<CalendarCategoryOption>;
    final List<CalendarActualSession> actualSessions =
        loaded[1] as List<CalendarActualSession>;
    final List<PlannedItem> plannedItems = loaded[2] as List<PlannedItem>;

    final DateTime now = _now();
    final CalendarDay day = _buildCalendarDay(
      selectedDate: normalizedDate,
      now: now,
      actualSessions: actualSessions,
      plannedItems: plannedItems,
    );

    return CalendarViewState(
      selectedDate: normalizedDate,
      categories: categories,
      plannedItems: plannedItems,
      day: day,
      mode: selectedMode ?? CalendarTimelineMode.both,
    );
  }

  CalendarDay _buildCalendarDay({
    required DateTime selectedDate,
    required DateTime now,
    required List<CalendarActualSession> actualSessions,
    required List<PlannedItem> plannedItems,
  }) {
    final DateTime startOfDay = dayKey(selectedDate);
    final DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    final List<CalendarEvent> actualEvents = <CalendarEvent>[];
    final List<TimeRange> actualRanges = <TimeRange>[];

    final List<CalendarEvent> plannedEvents = <CalendarEvent>[];
    final List<TimeRange> plannedRanges = <TimeRange>[];

    final Map<String, _CategoryAccumulator> byCategory =
        <String, _CategoryAccumulator>{};

    void ensureCategory(CalendarEvent event) {
      byCategory.putIfAbsent(
        event.categoryId,
        () => _CategoryAccumulator(
          categoryId: event.categoryId,
          categoryTitle: event.categoryTitle,
          accentColor: event.accentColor,
        ),
      );
    }

    for (final CalendarActualSession session in actualSessions) {
      final DateTime rawStart = session.startedAt;
      final DateTime rawEnd = session.endedAt ?? now;
      if (!rawEnd.isAfter(rawStart)) {
        continue;
      }

      if (!rawStart.isBefore(endOfDay) || !rawEnd.isAfter(startOfDay)) {
        continue;
      }

      final DateTime renderStart =
          rawStart.isBefore(startOfDay) ? startOfDay : rawStart;
      final DateTime renderEnd = rawEnd.isAfter(endOfDay) ? endOfDay : rawEnd;
      if (!renderEnd.isAfter(renderStart)) {
        continue;
      }

      final Duration duration = renderEnd.difference(renderStart);
      final String note =
          '${DateFormat('HH:mm').format(renderStart)} - ${DateFormat('HH:mm').format(renderEnd)}';

      final CalendarEvent event = CalendarEvent(
        id:
            session.isLive
                ? 'actual-live-${session.categoryId}-${rawStart.millisecondsSinceEpoch}'
                : 'actual-${session.categoryId}-${renderStart.millisecondsSinceEpoch}-${renderEnd.millisecondsSinceEpoch}',
        categoryId: session.categoryId,
        categoryTitle: session.categoryTitle,
        title: '${session.categoryTitle} Session',
        start: renderStart,
        end: renderEnd,
        duration: duration,
        accentColor: session.accentColor,
        note: note,
        type: CalendarEventType.actual,
        isCurrent: session.isLive && _isSameDate(selectedDate, dayKey(now)),
        isLive: session.isLive,
        isEditable: false,
      );

      actualEvents.add(event);
      actualRanges.add(TimeRange(start: renderStart, end: renderEnd));

      ensureCategory(event);
      byCategory[event.categoryId]!.actualSeconds += duration.inSeconds;
      byCategory[event.categoryId]!.actualRanges.add(
        TimeRange(start: renderStart, end: renderEnd),
      );
    }

    for (final PlannedItem item in plannedItems) {
      if (!item.endAt.isAfter(item.startAt)) {
        continue;
      }

      if (!item.startAt.isBefore(endOfDay) || !item.endAt.isAfter(startOfDay)) {
        continue;
      }

      final DateTime renderStart =
          item.startAt.isBefore(startOfDay) ? startOfDay : item.startAt;
      final DateTime renderEnd =
          item.endAt.isAfter(endOfDay) ? endOfDay : item.endAt;
      if (!renderEnd.isAfter(renderStart)) {
        continue;
      }

      final Duration duration = renderEnd.difference(renderStart);
      final String notePrefix =
          '${DateFormat('HH:mm').format(renderStart)} - ${DateFormat('HH:mm').format(renderEnd)}';
      final String notesText = item.notes?.trim() ?? '';
      final String note =
          notesText.isEmpty ? notePrefix : '$notePrefix · $notesText';

      final CalendarEvent event = CalendarEvent(
        id:
            'planned-${item.id}-${renderStart.millisecondsSinceEpoch}-${renderEnd.millisecondsSinceEpoch}',
        categoryId: item.categoryId,
        categoryTitle: item.categoryTitle,
        title: item.title,
        start: renderStart,
        end: renderEnd,
        duration: duration,
        accentColor: item.accentColor,
        note: note,
        type: CalendarEventType.planned,
        plannedItemId: item.isEditable ? item.id : null,
        plannedSource: item.source,
        isEditable: item.isEditable,
      );

      plannedEvents.add(event);
      plannedRanges.add(TimeRange(start: renderStart, end: renderEnd));

      ensureCategory(event);
      byCategory[event.categoryId]!.plannedSeconds += duration.inSeconds;
      byCategory[event.categoryId]!.plannedRanges.add(
        TimeRange(start: renderStart, end: renderEnd),
      );
    }

    plannedEvents.sort(
      (CalendarEvent a, CalendarEvent b) => a.start.compareTo(b.start),
    );
    actualEvents.sort(
      (CalendarEvent a, CalendarEvent b) => a.start.compareTo(b.start),
    );

    final int plannedSeconds = plannedEvents.fold<int>(
      0,
      (int sum, CalendarEvent e) => sum + e.duration.inSeconds,
    );
    final int actualSeconds = actualEvents.fold<int>(
      0,
      (int sum, CalendarEvent e) => sum + e.duration.inSeconds,
    );

    final int overlapSecondsAll = totalMergedOverlapSeconds(
      first: plannedRanges,
      second: actualRanges,
    );

    final List<CalendarCategorySummary> categorySummary = byCategory.values
        .map((acc) {
          final int overlapSeconds = totalMergedOverlapSeconds(
            first: acc.plannedRanges,
            second: acc.actualRanges,
          );

          return CalendarCategorySummary(
            categoryId: acc.categoryId,
            categoryTitle: acc.categoryTitle,
            accentColor: acc.accentColor,
            plannedDuration: Duration(seconds: acc.plannedSeconds),
            actualDuration: Duration(seconds: acc.actualSeconds),
            overlapDuration: Duration(seconds: overlapSeconds),
          );
        })
        .toList(growable: false)
      ..sort((CalendarCategorySummary a, CalendarCategorySummary b) {
        final int aMax =
            a.plannedDuration.inSeconds > a.actualDuration.inSeconds
                ? a.plannedDuration.inSeconds
                : a.actualDuration.inSeconds;
        final int bMax =
            b.plannedDuration.inSeconds > b.actualDuration.inSeconds
                ? b.plannedDuration.inSeconds
                : b.actualDuration.inSeconds;
        return bMax.compareTo(aMax);
      });

    return CalendarDay(
      date: selectedDate,
      label: DateFormat('EEE d').format(selectedDate),
      plannedEvents: plannedEvents,
      actualEvents: actualEvents,
      summary: CalendarDaySummary(
        plannedDuration: Duration(seconds: plannedSeconds),
        actualDuration: Duration(seconds: actualSeconds),
        overlapDuration: Duration(seconds: overlapSecondsAll),
        byCategory: categorySummary,
      ),
      isToday: _isSameDate(selectedDate, dayKey(now)),
    );
  }

  void _validateTitleAndRange({
    required String title,
    required DateTime startAt,
    required DateTime endAt,
  }) {
    if (title.trim().isEmpty) {
      throw const FormatException('Title cannot be empty.');
    }
    if (!endAt.isAfter(startAt)) {
      throw const FormatException('End time must be after start time.');
    }
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _CategoryAccumulator {
  _CategoryAccumulator({
    required this.categoryId,
    required this.categoryTitle,
    required this.accentColor,
  });

  final String categoryId;
  final String categoryTitle;
  final Color accentColor;

  int plannedSeconds = 0;
  int actualSeconds = 0;

  final List<TimeRange> plannedRanges = <TimeRange>[];
  final List<TimeRange> actualRanges = <TimeRange>[];
}
