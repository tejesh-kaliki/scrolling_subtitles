import 'dart:io';
import 'dart:ui' as ui;

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:subtitle/subtitle.dart';

import 'extensions.dart';

class ImageState extends ChangeNotifier {
  File? _imageFile;
  Size _imageSize = const Size.square(1080);

  String? get filePath => _imageFile?.path;
  File? get image => _imageFile;
  Size get imageSize => _imageSize;

  Future<void> setImageFile(String imagePath) async {
    _imageFile = File(imagePath);
    ui.Image image = await decodeImageFromList(await _imageFile!.readAsBytes());
    _imageSize = Size(image.width / 1.0, image.height / 1.0);
    notifyListeners();
  }
}

class SubtitleState extends ChangeNotifier {
  List<Subtitle>? _subtitles;
  List<Subtitle>? _backgroundSubs;
  final Set<String> _characterSet = {};
  File? subtitleFile;

  List<Subtitle>? get subtitles => _subtitles;
  List<Subtitle>? get backgroundSubs => _backgroundSubs;
  String? get filePath => subtitleFile?.path;
  List<String> get characters => _characterSet.toList();

  Future<void> parseSubs(String subPath) async {
    subtitleFile = File(subPath);
    SubtitleProvider subtitleProvider = SubtitleProvider.fromFile(
      subtitleFile!,
      type: SubtitleType.vtt,
    );
    SubtitleObject subtitleObject = await subtitleProvider.getSubtitle();
    SubtitleParser parser = SubtitleParser(subtitleObject);

    _subtitles = List<Subtitle>.empty(growable: true);
    _backgroundSubs = List<Subtitle>.empty(growable: true);
    _characterSet.clear();
    parser.parsing().forEach((subtitle) {
      _characterSet.add(subtitle.character);
      if (subtitle.isBackgroundSub) {
        backgroundSubs!.add(subtitle);
      } else {
        subtitles!.add(subtitle);
      }
    });
    notifyListeners();
  }
}

class AudioState extends ChangeNotifier {
  // Can use any id, but just used this random number.
  final Player _player =
      Player(id: 69420, commandlineArguments: ["--no-video"]);
  File? _audioFile;
  bool _audioLoaded = false;
  bool _paused = true;

  Player get player => _player;
  Stream<PositionState> get positionStream => _player.positionStream;
  String? get filePath => _audioFile?.path;
  bool get isLoaded => _audioLoaded;
  bool get isPlaying => !_paused;

  void loadAudio(String audioPath) {
    _audioFile = File(audioPath);
    _player.open(Media.file(_audioFile!), autoStart: false);
    _audioLoaded = true;
    notifyListeners();
  }

  void rewind10s() {
    Duration fpos = (_player.position.position ?? Duration.zero) -
        const Duration(seconds: 10);
    seekToPos(fpos);
  }

  void forward10s() {
    Duration fpos = (_player.position.position ?? Duration.zero) +
        const Duration(seconds: 10);
    seekToPos(fpos);
  }

  void seekToPos(Duration pos) {
    Duration total = _player.position.duration ?? Duration.zero;
    if (pos < Duration.zero) pos = Duration.zero;
    if (pos > total) pos = total;
    _player.seek(pos);
    _player.positionController.add(_player.position..position = pos);
  }

  void togglePlayPause() {
    _player.playOrPause();
    _paused = !_paused;
    notifyListeners();
  }
}
