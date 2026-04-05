import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/calendar_view_notifier.dart';

final calendarViewProvider =
    AsyncNotifierProvider<CalendarViewNotifier, CalendarViewState>(
      CalendarViewNotifier.new,
    );
