import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/analytics_view_notifier.dart';

final analyticsViewProvider =
    AsyncNotifierProvider<AnalyticsViewNotifier, AnalyticsViewState>(
  AnalyticsViewNotifier.new,
);
