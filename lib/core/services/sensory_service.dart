import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'app_settings_service.dart';

class SensoryService {
  SensoryService({required AppSettingsService appSettingsService})
    : _appSettingsService = appSettingsService;

  final AppSettingsService _appSettingsService;

  final AudioPlayer _audioPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  Future<void> playSessionStart() async {
    await _ensureSettingsLoaded();
    if (_appSettingsService.enableSound) {
      await _tryPlayCue('audio/session_start.mp3');
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
    await _appSettingsService.snapshot();
  }
}
