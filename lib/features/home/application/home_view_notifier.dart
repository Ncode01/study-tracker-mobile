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
  static const Duration _shortBreakDuration = Duration(minutes: 5);
  static const Duration _longBreakDuration = Duration(minutes: 15);
  static const int _longBreakEveryFocusSessions = 4;

  TimerRepository? _repository;
  TimerService? _timerService;
  AppSettingsService? _appSettingsService;
  SensoryService? _sensoryService;
  final bool _persistenceEnabled = true;
  bool _keepScreenAwakeEnabled = true;
  int _focusMinutes = 60;
  int _weeklyTargetMinutes = 10 * 60;
  bool _tickInFlight = false;

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

    final AppSettingsSnapshot settings = await settingsService.snapshot();
    _keepScreenAwakeEnabled = settings.keepScreenAwake;
    _focusMinutes = settings.defaultFocusMinutes;
    _weeklyTargetMinutes = settings.weeklyFocusTargetMinutes;

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

    final TimerSnapshot timer = await _repo.loadTimerSnapshot(
      focusMinutes: _focusMinutes,
    );

    final HomeStats stats = await _loadStats(
      categories: categories,
      currentCategoryId: currentCategory.id,
    );

    final HomeViewState initialState = HomeViewState(
      categories: categories,
      currentCategory: currentCategory,
      stats: stats,
      timer: timer,
    );

    await _syncPersistence(initialState);

    _tickerService.startTicker(onTick: _tick);
    await _tickerService.updateWakelock(
      _shouldEnableWakelockForState(initialState),
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
    final bool runningFocusSession =
        current.timer.isRunning && current.timer.phase == PomodoroPhase.focus;
    TimerSnapshot nextTimer = current.timer;

    if (runningFocusSession) {
      await _persistRunningSegmentIfNeeded(baseState: current, endedAt: now);
      nextTimer = current.timer.copyWith(
        elapsed: Duration.zero,
        isRunning: true,
        runningSince: now,
      );
    }

    final HomeStats nextStats = await _loadStats(
      categories: current.categories,
      currentCategoryId: category.id,
    );

    final HomeViewState nextState = current.copyWith(
      currentCategory: category,
      timer: nextTimer,
      stats: nextStats,
    );
    state = AsyncData(nextState);

    await _syncPersistence(nextState);

    unawaited(_playSwitchFeedbackSafely());

    await _tickerService.updateWakelock(
      _shouldEnableWakelockForState(nextState),
    );
  }

  Future<void> startFocusForCategoryId({
    required String categoryId,
    String? categoryTitle,
    Color? accentColor,
    IconData? icon,
    bool createIfMissing = false,
  }) async {
    final HomeViewState? current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final String normalizedId = _slugify(categoryId);
    SubjectCategory? target = _categoryById(normalizedId);

    if (target == null && createIfMissing) {
      target = SubjectCategory(
        id: normalizedId,
        title: _normalizeExternalTitle(categoryTitle, normalizedId),
        icon: icon ?? Icons.auto_awesome_rounded,
        accentColor: accentColor ?? const Color(0xFF64748B),
        section: 'CUSTOM',
      );

      if (_persistenceEnabled) {
        await _repo.insertCategory(target);
      }

      final HomeViewState? latest = state.valueOrNull;
      final HomeViewState base = latest ?? current;

      if (_categoryById(normalizedId) == null) {
        state = AsyncData(
          base.copyWith(
            categories: <SubjectCategory>[...base.categories, target],
          ),
        );
      } else {
        target = _categoryById(normalizedId);
      }
    }

    final HomeViewState? latest = state.valueOrNull;
    if (latest == null) {
      return;
    }

    final SubjectCategory category =
        target ?? _categoryById(normalizedId) ?? latest.currentCategory;

    await _startFocusForCategory(category: category, baseState: latest);
  }

  Future<SubjectCategory?> createCategory({
    required String title,
    required Color accentColor,
    bool switchToCategory = true,
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
    if (switchToCategory) {
      await switchCategory(category);
    }

    return category;
  }

  Future<void> setKeepScreenAwakeEnabled(bool enabled) async {
    _keepScreenAwakeEnabled = enabled;
    await _settingsService.setKeepScreenAwake(enabled);

    final HomeViewState? current = state.valueOrNull;
    if (current != null) {
      await _tickerService.updateWakelock(
        _shouldEnableWakelockForState(current),
      );
    }
  }

  Future<void> updateDefaultFocusDurationMinutes(int minutes) async {
    final int normalizedMinutes = switch (minutes) {
      25 || 60 || 90 => minutes,
      _ => 60,
    };

    await _settingsService.setDefaultFocusMinutes(normalizedMinutes);
    _focusMinutes = normalizedMinutes;

    final HomeViewState? current = state.valueOrNull;
    if (current == null) {
      return;
    }

    if (current.timer.phase == PomodoroPhase.focus &&
        !current.timer.isRunning) {
      final Duration nextDuration = Duration(minutes: normalizedMinutes);
      final Duration clampedElapsed =
          current.timer.elapsed > nextDuration
              ? nextDuration
              : current.timer.elapsed;
      final TimerSnapshot nextTimer = current.timer.copyWith(
        phaseDuration: nextDuration,
        elapsed: clampedElapsed,
      );
      final HomeViewState nextState = current.copyWith(timer: nextTimer);
      state = AsyncData(nextState);
      await _syncPersistence(nextState);
    }
  }

  Future<void> updateWeeklyTargetMinutes(int minutes) async {
    final int normalizedMinutes = switch (minutes) {
      300 || 600 || 900 || 1200 => minutes,
      _ => 600,
    };

    await _settingsService.setWeeklyFocusTargetMinutes(normalizedMinutes);
    _weeklyTargetMinutes = normalizedMinutes;

    final HomeViewState? current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final HomeStats nextStats = await _loadStats(
      categories: current.categories,
      currentCategoryId: current.currentCategory.id,
    );
    state = AsyncData(current.copyWith(stats: nextStats));
  }

  Future<void> startOrResumeTimer() async {
    final HomeViewState? current = state.valueOrNull;
    if (current == null || current.timer.isRunning) {
      return;
    }

    final DateTime now = DateTime.now();
    final TimerSnapshot nextTimer = current.timer.copyWith(
      isRunning: true,
      runningSince: now,
    );
    final HomeViewState nextState = current.copyWith(timer: nextTimer);
    state = AsyncData(nextState);

    await _syncPersistence(nextState);
    await _tickerService.updateWakelock(
      _shouldEnableWakelockForState(nextState),
    );
  }

  Future<void> pauseTimer() async {
    final HomeViewState? current = state.valueOrNull;
    if (current == null || !current.timer.isRunning) {
      return;
    }

    final DateTime now = DateTime.now();
    await _persistRunningSegmentIfNeeded(baseState: current, endedAt: now);

    final TimerSnapshot nextTimer = current.timer
        .materializeAt(now)
        .copyWith(isRunning: false, clearRunningSince: true);

    final HomeStats nextStats = await _loadStats(
      categories: current.categories,
      currentCategoryId: current.currentCategory.id,
    );

    final HomeViewState nextState = current.copyWith(
      timer: nextTimer,
      stats: nextStats,
    );
    state = AsyncData(nextState);

    await _syncPersistence(nextState);
    await _tickerService.updateWakelock(false);
  }

  Future<void> stopTimer() async {
    final HomeViewState? current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final DateTime now = DateTime.now();
    if (current.timer.isRunning) {
      await _persistRunningSegmentIfNeeded(baseState: current, endedAt: now);
    }

    final TimerSnapshot nextTimer = TimerSnapshot.idleFocus(
      focusDuration: Duration(minutes: _focusMinutes),
      completedFocusSessions: 0,
    );

    final HomeStats nextStats = await _loadStats(
      categories: current.categories,
      currentCategoryId: current.currentCategory.id,
    );

    final HomeViewState nextState = current.copyWith(
      timer: nextTimer,
      stats: nextStats,
    );
    state = AsyncData(nextState);

    await _syncPersistence(nextState);
    await _tickerService.updateWakelock(false);
  }

  Future<void> startBreakNow() async {
    final HomeViewState? current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final DateTime now = DateTime.now();
    if (current.timer.isRunning) {
      await _persistRunningSegmentIfNeeded(baseState: current, endedAt: now);
    }

    final TimerSnapshot nextTimer = TimerSnapshot(
      phase: PomodoroPhase.shortBreak,
      phaseDuration: _shortBreakDuration,
      elapsed: Duration.zero,
      isRunning: true,
      completedFocusSessions: current.timer.completedFocusSessions,
      runningSince: now,
    );

    final HomeStats nextStats = await _loadStats(
      categories: current.categories,
      currentCategoryId: current.currentCategory.id,
    );

    final HomeViewState nextState = current.copyWith(
      timer: nextTimer,
      stats: nextStats,
    );
    state = AsyncData(nextState);

    await _syncPersistence(nextState);
    await _tickerService.updateWakelock(false);
  }

  Future<void> skipBreak() async {
    final HomeViewState? current = state.valueOrNull;
    if (current == null || current.timer.phase == PomodoroPhase.focus) {
      return;
    }

    final DateTime now = DateTime.now();
    if (current.timer.isRunning) {
      await _persistRunningSegmentIfNeeded(baseState: current, endedAt: now);
    }

    final TimerSnapshot nextTimer = TimerSnapshot.idleFocus(
      focusDuration: Duration(minutes: _focusMinutes),
      completedFocusSessions: current.timer.completedFocusSessions,
    );

    final HomeStats nextStats = await _loadStats(
      categories: current.categories,
      currentCategoryId: current.currentCategory.id,
    );

    final HomeViewState nextState = current.copyWith(
      timer: nextTimer,
      stats: nextStats,
    );
    state = AsyncData(nextState);

    await _syncPersistence(nextState);
    await _tickerService.updateWakelock(false);
  }

  Future<void> _startFocusForCategory({
    required SubjectCategory category,
    required HomeViewState baseState,
  }) async {
    final DateTime now = DateTime.now();

    if (baseState.timer.isRunning) {
      await _persistRunningSegmentIfNeeded(baseState: baseState, endedAt: now);
    }

    final TimerSnapshot nextTimer = TimerSnapshot(
      phase: PomodoroPhase.focus,
      phaseDuration: Duration(minutes: _focusMinutes),
      elapsed: Duration.zero,
      isRunning: true,
      completedFocusSessions: baseState.timer.completedFocusSessions,
      runningSince: now,
    );

    final HomeStats nextStats = await _loadStats(
      categories: baseState.categories,
      currentCategoryId: category.id,
    );

    final HomeViewState nextState = baseState.copyWith(
      currentCategory: category,
      timer: nextTimer,
      stats: nextStats,
    );
    state = AsyncData(nextState);

    await _syncPersistence(nextState);
    await _tickerService.updateWakelock(
      _shouldEnableWakelockForState(nextState),
    );

    unawaited(_playSwitchFeedbackSafely());
  }

  Future<void> _tick() async {
    if (_tickInFlight) {
      return;
    }
    _tickInFlight = true;

    final HomeViewState? current = state.valueOrNull;
    if (current == null || !current.timer.isRunning) {
      _tickInFlight = false;
      return;
    }

    try {
      final DateTime now = DateTime.now();
      final DateTime? segmentStart = current.timer.runningSince;
      final TimerSnapshot progressed = current.timer.materializeAt(now);

      final HomeViewState? latest = state.valueOrNull;
      if (latest == null) {
        return;
      }
      if (!_sameTimerRun(latest.timer, current.timer) ||
          latest.currentCategory.id != current.currentCategory.id) {
        return;
      }

      final HomeViewState progressedState = latest.copyWith(timer: progressed);
      state = AsyncData(progressedState);

      if (progressed.isPhaseCompleteAt(now)) {
        await _handleCompletedPhase(
          previous: current,
          progressed: progressed,
          completedAt: now,
          segmentStart: segmentStart,
        );
        return;
      }

      if (_persistenceEnabled && progressed.elapsed.inSeconds % 15 == 0) {
        await _repo.saveTimerSnapshot(progressed);
      }
    } finally {
      _tickInFlight = false;
    }
  }

  Future<void> _handleCompletedPhase({
    required HomeViewState previous,
    required TimerSnapshot progressed,
    required DateTime completedAt,
    required DateTime? segmentStart,
  }) async {
    if (segmentStart != null) {
      await _persistSessionSegment(
        baseState: previous,
        startedAt: segmentStart,
        endedAt: completedAt,
      );
    }

    TimerSnapshot nextTimer;
    if (progressed.phase == PomodoroPhase.focus) {
      final int completedFocusSessions = progressed.completedFocusSessions + 1;
      final PomodoroPhase breakPhase =
          completedFocusSessions % _longBreakEveryFocusSessions == 0
              ? PomodoroPhase.longBreak
              : PomodoroPhase.shortBreak;

      nextTimer = TimerSnapshot(
        phase: breakPhase,
        phaseDuration:
            breakPhase == PomodoroPhase.longBreak
                ? _longBreakDuration
                : _shortBreakDuration,
        elapsed: Duration.zero,
        isRunning: true,
        completedFocusSessions: completedFocusSessions,
        runningSince: completedAt,
      );
    } else {
      nextTimer = TimerSnapshot.idleFocus(
        focusDuration: Duration(minutes: _focusMinutes),
        completedFocusSessions: progressed.completedFocusSessions,
      );
    }

    final HomeViewState? latest = state.valueOrNull;
    if (latest == null || !_sameTimerRun(latest.timer, progressed)) {
      return;
    }

    final HomeStats nextStats = await _loadStats(
      categories: latest.categories,
      currentCategoryId: latest.currentCategory.id,
    );

    final HomeViewState nextState = latest.copyWith(
      timer: nextTimer,
      stats: nextStats,
    );
    state = AsyncData(nextState);

    await _syncPersistence(nextState);
    await _tickerService.updateWakelock(
      _shouldEnableWakelockForState(nextState),
    );

    unawaited(_playSwitchFeedbackSafely());
  }

  bool _sameTimerRun(TimerSnapshot a, TimerSnapshot b) {
    final int? aRunMs = a.runningSince?.millisecondsSinceEpoch;
    final int? bRunMs = b.runningSince?.millisecondsSinceEpoch;
    return a.phase == b.phase &&
        a.isRunning == b.isRunning &&
        aRunMs == bRunMs &&
        a.completedFocusSessions == b.completedFocusSessions;
  }

  Future<void> _persistRunningSegmentIfNeeded({
    required HomeViewState baseState,
    required DateTime endedAt,
  }) async {
    final DateTime? startedAt = baseState.timer.runningSince;
    if (startedAt == null) {
      return;
    }

    await _persistSessionSegment(
      baseState: baseState,
      startedAt: startedAt,
      endedAt: endedAt,
    );
  }

  Future<void> _persistSessionSegment({
    required HomeViewState baseState,
    required DateTime startedAt,
    required DateTime endedAt,
  }) async {
    if (!_persistenceEnabled || !endedAt.isAfter(startedAt)) {
      return;
    }

    final String categoryId = _activeCategoryIdForState(baseState);
    await _repo.saveSession(
      categoryId: categoryId,
      startedAt: startedAt,
      endedAt: endedAt,
      duration: endedAt.difference(startedAt),
      isProductive:
          baseState.timer.phase == PomodoroPhase.focus &&
          _isProductiveCategoryId(categoryId),
    );
  }

  Future<void> _syncPersistence(HomeViewState stateValue) async {
    if (!_persistenceEnabled) {
      return;
    }

    await _repo.saveSelectedCategoryId(stateValue.currentCategory.id);
    await _repo.saveTimerSnapshot(stateValue.timer);

    if (stateValue.timer.isRunning && stateValue.timer.runningSince != null) {
      await _repo.saveActiveSession(
        categoryId: _activeCategoryIdForState(stateValue),
        sessionStartTime: stateValue.timer.runningSince!,
      );
    } else {
      await _repo.clearActiveSession();
    }
  }

  Future<HomeStats> _loadStats({
    required List<SubjectCategory> categories,
    required String currentCategoryId,
  }) async {
    if (!_persistenceEnabled) {
      return const HomeStats(
        totalProductive: '0m',
        streak: '0m',
        next: '-',
        weeklyTargetProgress: '0m / 10h',
        weeklyAverage: '0m/day',
        planAdherence: 'No plan yet',
      );
    }

    return _repo.loadHomeStats(
      categories: categories,
      currentCategoryId: currentCategoryId,
      weeklyTargetMinutes: _weeklyTargetMinutes,
    );
  }

  String _activeCategoryIdForState(HomeViewState stateValue) {
    if (stateValue.timer.phase == PomodoroPhase.focus) {
      return stateValue.currentCategory.id;
    }

    for (final SubjectCategory category in stateValue.categories) {
      if (category.id.toLowerCase() == 'break') {
        return category.id;
      }
    }
    return stateValue.currentCategory.id;
  }

  Future<void> _playSwitchFeedbackSafely() async {
    if (!_canUsePlatformFeedback()) {
      return;
    }

    try {
      await _sensory.playSessionStart();
    } catch (_) {
      // Feedback side effects must never block the session switch path.
    }

    try {
      if (_settingsService.enableHaptics) {
        await HapticFeedback.heavyImpact();
      }
    } catch (_) {
      // Haptics can fail on some platforms and should be ignored safely.
    }
  }

  bool _canUsePlatformFeedback() {
    try {
      ServicesBinding.instance;
      return true;
    } catch (_) {
      return false;
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

  bool _shouldEnableWakelockForState(HomeViewState stateValue) {
    if (!_keepScreenAwakeEnabled || !stateValue.timer.isRunning) {
      return false;
    }
    if (stateValue.timer.phase != PomodoroPhase.focus) {
      return false;
    }

    final String activeCategoryId = _activeCategoryIdForState(stateValue);
    return _isProductiveCategoryId(activeCategoryId);
  }

  String _slugify(String value) {
    final String lowered = value.toLowerCase();
    final String slug = lowered.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final String trimmed = slug.replaceAll(RegExp(r'^-+|-+$'), '');
    return trimmed.isEmpty ? 'category' : trimmed;
  }

  String _normalizeExternalTitle(String? rawTitle, String normalizedId) {
    final String trimmed = rawTitle?.trim() ?? '';
    if (trimmed.isNotEmpty) {
      return trimmed;
    }

    final List<String> words = normalizedId
        .split('-')
        .where((String part) => part.trim().isNotEmpty)
        .toList(growable: false);
    if (words.isEmpty) {
      return 'Category';
    }

    return words
        .map(
          (String part) =>
              '${part.substring(0, 1).toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
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
}
