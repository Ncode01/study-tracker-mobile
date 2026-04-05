import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SensoryService {
  SensoryService._();

  static final SensoryService instance = SensoryService._();

  final AudioPlayer _audioPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  Future<void> tap() async {
    await HapticFeedback.selectionClick();
  }

  Future<void> sessionStarted() async {
    await HapticFeedback.mediumImpact();
    await _tryPlayCue('audio/session_start.mp3');
  }

  Future<void> sessionStopped() async {
    await HapticFeedback.lightImpact();
  }

  Future<void> sessionCompleted() async {
    await HapticFeedback.heavyImpact();
    await _tryPlayCue('audio/session_complete.mp3');
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
}
