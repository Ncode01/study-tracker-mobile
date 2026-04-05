import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/services/app_settings_service.dart';
import '../../../core/services/sensory_service.dart';
import '../domain/models/home_stats.dart';
import '../domain/models/home_view_state.dart';
import '../domain/models/subject_category.dart';
import '../domain/models/timer_snapshot.dart';
import '../domain/repositories/timer_repository.dart';
import 'timer_service.dart';

class HomeViewNotifier extends AsyncNotifier<HomeViewState> {
  static const SubjectCategory _fallbackCategory = SubjectCategory(
    id: 'physics',
    title: 'Physics',
    icon: Icons.bolt_outlined,
    accentColor: Color(0xFF3B82F6),
    section: 'A/LEVELS',
  );

  TimerRepository? _repository;
  TimerService? _timerService;
  AppSettingsService? _appSettingsService;
  SensoryService? _sensoryService;
  final bool _persistenceEnabled = true;
  bool _keepScreenAwakeEnabled = true;

  TimerRepository get _repo {
    return _repository ??= TimerRepository(
      database: ref.read(databaseProvider),
      preferences: ref.read(sharedPreferencesProvider),
    );
  }

  TimerService get _tickerService {
    return _timerService ??= TimerService();
  }

  AppSettingsService get _settingsService {
    final AppSettingsService? cached = _appSettingsService;
    if (cached != null) {
      return cached;
    }
    final AppSettingsService created = ref.read(appSettingsServiceProvider);
    _appSettingsService = created;
    return created;
  }

  SensoryService get _sensory {
    final SensoryService? cached = _sensoryService;
    if (cached != null) {
      return cached;
    }
    final SensoryService created = ref.read(sensoryServiceProvider);
    _sensoryService = created;
    return created;
  }

  @override
  Future<HomeViewState> build() async {
    final AppSettingsService settingsService = _settingsService;
    _sensory;

    final AppSettingsSnapshot settings = await settingsService.snapshot();
    _keepScreenAwakeEnabled = settings.keepScreenAwake;

    ref.onDispose(() {
      final TimerService? timerService = _timerService;
      if (timerService != null) {
        unawaited(timerService.dispose());
      }
    });

    final List<SubjectCategory> loadedCategories = await _repo.loadCategories();
    final List<SubjectCategory> categories =
        loadedCategories.isEmpty
            ? const <SubjectCategory>[_fallbackCategory]
            : loadedCategories;

    final String? selectedCategoryId = await _repo.loadSelectedCategoryId();
    final SubjectCategory currentCategory = categories.firstWhere(
      (SubjectCategory category) => category.id == selectedCategoryId,
      orElse: () => categories.first,
    );

    final TimerSnapshot timer = await _repo.loadTimerSnapshot();

    final HomeStats stats = await _repo.loadHomeStats(
      categories: categories,
      currentCategoryId: currentCategory.id,
    );

    final HomeViewState initialState = HomeViewState(
      categories: categories,
      currentCategory: currentCategory,
      stats: stats,
      timer: timer,
    );

    if (_persistenceEnabled) {
      await _repo.saveActiveSession(
        categoryId: currentCategory.id,
        sessionStartTime: timer.sessionStartTime,
      );
    }

    _tickerService.startTicker(onTick: _tick);
    await _tickerService.updateWakelock(
      _shouldEnableWakelockForCategory(currentCategory.id),
    );

    return initialState;
  }

  Future<void> switchCategory(SubjectCategory category) async {
    final HomeViewState? current = state.valueOrNull;
    if (current == null) {
      return;
    }

    if (current.currentCategory.id == category.id) {
      return;
    }

    final DateTime now = DateTime.now();
    final DateTime previousSessionStart = _resolveSessionStartTime(
      current.timer,
    );
    final Duration outgoingDuration = now.difference(previousSessionStart);

    if (_persistenceEnabled && outgoingDuration > Duration.zero) {
      await _repo.saveSession(
        categoryId: current.currentCategory.id,
        startedAt: previousSessionStart,
        endedAt: now,
        duration: outgoingDuration,
        isProductive: _isProductiveCategoryId(current.currentCategory.id),
      );
    }

    if (_persistenceEnabled) {
      await _repo.saveActiveSession(
        categoryId: category.id,
        sessionStartTime: now,
      );
    }

    await _sensory.playSessionStart();
    if (_settingsService.enableHaptics) {
      await HapticFeedback.heavyImpact();
    }

    final TimerSnapshot nextTimer = TimerSnapshot(
      sessionStartTime: now,
      elapsed: Duration.zero,
    );

    final HomeStats nextStats =
        _persistenceEnabled
            ? await _repo.loadHomeStats(
              categories: current.categories,
              currentCategoryId: category.id,
            )
            : current.stats;

    state = AsyncData(
      current.copyWith(
        currentCategory: category,
        timer: nextTimer,
        stats: nextStats,
      ),
    );

    await _tickerService.updateWakelock(
      _shouldEnableWakelockForCategory(category.id),
    );
  }

