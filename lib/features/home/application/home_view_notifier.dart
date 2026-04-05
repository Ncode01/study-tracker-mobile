import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/local/app_database.dart';
import '../domain/models/home_stats.dart';
import '../domain/models/home_view_state.dart';
import '../domain/models/subject_category.dart';
import '../domain/models/timer_snapshot.dart';
import '../domain/repositories/timer_repository.dart';
import 'timer_service.dart';

class HomeViewNotifier extends AsyncNotifier<HomeViewState>
    with WidgetsBindingObserver {
  static const Duration _defaultTarget = Duration(hours: 5);

  late final TimerRepository _repository;
  final TimerService _timerService = TimerService();
  Duration _sessionStartElapsed = Duration.zero;
  DateTime? _sessionStartedAt;
  DateTime? _backgroundedAt;
  bool _observerAttached = false;
  bool _persistenceEnabled = true;

  @override
  Future<HomeViewState> build() async {
    try {
      _repository = TimerRepository(
        database: AppDatabase.instance,
        preferences: await SharedPreferences.getInstance(),
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

      final List<SubjectCategory> categories =
          await _repository.loadCategories();
      final String? selectedCategoryId =
          await _repository.loadSelectedCategoryId();
      final SubjectCategory currentCategory = categories.firstWhere(
        (SubjectCategory category) => category.id == selectedCategoryId,
        orElse: () => categories.first,
      );

      final TimerSnapshot timer = await _repository.loadTimerSnapshot(
        defaultTarget: _defaultTarget,
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
          _isDeepWorkCategoryId(currentCategory.id),
        );
        if (_persistenceEnabled) {
          await _timerService.scheduleCompletion(
            remaining: _remainingDuration(timer),
            categoryTitle: currentCategory.title,
          );
        }
      }

      return initialState;
    } catch (_) {
      _persistenceEnabled = false;
      return _fallbackState();
    }
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
      enableWakelock: _isDeepWorkCategoryId(next.currentCategory.id),
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
      await _timerService.updateWakelock(_isDeepWorkCategoryId(category.id));
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

    final HomeStats stats = _persistenceEnabled
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

    final HomeViewState completedState =
        current.copyWith(timer: completedTimer);
    state = AsyncData(completedState);
    if (_persistenceEnabled) {
      await _repository.saveTimerSnapshot(completedTimer);
    }

    await _persistSessionIfNeeded(
      currentCategoryId: completedState.currentCategory.id,
      endElapsed: completedState.timer.elapsed,
    );

    final HomeStats stats = _persistenceEnabled
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
      final Duration absoluteElapsed =
          DateTime.now().difference(current.timer.sessionStartTime!);
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

  Duration _remainingDuration(TimerSnapshot timer) {
    final Duration remaining = timer.target - timer.elapsed;
    if (remaining.isNegative) {
      return Duration.zero;
    }
    return remaining;
  }

  HomeViewState _fallbackState() {
    const List<SubjectCategory> categories = <SubjectCategory>[
      SubjectCategory(
        id: 'physics',
        title: 'Physics',
        icon: Icons.bolt_outlined,
        accentColor: Color(0xFF3B82F6),
        section: 'A/LEVELS',
      ),
      SubjectCategory(
        id: 'maths',
        title: 'Maths',
        icon: Icons.calculate_outlined,
        accentColor: Color(0xFFF43F5E),
        section: 'A/LEVELS',
      ),
      SubjectCategory(
        id: 'chemistry',
        title: 'Chemistry',
        icon: Icons.science_outlined,
        accentColor: Color(0xFF22C55E),
        section: 'A/LEVELS',
      ),
      SubjectCategory(
        id: 'break',
        title: 'Break',
        icon: Icons.free_breakfast_outlined,
        accentColor: Color(0xFF8554F8),
        section: 'LIFESTYLE & OTHER',
      ),
      SubjectCategory(
        id: 'idle',
        title: 'Idle',
        icon: Icons.hourglass_empty_rounded,
        accentColor: Color(0xFF64748B),
        section: 'LIFESTYLE & OTHER',
      ),
    ];

    return HomeViewState(
      categories: categories,
      currentCategory: categories.first,
      stats: HomeStats(
        totalProductive: '4h 12m',
        streak: '2h 00m',
        next: 'Chemistry',
      ),
      timer: TimerSnapshot(
        elapsed: Duration(hours: 2, minutes: 14, seconds: 45),
        target: Duration(hours: 5),
        isRunning: false,
        sessionStartElapsed: Duration(hours: 2, minutes: 14, seconds: 45),
      ),
    );
  }
}
