import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../application/calendar_view_notifier.dart';
import '../../domain/repositories/calendar_repository.dart';

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return SqliteCalendarRepository(
    database: ref.watch(databaseProvider),
    preferences: ref.watch(sharedPreferencesProvider),
  );
});

final calendarNowProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});

final calendarViewProvider =
    AsyncNotifierProvider<CalendarViewNotifier, CalendarViewState>(
      CalendarViewNotifier.new,
    );
