import 'package:flutter_test/flutter_test.dart';
import 'package:study_tracker_mobile/features/calendar/application/calendar_time_math.dart';

void main() {
  group('calendar_time_math', () {
    test('splitRangeByDay splits spans at midnight boundaries', () {
      final DateTime start = DateTime(2026, 4, 5, 23, 30);
      final DateTime end = DateTime(2026, 4, 6, 1, 15);

      final List<TimeRange> slices = splitRangeByDay(start: start, end: end);

      expect(slices.length, 2);
      expect(slices[0].start, DateTime(2026, 4, 5, 23, 30));
      expect(slices[0].end, DateTime(2026, 4, 6, 0, 0));
      expect(slices[0].duration.inMinutes, 30);

      expect(slices[1].start, DateTime(2026, 4, 6, 0, 0));
      expect(slices[1].end, DateTime(2026, 4, 6, 1, 15));
      expect(slices[1].duration.inMinutes, 75);
    });

    test(
      'totalMergedOverlapSeconds avoids double counting overlapping ranges',
      () {
        final List<TimeRange> planned = <TimeRange>[
          TimeRange(
            start: DateTime(2026, 4, 5, 10, 0),
            end: DateTime(2026, 4, 5, 11, 0),
          ),
          TimeRange(
            start: DateTime(2026, 4, 5, 10, 30),
            end: DateTime(2026, 4, 5, 12, 0),
          ),
        ];

        final List<TimeRange> actual = <TimeRange>[
          TimeRange(
            start: DateTime(2026, 4, 5, 10, 45),
            end: DateTime(2026, 4, 5, 11, 15),
          ),
        ];

        final int overlap = totalMergedOverlapSeconds(
          first: planned,
          second: actual,
        );

        expect(overlap, 30 * 60);
      },
    );

    test('overlapSeconds returns zero when ranges do not overlap', () {
      final int overlap = overlapSeconds(
        firstStart: DateTime(2026, 4, 5, 8, 0),
        firstEnd: DateTime(2026, 4, 5, 9, 0),
        secondStart: DateTime(2026, 4, 5, 9, 1),
        secondEnd: DateTime(2026, 4, 5, 10, 0),
      );

      expect(overlap, 0);
    });

    test('day-boundary overlap can be computed safely from split slices', () {
      final DateTime plannedStart = DateTime(2026, 4, 5, 23, 0);
      final DateTime plannedEnd = DateTime(2026, 4, 6, 1, 0);
      final DateTime actualStart = DateTime(2026, 4, 6, 0, 30);
      final DateTime actualEnd = DateTime(2026, 4, 6, 2, 0);

      final List<TimeRange> plannedSlices = splitRangeByDay(
        start: plannedStart,
        end: plannedEnd,
      );
      final List<TimeRange> actualSlices = splitRangeByDay(
        start: actualStart,
        end: actualEnd,
      );

      final List<TimeRange> plannedDayTwo = plannedSlices
          .where(
            (TimeRange range) => dayKey(range.start) == DateTime(2026, 4, 6),
          )
          .toList(growable: false);
      final List<TimeRange> actualDayTwo = actualSlices
          .where(
            (TimeRange range) => dayKey(range.start) == DateTime(2026, 4, 6),
          )
          .toList(growable: false);

      final int overlapDayTwo = totalMergedOverlapSeconds(
        first: plannedDayTwo,
        second: actualDayTwo,
      );

      expect(overlapDayTwo, 30 * 60);
    });
  });
}
