import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/hub_view_notifier.dart';

final hubViewProvider = AsyncNotifierProvider<HubViewNotifier, HubViewState>(
  HubViewNotifier.new,
);
