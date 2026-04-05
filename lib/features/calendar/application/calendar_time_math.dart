class TimeRange {
  const TimeRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  Duration get duration => end.difference(start);

  bool get isValid => end.isAfter(start);
}

List<TimeRange> splitRangeByDay({
  required DateTime start,
  required DateTime end,
}) {
  if (!end.isAfter(start)) {
    return const <TimeRange>[];
  }

  final List<TimeRange> slices = <TimeRange>[];
  DateTime cursor = start;

  while (cursor.isBefore(end)) {
    final DateTime nextMidnight = DateTime(
      cursor.year,
      cursor.month,
      cursor.day,
    ).add(const Duration(days: 1));
    final DateTime sliceEnd = nextMidnight.isBefore(end) ? nextMidnight : end;

    if (sliceEnd.isAfter(cursor)) {
      slices.add(TimeRange(start: cursor, end: sliceEnd));
    }

    cursor = sliceEnd;
  }

  return slices;
}

int overlapSeconds({
  required DateTime firstStart,
  required DateTime firstEnd,
  required DateTime secondStart,
  required DateTime secondEnd,
}) {
  if (!firstEnd.isAfter(firstStart) || !secondEnd.isAfter(secondStart)) {
    return 0;
  }

  final DateTime maxStart =
      firstStart.isAfter(secondStart) ? firstStart : secondStart;
  final DateTime minEnd = firstEnd.isBefore(secondEnd) ? firstEnd : secondEnd;

  if (!minEnd.isAfter(maxStart)) {
    return 0;
  }

  return minEnd.difference(maxStart).inSeconds;
}

List<TimeRange> mergeRanges(Iterable<TimeRange> ranges) {
  final List<TimeRange> sorted = ranges
      .where((TimeRange range) => range.isValid)
      .toList(growable: false)
    ..sort((TimeRange a, TimeRange b) => a.start.compareTo(b.start));

  if (sorted.isEmpty) {
    return const <TimeRange>[];
  }

  final List<TimeRange> merged = <TimeRange>[];
  DateTime currentStart = sorted.first.start;
  DateTime currentEnd = sorted.first.end;

  for (int i = 1; i < sorted.length; i++) {
    final TimeRange next = sorted[i];
    if (!next.start.isAfter(currentEnd)) {
      if (next.end.isAfter(currentEnd)) {
        currentEnd = next.end;
      }
      continue;
    }

    merged.add(TimeRange(start: currentStart, end: currentEnd));
    currentStart = next.start;
    currentEnd = next.end;
  }

  merged.add(TimeRange(start: currentStart, end: currentEnd));
  return merged;
}

int totalMergedOverlapSeconds({
  required Iterable<TimeRange> first,
  required Iterable<TimeRange> second,
}) {
  final List<TimeRange> firstMerged = mergeRanges(first);
  final List<TimeRange> secondMerged = mergeRanges(second);

  if (firstMerged.isEmpty || secondMerged.isEmpty) {
    return 0;
  }

  int totalSeconds = 0;
  int firstIndex = 0;
  int secondIndex = 0;

  while (firstIndex < firstMerged.length && secondIndex < secondMerged.length) {
    final TimeRange a = firstMerged[firstIndex];
    final TimeRange b = secondMerged[secondIndex];

    totalSeconds += overlapSeconds(
      firstStart: a.start,
      firstEnd: a.end,
      secondStart: b.start,
      secondEnd: b.end,
    );

    if (a.end.isBefore(b.end) || a.end.isAtSameMomentAs(b.end)) {
      firstIndex += 1;
    } else {
      secondIndex += 1;
    }
  }

  return totalSeconds;
}

DateTime dayKey(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
