import 'package:flutter/material.dart';

import 'home_stats.dart';
import 'subject_category.dart';
import 'timer_snapshot.dart';

class HomeViewState {
  const HomeViewState({
    required this.categories,
    required this.currentCategory,
    required this.stats,
    required this.timer,
  });

  final List<SubjectCategory> categories;
  final SubjectCategory currentCategory;
  final HomeStats stats;
  final TimerSnapshot timer;

  HomeViewState copyWith({
    List<SubjectCategory>? categories,
    SubjectCategory? currentCategory,
    HomeStats? stats,
    TimerSnapshot? timer,
  }) {
    return HomeViewState(
      categories: categories ?? this.categories,
      currentCategory: currentCategory ?? this.currentCategory,
      stats: stats ?? this.stats,
      timer: timer ?? this.timer,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'categories': categories
          .map((SubjectCategory category) => category.toMap())
          .toList(growable: false),
      'currentCategoryId': currentCategory.id,
      'stats': stats.toMap(),
      'timer': timer.toMap(),
    };
  }

  factory HomeViewState.fromMap(Map<String, Object?> map) {
    final List<Object?> categoryMaps =
        map['categories'] as List<Object?>? ?? <Object?>[];

    final List<SubjectCategory> parsedCategories = categoryMaps
        .whereType<Map<String, Object?>>()
        .map(SubjectCategory.fromMap)
        .toList(growable: false);

    final SubjectCategory fallbackCategory = parsedCategories.isNotEmpty
        ? parsedCategories.first
        : const SubjectCategory(
            id: 'physics',
            title: 'Physics',
            icon: Icons.bolt_outlined,
            accentColor: Color(0xFF3B82F6),
            section: 'A/LEVELS',
          );

    final String currentId = map['currentCategoryId'] as String? ?? '';
    final SubjectCategory current = parsedCategories.firstWhere(
      (SubjectCategory category) => category.id == currentId,
      orElse: () => fallbackCategory,
    );

    return HomeViewState(
      categories: parsedCategories.isEmpty
          ? <SubjectCategory>[fallbackCategory]
          : parsedCategories,
      currentCategory: current,
      stats: HomeStats.fromMap(
        map['stats'] as Map<String, Object?>? ?? <String, Object?>{},
      ),
      timer: TimerSnapshot.fromMap(
        map['timer'] as Map<String, Object?>? ?? <String, Object?>{},
      ),
    );
  }
}
