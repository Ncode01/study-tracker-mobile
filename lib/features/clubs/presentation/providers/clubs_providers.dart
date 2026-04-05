import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/clubs_view_notifier.dart';

final clubsViewProvider =
    AsyncNotifierProvider<ClubsViewNotifier, ClubsViewState>(
  ClubsViewNotifier.new,
);
