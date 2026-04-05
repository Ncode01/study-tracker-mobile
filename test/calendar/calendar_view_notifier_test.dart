import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_tracker_mobile/features/calendar/application/calendar_view_notifier.dart';
import 'package:study_tracker_mobile/features/calendar/domain/models/planned_item.dart';
import 'package:study_tracker_mobile/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:study_tracker_mobile/features/calendar/presentation/providers/calendar_providers.dart';

void main() {
  group('CalendarViewNotifier state loading', () {
    const CalendarCategoryOption physics = CalendarCategoryOption(
      id: 'physics',
      title: 'Physics',
      accentColor: Color(0xFF3B82F6),
    );

    test('loads correctly when only planned items exist', () async {
      final DateTime now = DateTime(2026, 4, 5, 12, 0);
      final _FakeCalendarRepository repository = _FakeCalendarRepository(
        categories: const <CalendarCategoryOption>[physics],
        plannedItems: <PlannedItem>[
          PlannedItem(
            id: 1,
            categoryId: 'physics',
            categoryTitle: 'Physics',
            accentColor: const Color(0xFF3B82F6),
            title: 'Wave revision',
            startAt: DateTime(2026, 4, 5, 9, 0),
            endAt: DateTime(2026, 4, 5, 10, 0),
            notes: null,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );

      final ProviderContainer container = _containerFor(
        repository: repository,
        now: now,
      );
      addTearDown(container.dispose);

      final CalendarViewState state = await container.read(
        calendarViewProvider.future,
      );

      final CalendarDay selectedDay = state.selectedDay;
      expect(state.mode, CalendarTimelineMode.both);
      expect(selectedDay.plannedEvents.length, 1);
      expect(selectedDay.actualEvents, isEmpty);
      expect(selectedDay.summary.plannedDuration.inMinutes, 60);
      expect(selectedDay.summary.actualDuration, Duration.zero);
      expect(selectedDay.summary.variance.inMinutes, -60);
    });

    test('loads correctly when only actual sessions exist', () async {
      final DateTime now = DateTime(2026, 4, 5, 12, 0);
      final _FakeCalendarRepository repository = _FakeCalendarRepository(
        categories: const <CalendarCategoryOption>[physics],
        actualSessions: <CalendarActualSession>[
          CalendarActualSession(
            categoryId: 'physics',
            categoryTitle: 'Physics',
            accentColor: const Color(0xFF3B82F6),
            startedAt: DateTime(2026, 4, 5, 10, 0),
            endedAt: DateTime(2026, 4, 5, 11, 30),
          ),
        ],
      );

      final ProviderContainer container = _containerFor(
        repository: repository,
        now: now,
      );
      addTearDown(container.dispose);

      final CalendarViewState state = await container.read(
        calendarViewProvider.future,
      );

      final CalendarDay selectedDay = state.selectedDay;
      expect(selectedDay.plannedEvents, isEmpty);
      expect(selectedDay.actualEvents.length, 1);
      expect(selectedDay.summary.plannedDuration, Duration.zero);
      expect(selectedDay.summary.actualDuration.inMinutes, 90);
      expect(selectedDay.summary.variance.inMinutes, 90);
    });

    test('loads correctly when planned and actual both exist', () async {
      final DateTime now = DateTime(2026, 4, 5, 12, 0);
      final _FakeCalendarRepository repository = _FakeCalendarRepository(
        categories: const <CalendarCategoryOption>[physics],
        plannedItems: <PlannedItem>[
          PlannedItem(
            id: 1,
            categoryId: 'physics',
            categoryTitle: 'Physics',
            accentColor: const Color(0xFF3B82F6),
            title: 'Lab prep',
            startAt: DateTime(2026, 4, 5, 9, 0),
            endAt: DateTime(2026, 4, 5, 11, 0),
            notes: null,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        actualSessions: <CalendarActualSession>[
          CalendarActualSession(
            categoryId: 'physics',
            categoryTitle: 'Physics',
            accentColor: const Color(0xFF3B82F6),
            startedAt: DateTime(2026, 4, 5, 9, 30),
            endedAt: DateTime(2026, 4, 5, 11, 30),
          ),
        ],
      );

      final ProviderContainer container = _containerFor(
        repository: repository,
        now: now,
      );
      addTearDown(container.dispose);

      final CalendarViewState state = await container.read(
        calendarViewProvider.future,
      );

      final CalendarDay selectedDay = state.selectedDay;
      expect(selectedDay.plannedEvents.length, 1);
      expect(selectedDay.actualEvents.length, 1);
      expect(selectedDay.summary.plannedDuration.inMinutes, 120);
      expect(selectedDay.summary.actualDuration.inMinutes, 120);
      expect(selectedDay.summary.overlapDuration.inMinutes, 90);
      expect(selectedDay.summary.byCategory.length, 1);
      expect(selectedDay.summary.byCategory.first.categoryId, 'physics');
      expect(
        selectedDay.summary.byCategory.first.plannedDuration.inMinutes,
        120,
      );
      expect(
        selectedDay.summary.byCategory.first.actualDuration.inMinutes,
        120,
      );
      expect(
        selectedDay.summary.byCategory.first.overlapDuration.inMinutes,
        90,
      );
    });

    test('loads correctly when neither planned nor actual exists', () async {
      final DateTime now = DateTime(2026, 4, 5, 12, 0);
      final _FakeCalendarRepository repository = _FakeCalendarRepository(
        categories: const <CalendarCategoryOption>[physics],
      );

      final ProviderContainer container = _containerFor(
        repository: repository,
        now: now,
      );
      addTearDown(container.dispose);

      final CalendarViewState state = await container.read(
        calendarViewProvider.future,
      );

      final CalendarDay selectedDay = state.selectedDay;
      expect(selectedDay.date, DateTime(2026, 4, 5));
      expect(selectedDay.plannedEvents, isEmpty);
      expect(selectedDay.actualEvents, isEmpty);
      expect(selectedDay.summary.plannedDuration, Duration.zero);
      expect(selectedDay.summary.actualDuration, Duration.zero);
      expect(selectedDay.summary.variance, Duration.zero);
    });

    test(
      'read-only planned items are not editable in timeline events',
      () async {
        final DateTime now = DateTime(2026, 4, 5, 12, 0);
        final _FakeCalendarRepository repository = _FakeCalendarRepository(
          categories: const <CalendarCategoryOption>[physics],
          plannedItems: <PlannedItem>[
            PlannedItem(
              id: -99,
              categoryId: 'physics',
              categoryTitle: 'Physics',
              accentColor: const Color(0xFF3B82F6),
              title: 'Physics Live Class',
              startAt: DateTime(2026, 4, 5, 9, 0),
              endAt: DateTime(2026, 4, 5, 10, 0),
              notes: 'Teacher: Smith',
              createdAt: now,
              updatedAt: now,
              source: PlannedItemSource.hubLiveClass,
              isEditable: false,
            ),
          ],
        );

        final ProviderContainer container = _containerFor(
          repository: repository,
          now: now,
        );
        addTearDown(container.dispose);

        final CalendarViewState state = await container.read(
          calendarViewProvider.future,
        );

        final CalendarEvent event = state.selectedDay.plannedEvents.first;
        expect(event.plannedItemId, isNull);
        expect(event.isPlanned, isTrue);
      },
    );
  });
}

ProviderContainer _containerFor({
  required CalendarRepository repository,
  required DateTime now,
}) {
  return ProviderContainer(
    overrides: <Override>[
      calendarRepositoryProvider.overrideWithValue(repository),
      calendarNowProvider.overrideWithValue(() => now),
    ],
  );
}

class _FakeCalendarRepository implements CalendarRepository {
  _FakeCalendarRepository({
    this.categories = const <CalendarCategoryOption>[],
    this.actualSessions = const <CalendarActualSession>[],
    this.plannedItems = const <PlannedItem>[],
  });

  final List<CalendarCategoryOption> categories;
  final List<CalendarActualSession> actualSessions;
  final List<PlannedItem> plannedItems;

  @override
  Future<List<CalendarCategoryOption>> loadCategories() async {
    return categories;
  }

  @override
  Future<List<CalendarActualSession>> loadActualSessions({
    required DateTime selectedDate,
  }) async {
    return actualSessions;
  }

  @override
  Future<List<PlannedItem>> loadPlannedItems({
    required DateTime selectedDate,
  }) async {
    return plannedItems;
  }

  @override
  Future<int> createPlannedItem(PlannedItemDraft draft) async {
    return 1;
  }

  @override
  Future<void> deletePlannedItem(int id) async {}

  @override
  Future<void> updatePlannedItem(PlannedItem item) async {}
}
