import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/services/app_settings_service.dart';
import '../domain/models/home_stats.dart';
import '../domain/models/home_view_state.dart';
import '../domain/models/subject_category.dart';
import '../domain/models/timer_snapshot.dart';
import '../domain/repositories/timer_repository.dart';
import 'timer_service.dart';

class HomeViewNotifier extends AsyncNotifier<HomeViewState>
    with WidgetsBindingObserver {
  static const Duration _fallbackTarget = Duration(minutes: 60);

  late TimerRepository _repository;
  late TimerService _timerService;
  late AppSettingsService _appSettingsService;
  Duration _sessionStartElapsed = Duration.zero;
  DateTime? _sessionStartedAt;
  DateTime? _backgroundedAt;
  bool _observerAttached = false;
  final bool _persistenceEnabled = true;
  bool _keepScreenAwakeEnabled = true;

  @override
  Future<HomeViewState> build() async {
    _appSettingsService = ref.read(appSettingsServiceProvider);
    _repository = TimerRepository(
      database: ref.read(databaseProvider),
      preferences: ref.read(sharedPreferencesProvider),
    );
    _timerService = TimerService(
      sensoryService: ref.read(sensoryServiceProvider),
      notificationService: ref.read(notificationServiceProvider),
    );

    final AppSettingsSnapshot settings = await _appSettingsService.snapshot();
    _keepScreenAwakeEnabled = settings.keepScreenAwake;
    final Duration configuredDefaultTarget = Duration(
      minutes: settings.defaultFocusMinutes,
    );

    if (!_observerAttached) {
      WidgetsBinding.instance.addObserver(this);
      _observerAttached = true;
    }

    ref.onDispose(() {
      unawaited(_timerService.dispose());
      if (_observerAttached) {
        WidgetsBinding.instance.removeObserver(this);
        _observerAttached = false;
      }
    });

    final List<SubjectCategory> categories = await _repository.loadCategories();
    final String? selectedCategoryId =
        await _repository.loadSelectedCategoryId();
    final SubjectCategory currentCategory = categories.firstWhere(
      (SubjectCategory category) => category.id == selectedCategoryId,
      orElse: () => categories.first,
    );

    final TimerSnapshot timer = await _repository.loadTimerSnapshot(
      defaultTarget: configuredDefaultTarget,
    );

    final HomeStats stats = await _repository.loadHomeStats(
      categories: categories,
      currentCategoryId: currentCategory.id,
    );

    final HomeViewState initialState = HomeViewState(
      categories: categories,
      currentCategory: currentCategory,
      stats: stats,
      timer: timer,
    );

    if (timer.isRunning) {
      _sessionStartElapsed = timer.sessionStartElapsed;
      final DateTime? sessionStartTime = timer.sessionStartTime;
      if (sessionStartTime != null) {
        _sessionStartedAt = sessionStartTime.add(timer.sessionStartElapsed);
      } else {
        _sessionStartElapsed = timer.elapsed;
        _sessionStartedAt = DateTime.now();
      }

      _timerService.startTicker(onTick: _tick);
      await _timerService.updateWakelock(
        _shouldEnableWakelockForCategory(currentCategory.id),
      );
      if (_persistenceEnabled) {
        await _timerService.scheduleCompletion(
          remaining: _remainingDuration(timer),
          categoryTitle: currentCategory.title,
        );
      }
    }

    return initialState;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _handleAppBackgrounded();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      unawaited(_handleAppResumed());
    }
  }

  Future<void> toggleTimer() async {
    final HomeViewState? current = state.valueOrNull;
    if (current == null) {
      return;
    }

    if (current.timer.isRunning) {
      await _stopTimerAndRecordSession(current);
      return;
    }

    final DateTime now = DateTime.now();
    final TimerSnapshot nextTimer = current.timer.copyWith(
      isRunning: true,
      sessionStartTime: now.subtract(current.timer.elapsed),
      sessionStartElapsed: current.timer.elapsed,
    );
    final HomeViewState next = current.copyWith(timer: nextTimer);
    state = AsyncData(next);

    _sessionStartElapsed = current.timer.elapsed;
    _sessionStartedAt = now;
    _timerService.startTicker(onTick: _tick);

    await _timerService.onSessionStarted(
      remaining: _remainingDuration(nextTimer),
      enableWakelock: _shouldEnableWakelockForCategory(next.currentCategory.id),
      categoryTitle: next.currentCategory.title,
    );

    if (_persistenceEnabled) {
      await _repository.saveTimerSnapshot(nextTimer);
    }
  }

  Future<void> switchCategory(SubjectCategory category) async {
    final HomeViewState? current = state.valueOrNull;
    if (current == null) {
      return;
    }

    state = AsyncData(current.copyWith(currentCategory: category));
    unawaited(_timerService.onCategorySwitched());
    if (current.timer.isRunning) {
      await _timerService.updateWakelock(
        _shouldEnableWakelockForCategory(category.id),
      );
      await _timerService.scheduleCompletion(
        remaining: _remainingDuration(current.timer),
        categoryTitle: category.title,
      );
    }
    if (_persistenceEnabled) {
      await _repository.saveSelectedCategoryId(category.id);
    }
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
      await _repository.insertCategory(category);
      await _repository.saveSelectedCategoryId(category.id);
    }

    final List<SubjectCategory> nextCategories = <SubjectCategory>[
      ...current.categories,
      category,
    ];

    final HomeStats nextStats =
        _persistenceEnabled
            ? await _repository.loadHomeStats(
              categories: nextCategories,
              currentCategoryId: category.id,
            )
            : current.stats.copyWith(next: category.title);

    final HomeViewState nextState = current.copyWith(
      categories: nextCategories,
      currentCategory: category,
      stats: nextStats,
    );

    state = AsyncData(nextState);
    unawaited(_timerService.onCategorySwitched());

    if (current.timer.isRunning) {
      await _timerService.updateWakelock(
        _shouldEnableWakelockForCategory(category.id),
      );
      await _timerService.scheduleCompletion(
        remaining: _remainingDuration(current.timer),
        categoryTitle: category.title,
      );
    }

    return category;
  }

  Future<void> setKeepScreenAwakeEnabled(bool enabled) async {
    _keepScreenAwakeEnabled = enabled;
    await _appSettingsService.setKeepScreenAwake(enabled);

    final HomeViewState? current = state.valueOrNull;
    if (current != null && current.timer.isRunning) {
      await _timerService.updateWakelock(
        _shouldEnableWakelockForCategory(current.currentCategory.id),
      );
    }
  }

  Future<void> updateDefaultFocusDurationMinutes(int minutes) async {
    final int normalizedMinutes = switch (minutes) {
      25 || 60 || 90 => minutes,
      _ => _fallbackTarget.inMinutes,
    };

    await _appSettingsService.setDefaultFocusMinutes(normalizedMinutes);

    final HomeViewState? current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final Duration nextTarget = Duration(minutes: normalizedMinutes);
    final Duration nextElapsed =
        current.timer.elapsed > nextTarget ? nextTarget : current.timer.elapsed;

    final TimerSnapshot nextTimer = current.timer.copyWith(
      target: nextTarget,
      elapsed: nextElapsed,
      sessionStartElapsed:
          current.timer.sessionStartElapsed > nextElapsed
              ? nextElapsed
              : current.timer.sessionStartElapsed,
    );

    state = AsyncData(current.copyWith(timer: nextTimer));

    if (_persistenceEnabled) {
      await _repository.saveTimerSnapshot(nextTimer);
    }

    if (nextTimer.isRunning) {
      await _timerService.scheduleCompletion(
        remaining: _remainingDuration(nextTimer),
        categoryTitle: current.currentCategory.title,
      );
    }
  }

  Future<void> _tick() async {
    final HomeViewState? current = state.valueOrNull;
    if (current == null || !current.timer.isRunning) {
      return;
    }

    final Duration nextElapsed =
        current.timer.elapsed + const Duration(seconds: 1);
    final bool completed = nextElapsed >= current.timer.target;

    final TimerSnapshot nextTimer = current.timer.copyWith(
      elapsed: completed ? current.timer.target : nextElapsed,
      isRunning: !completed,
      clearSessionStartTime: completed,
      sessionStartElapsed:
          completed ? current.timer.target : current.timer.sessionStartElapsed,
    );
    final HomeViewState next = current.copyWith(timer: nextTimer);
    state = AsyncData(next);

    if (_persistenceEnabled) {
      await _repository.saveTimerSnapshot(nextTimer);
    }

    if (completed) {
      await _completeTimerSession(next);
    }
  }

  Future<void> _stopTimerAndRecordSession(HomeViewState current) async {
    _timerService.stopTicker();
    await _timerService.onSessionStopped();

    final TimerSnapshot nextTimer = current.timer.copyWith(
      isRunning: false,
      clearSessionStartTime: true,
      sessionStartElapsed: current.timer.elapsed,
    );
    await _persistSessionIfNeeded(
      currentCategoryId: current.currentCategory.id,
      endElapsed: nextTimer.elapsed,
    );

    final HomeStats stats =
        _persistenceEnabled
            ? await _repository.loadHomeStats(
              categories: current.categories,
              currentCategoryId: current.currentCategory.id,
            )
            : current.stats;

    final HomeViewState next = current.copyWith(timer: nextTimer, stats: stats);
    state = AsyncData(next);

    if (_persistenceEnabled) {
      await _repository.saveTimerSnapshot(nextTimer);
    }
  }

  Future<void> _completeTimerSession(HomeViewState current) async {
    _timerService.stopTicker();
    await _timerService.onSessionCompleted();

    final TimerSnapshot completedTimer = current.timer.copyWith(
      isRunning: false,
      clearSessionStartTime: true,
      sessionStartElapsed: current.timer.elapsed,
    );

    final HomeViewState completedState = current.copyWith(
      timer: completedTimer,
    );
    state = AsyncData(completedState);
    if (_persistenceEnabled) {
      await _repository.saveTimerSnapshot(completedTimer);
    }

    await _persistSessionIfNeeded(
      currentCategoryId: completedState.currentCategory.id,
      endElapsed: completedState.timer.elapsed,
    );

    final HomeStats stats =
        _persistenceEnabled
            ? await _repository.loadHomeStats(
              categories: completedState.categories,
              currentCategoryId: completedState.currentCategory.id,
            )
            : completedState.stats;

    state = AsyncData(completedState.copyWith(stats: stats));
  }

  Future<void> _persistSessionIfNeeded({
    required String currentCategoryId,
    required Duration endElapsed,
  }) async {
    final DateTime? startedAt = _sessionStartedAt;
    if (startedAt == null) {
      return;
    }

    final Duration sessionDuration = endElapsed - _sessionStartElapsed;
    if (sessionDuration <= Duration.zero) {
      _sessionStartedAt = null;
      _sessionStartElapsed = endElapsed;
      return;
    }

    if (_persistenceEnabled) {
      await _repository.saveSession(
        categoryId: currentCategoryId,
        startedAt: startedAt,
        endedAt: DateTime.now(),
        duration: sessionDuration,
        isProductive:
            currentCategoryId != 'break' && currentCategoryId != 'idle',
      );
    }

    _sessionStartedAt = null;
    _sessionStartElapsed = endElapsed;
  }

  void _handleAppBackgrounded() {
    final HomeViewState? current = state.valueOrNull;
    if (current == null || !current.timer.isRunning) {
      return;
    }

    _backgroundedAt = DateTime.now();
    _timerService.stopTicker();
    if (_persistenceEnabled) {
      unawaited(_repository.saveTimerSnapshot(current.timer));
    }
  }

  Future<void> _handleAppResumed() async {
    final HomeViewState? current = state.valueOrNull;
    if (current == null || !current.timer.isRunning) {
      _backgroundedAt = null;
      return;
    }

    final DateTime? priorBackgroundedAt = _backgroundedAt;
    _backgroundedAt = null;

    Duration nextElapsed = current.timer.elapsed;
    if (current.timer.sessionStartTime != null) {
      final Duration absoluteElapsed = DateTime.now().difference(
        current.timer.sessionStartTime!,
      );
      if (!absoluteElapsed.isNegative) {
        nextElapsed = absoluteElapsed;
      }
    } else if (priorBackgroundedAt != null) {
      final Duration drift = DateTime.now().difference(priorBackgroundedAt);
      if (!drift.isNegative) {
        nextElapsed = current.timer.elapsed + drift;
      }
    }

    final bool completed = nextElapsed >= current.timer.target;

    final TimerSnapshot nextTimer = current.timer.copyWith(
      elapsed: completed ? current.timer.target : nextElapsed,
      isRunning: !completed,
      clearSessionStartTime: completed,
      sessionStartElapsed:
          completed ? current.timer.target : current.timer.sessionStartElapsed,
    );
    final HomeViewState next = current.copyWith(timer: nextTimer);
    state = AsyncData(next);

    if (_persistenceEnabled) {
      await _repository.saveTimerSnapshot(nextTimer);
    }

    if (completed) {
      await _completeTimerSession(next);
      return;
    }

    _timerService.startTicker(onTick: _tick);
    if (_persistenceEnabled) {
      await _timerService.scheduleCompletion(
        remaining: _remainingDuration(nextTimer),
        categoryTitle: next.currentCategory.title,
      );
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

  bool _isDeepWorkCategoryId(String categoryId) {
    return categoryId != 'break' && categoryId != 'idle';
  }

  bool _shouldEnableWakelockForCategory(String categoryId) {
    return _keepScreenAwakeEnabled && _isDeepWorkCategoryId(categoryId);
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
        (_persistenceEnabled &&
            await _repository.categoryIdExists(candidate))) {
      candidate = '$base-$suffix';
      suffix += 1;
    }

    return candidate;
  }

  Duration _remainingDuration(TimerSnapshot timer) {
    final Duration remaining = timer.target - timer.elapsed;
    if (remaining.isNegative) {
      return Duration.zero;
    }
    return remaining;
  }
}
