import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import 'app_settings_service.dart';

class SensoryService {
  SensoryService._();

  static final SensoryService instance = SensoryService._();

  final AudioPlayer _audioPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  Future<void> tap() async {
    await _ensureSettingsLoaded();
    if (!AppSettingsService.instance.enableHaptics) {
      return;
    }
    await HapticFeedback.selectionClick();
  }

  Future<void> sessionStarted() async {
    await _ensureSettingsLoaded();
    if (AppSettingsService.instance.enableHaptics) {
      await HapticFeedback.mediumImpact();
    }
    if (AppSettingsService.instance.enableSound) {
      await _tryPlayCue('audio/session_start.mp3');
    }
  }

  Future<void> sessionStopped() async {
    await _ensureSettingsLoaded();
    if (!AppSettingsService.instance.enableHaptics) {
      return;
    }
    await HapticFeedback.lightImpact();
  }

  Future<void> sessionCompleted() async {
    await _ensureSettingsLoaded();
    if (AppSettingsService.instance.enableHaptics) {
      await HapticFeedback.heavyImpact();
    }
    if (AppSettingsService.instance.enableSound) {
      await _tryPlayCue('audio/session_complete.mp3');
    }
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }

  Future<void> _tryPlayCue(String assetPath) async {
    try {
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (_) {
      // Audio cues are optional. Missing assets or unsupported platforms are ignored.
    }
  }

  Future<void> _ensureSettingsLoaded() async {
    await AppSettingsService.instance.snapshot();
  }
}
