import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../../application/home_view_notifier.dart';
import '../../domain/models/home_stats.dart';
import '../../domain/models/home_view_state.dart';
import '../../domain/models/subject_category.dart';

final homeViewNotifierProvider =
    AsyncNotifierProvider<HomeViewNotifier, HomeViewState>(
  HomeViewNotifier.new,
);

final homeStatsProvider = Provider<HomeStats>((ref) {
  return ref.watch(homeViewNotifierProvider).maybeWhen(
        data: (HomeViewState state) => state.stats,
        orElse: () => const HomeStats(
          totalProductive: '0m',
          streak: '0m',
          next: '-',
        ),
      );
});

final currentCategoryProvider = Provider<SubjectCategory>((ref) {
  return ref.watch(homeViewNotifierProvider).maybeWhen(
        data: (HomeViewState state) => state.currentCategory,
        orElse: () => const SubjectCategory(
          id: 'loading',
          title: 'Loading',
          icon: Icons.hourglass_empty_rounded,
          accentColor: Colors.white,
          section: 'A/LEVELS',
        ),
      );
});

final categoryListProvider = Provider<List<SubjectCategory>>((ref) {
  return ref.watch(homeViewNotifierProvider).maybeWhen(
        data: (HomeViewState state) => state.categories,
        orElse: () => const <SubjectCategory>[],
      );
});