  Future<void> quickSwitchToMaths() async {
    final SubjectCategory? maths = _categoryById('maths');
    if (maths != null) {
      await switchCategory(maths);
    }
  }

  Future<void> quickSwitchToBreak() async {
    final SubjectCategory? breakCategory = _categoryById('break');
    if (breakCategory != null) {
      await switchCategory(breakCategory);
    }
  }

  Future<SubjectCategory?> createCategory({
    required String title,
    required Color accentColor,
  }) async {
    final HomeViewState? current = state.valueOrNull;
    if (current == null) {
      return null;
    }

    final String trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return null;
    }

    final String categoryId = await _generateUniqueCategoryId(trimmedTitle);
    final SubjectCategory category = SubjectCategory(
      id: categoryId,
      title: trimmedTitle,
      icon: Icons.auto_awesome_rounded,
      accentColor: accentColor,
      section: 'CUSTOM',
    );

    if (_persistenceEnabled) {
      await _repo.insertCategory(category);
    }

    final List<SubjectCategory> nextCategories = <SubjectCategory>[
      ...current.categories,
      category,
    ];

    state = AsyncData(current.copyWith(categories: nextCategories));
    await switchCategory(category);

    return category;
  }

  Future<void> setKeepScreenAwakeEnabled(bool enabled) async {
    _keepScreenAwakeEnabled = enabled;
    await _settingsService.setKeepScreenAwake(enabled);

    final HomeViewState? current = state.valueOrNull;
    if (current != null) {
      await _tickerService.updateWakelock(
        _shouldEnableWakelockForCategory(current.currentCategory.id),
      );
    }
  }

  Future<void> updateDefaultFocusDurationMinutes(int minutes) async {
    final int normalizedMinutes = switch (minutes) {
      25 || 60 || 90 => minutes,
      _ => 60,
    };

    await _settingsService.setDefaultFocusMinutes(normalizedMinutes);
  }

  Future<void> _tick() async {
    final HomeViewState? current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final DateTime sessionStartTime = _resolveSessionStartTime(current.timer);
    final Duration elapsed = DateTime.now().difference(sessionStartTime);
    final Duration normalizedElapsed =
        elapsed.isNegative ? Duration.zero : elapsed;

    if (normalizedElapsed.inSeconds == current.timer.elapsed.inSeconds) {
      return;
    }

    final TimerSnapshot nextTimer = current.timer.copyWith(
      sessionStartTime: sessionStartTime,
      elapsed: normalizedElapsed,
    );
    state = AsyncData(current.copyWith(timer: nextTimer));

    if (_persistenceEnabled && normalizedElapsed.inSeconds % 30 == 0) {
      await _repo.saveTimerSnapshot(nextTimer);
    }
  }

  SubjectCategory? _categoryById(String id) {
    final List<SubjectCategory>? categories = state.valueOrNull?.categories;
    if (categories == null) {
      return null;
    }

    for (final SubjectCategory category in categories) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }

  bool _isNonProductiveCategoryId(String categoryId) {
    final String normalized = categoryId.toLowerCase();
    return normalized == 'break' ||
        normalized == 'idle' ||
        normalized == 'sleep';
  }

  bool _isProductiveCategoryId(String categoryId) {
    return !_isNonProductiveCategoryId(categoryId);
  }

  bool _shouldEnableWakelockForCategory(String categoryId) {
    return _keepScreenAwakeEnabled && _isProductiveCategoryId(categoryId);
  }

  String _slugify(String value) {
    final String lowered = value.toLowerCase();
    final String slug = lowered.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final String trimmed = slug.replaceAll(RegExp(r'^-+|-+$'), '');
    return trimmed.isEmpty ? 'category' : trimmed;
  }

  Future<String> _generateUniqueCategoryId(String title) async {
    final String base = _slugify(title);
    String candidate = base;
    int suffix = 2;

    while (_categoryById(candidate) != null ||
        (_persistenceEnabled && await _repo.categoryIdExists(candidate))) {
      candidate = '$base-$suffix';
      suffix += 1;
    }

    return candidate;
  }

  DateTime _resolveSessionStartTime(TimerSnapshot timer) {
    try {
      return timer.sessionStartTime;
    } catch (_) {
      final Duration fallbackElapsed = _safeElapsed(timer);
      return DateTime.now().subtract(fallbackElapsed);
    }
  }

  Duration _safeElapsed(TimerSnapshot timer) {
    try {
      return timer.elapsed;
    } catch (_) {
      return Duration.zero;
    }
  }
}
