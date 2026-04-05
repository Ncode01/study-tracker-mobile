import 'dart:async';

import 'package:wakelock_plus/wakelock_plus.dart';

class TimerService {
  TimerService();

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

  Future<void> updateWakelock(bool enabled) async {
    await _setWakelockEnabled(enabled);
  }

  Future<void> dispose() async {
    stopTicker();
    await _setWakelockEnabled(false);
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
