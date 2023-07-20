import 'dart:io';
import 'dart:ui' as ui;

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:subtitle/subtitle.dart';

import 'extensions.dart';

class OptionsState extends ChangeNotifier {
  Duration _subDelay = const Duration(milliseconds: 500);

  Duration get subtitleDelay => _subDelay;
  set subtitleDelay(Duration delay) {
    _subDelay = delay;
    notifyListeners();
  }
}

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
      _characterSet.addAll(subtitle.characters);
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

  void pause() {
    if (!_paused) togglePlayPause();
  }

  void play() {
    if (_paused) togglePlayPause();
  }
}

class ColorsState extends ChangeNotifier {
  static final Map<String, Color> _defaultColors = {
    "rozemyne": Colors.blue.shade800,
    "myne": Colors.blue.shade800,
    "ferdinand": Colors.cyanAccent,
    "sylvester": Colors.deepPurple,
    "hartmut": Colors.deepOrange,
    "brunhilde": Colors.redAccent.shade700,
    "judithe": const Color.fromARGB(255, 255, 119, 0),
    "hildebrand": Colors.lightBlue.shade300,
    "eckhart": Colors.green,
    "justus": Colors.brown,
    "philine": const Color.fromARGB(255, 255, 210, 133),
    "solange": Colors.purple.shade100,
    "rauffen": Colors.orange,
    "wilfried": Colors.amber.shade300,
    "cornelius": Colors.lime,
    "charlotte": Colors.indigo.shade300,
    "karstedt": Colors.orange.shade800,
    "georgine": Colors.purple,
    "relichion": const Color.fromARGB(255, 255, 201, 176),
    "immanuel": const Color(0xff059D84),
    "raublut": const Color(0xff889654),
    "zent": const Color(0xffCCECFF),
    "rihyarda": Colors.grey.shade300,
    "fran": Colors.grey,
    "gil": Colors.grey,
    "zahm": Colors.grey,
    "schwartz": Colors.grey.shade800,
    "weiss": Colors.grey.shade100,
    "temple attendant": Colors.grey,
    "ferdinand's temple attendants": Colors.grey,
    "dunkelfelger knights": Colors.blue,
    "ehrenfest noble": Colors.yellow,
    "ehrenfest students": Colors.yellow,
    "terrorist": Colors.grey.shade800,
    "urano": Colors.blue.shade800,
    "benno": Colors.yellow,
    "lutz": Colors.orange,
    "gutenbergs": const Color(0xff6BAED6),
    "stenluke": Colors.teal,
    "bonifatius": const Color(0xff996515),
    "florencia": Colors.limeAccent.shade400,
    "elvira": Colors.greenAccent.shade400,
    "damuel": Colors.yellow.shade200,
    "tuuli": Colors.lightGreenAccent,
    "angelica": const Color(0xff6BAED6),
    "lamprecht": const Color(0xffFCAE91),
    "bezewanst": const Color(0xffFB6A4A),
    "bindewald": const Color.fromARGB(255, 255, 201, 176),
    "gunther": Colors.green.shade600,
    "effa": Colors.green.shade200,
    "veronica": const Color(0xffFCAE91),
    "black-clad man": Colors.grey.shade800,
    "hirschur": const Color(0xff6600ff),
    "fraulram": const Color(0xffcc99ff),
    "otto": const Color(0xffcc6600),
    "corinna": const Color(0xff66ff66),
    "mark": const Color(0xff996633),
    "gustav": const Color(0xfffff4c0),
  };
  final Map<String, Color> _activeColors = {};

  Map<String, Color> get charColors => _activeColors;

  Color of(String character) {
    return _activeColors[character] ?? Colors.white;
  }

  void loadColors(List<String> characters) {
    _activeColors.clear();
    for (String character in characters) {
      _activeColors[character] = _defaultColors[character] ?? Colors.white;
    }
    notifyListeners();
  }

  void setCharacterColor(String character, Color color) {
    _activeColors[character] = color;
    notifyListeners();
  }
}
