// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioState extends ChangeNotifier {
  static const String audioSharedKey = "audioPath";

  final Player _player = Player();
  File? _audioFile;
  bool _audioLoaded = false;
  bool _paused = true;

  Player get player => _player;
  Stream<Duration> get positionStream => _player.stream.position;
  Stream<Duration> get durationStream => _player.stream.duration;
  String? get filePath => _audioFile?.path;
  bool get isLoaded => _audioLoaded;
  bool get isPlaying => !_paused;

  AudioState() {
    loadPreviousState();
  }

  void loadAudio(String audioPath) {
    File file = File(audioPath);
    if (!file.existsSync()) return;

    // _player.open(Media.file(file), autoStart: false);
    _player.open(Media(file.uri.toString()), play: false);
    _audioFile = file;
    _audioLoaded = true;
    notifyListeners();
  }

  void rewind10s() {
    Duration fpos = (_player.state.position) - const Duration(seconds: 10);
    seekToPos(fpos);
  }

  void forward10s() {
    Duration fpos = (_player.state.position) + const Duration(seconds: 10);
    seekToPos(fpos);
  }

  void seekToPos(Duration pos) {
    Duration total = _player.state.duration;
    if (pos < Duration.zero) pos = Duration.zero;
    if (pos > total) pos = total;
    _player.seek(pos);
    // _player.positionController.add(_player.position..position = pos);
  }

  void togglePlayPause() {
    _paused ? play() : pause();
  }

  void pause() {
    _player.pause();
    _paused = true;
    notifyListeners();
  }

  void play() {
    _player.play();
    _paused = false;
    notifyListeners();
  }

  Future<void> pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null) return;

    String? path = result.files.single.path;
    if (path == null) return;

    loadAudio(path);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(audioSharedKey, path);
  }

  Future<void> loadPreviousState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? path = prefs.getString(audioSharedKey);
    if (path != null) loadAudio(path);
  }
}
