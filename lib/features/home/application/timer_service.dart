import 'dart:async';

import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/services/sensory_service.dart';

class TimerService {
  Timer? _ticker;

  void startTicker({required Future<void> Function() onTick}) {
    stopTicker();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => unawaited(onTick()),
    );
  }

  void stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  Future<void> onSessionStarted({
    required Duration remaining,
    required bool enableWakelock,
    required String categoryTitle,
  }) async {
    unawaited(SensoryService.instance.sessionStarted());
    await _setWakelockEnabled(enableWakelock);
    await _scheduleCompletionIfNeeded(
      remaining: remaining,
      categoryTitle: categoryTitle,
    );
  }

  Future<void> onSessionStopped() async {
    unawaited(SensoryService.instance.sessionStopped());
    await _setWakelockEnabled(false);
    await NotificationService.instance.cancelTimerCompletion();
  }

  Future<void> onCategorySwitched() async {
    unawaited(SensoryService.instance.tap());
  }

  Future<void> onSessionCompleted() async {
    unawaited(SensoryService.instance.sessionCompleted());
    await _setWakelockEnabled(false);
    await NotificationService.instance.cancelTimerCompletion();
  }

  Future<void> updateWakelock(bool enabled) async {
    await _setWakelockEnabled(enabled);
  }

  Future<void> scheduleCompletion({
    required Duration remaining,
    required String categoryTitle,
  }) async {
    await _scheduleCompletionIfNeeded(
      remaining: remaining,
      categoryTitle: categoryTitle,
    );
  }

  Future<void> dispose() async {
    stopTicker();
    await _setWakelockEnabled(false);
  }

  Future<void> _scheduleCompletionIfNeeded({
    required Duration remaining,
    required String categoryTitle,
  }) async {
    await NotificationService.instance.cancelTimerCompletion();
    if (remaining <= Duration.zero) {
      return;
    }
    await NotificationService.instance.scheduleTimerCompletion(
      delay: remaining,
      categoryTitle: categoryTitle,
    );
  }

  Future<void> _setWakelockEnabled(bool enabled) async {
    try {
      if (enabled) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    } catch (_) {
      // Keep core timer behavior healthy even if wakelock fails.
    }
  }
}
