// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';

class AudioState extends ChangeNotifier {
  static const String audioSharedKey = "audioPath";

  final AudioPlayer _player = AudioPlayer();
  // Duration _duration = Duration.zero;
  File? _audioFile;
  bool _audioLoaded = false;

  Stream<Duration> get positionStream => _player.positionStream;
  Duration get duration => _player.duration ?? Duration.zero;
  String? get filePath => _audioFile?.path;
  bool get isLoaded => _audioLoaded;
  Stream<bool> get playingStream => _player.playingStream;

  AudioState() {
    loadPreviousState();
  }

  Future<void> loadAudio(String audioPath) async {
    File file = File(audioPath);
    if (!file.existsSync()) return;

    AudioSource source = AudioSource.file(file.path);
    await _player.setAudioSource(source);
    _audioFile = file;
    _audioLoaded = true;
    notifyListeners();
  }

  void rewind10s() {
    Duration fpos = (_player.position) - const Duration(seconds: 10);
    seekToPos(fpos);
  }

  void forward10s() {
    Duration fpos = (_player.position) + const Duration(seconds: 10);
    seekToPos(fpos);
  }

  void seekToPos(Duration pos) {
    Duration totalDuration = _player.duration ?? Duration.zero;
    if (pos < Duration.zero) pos = Duration.zero;
    if (pos > totalDuration) pos = totalDuration;
    _player.seek(pos);
  }

  void togglePlayPause() {
    _player.playing ? pause() : play();
  }

  void pause() {
    _player.pause();
    notifyListeners();
  }

  void play() {
    _player.play();
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
