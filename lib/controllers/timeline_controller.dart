import 'package:flutter/scheduler.dart';

class TimelineController {
  Duration currentTime = Duration.zero;

  Duration _lastAudioTime = Duration.zero;
  DateTime _lastWallTime = DateTime.now();

  final void Function() onTick;

  late final Ticker _ticker;

  TimelineController({required this.onTick}) {
    _ticker = Ticker(_onTick);
  }

  bool suspended = false;

  void _onTick(Duration _) {
    if (suspended) return;
    final now = DateTime.now();
    final delta = now.difference(_lastWallTime);

    currentTime = _lastAudioTime + delta;

    onTick();
  }

  /// Called when audio stream updates
  void updateAudioTime(Duration pos) {
    _lastAudioTime = pos;
    _lastWallTime = DateTime.now();
  }

  /// Play
  void play() {
    _lastWallTime = DateTime.now();
    _ticker.start();
  }

  /// Pause
  void pause() {
    _lastAudioTime = currentTime;
    _ticker.stop();
  }

  void dispose() {
    _ticker.dispose();
  }
}
