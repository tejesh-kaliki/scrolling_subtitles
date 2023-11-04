import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dart_vlc/dart_vlc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  ImageState() {
    loadPreviousState();
  }

  Future<void> setImageFile(String imagePath) async {
    File file = File(imagePath);
    if (!await file.exists()) return;

    ui.Image image = await decodeImageFromList(await file.readAsBytes());
    _imageFile = file;
    _imageSize = Size(image.width / 1.0, image.height / 1.0);
    notifyListeners();
  }

  Future<void> pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;

    String? path = result.files.single.path;
    if (path == null) return;

    setImageFile(path);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("imagePath", path);
  }

  Future<void> loadPreviousState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? path = prefs.getString("imagePath");
    if (path != null) setImageFile(path);
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

  SubtitleState() {
    loadPreviousState();
  }

  Future<void> parseSubs(String subPath) async {
    File file = File(subPath);
    if (!await file.exists()) return;

    SubtitleProvider subtitleProvider = SubtitleProvider.fromFile(
      file,
      type: SubtitleType.vtt,
    );
    SubtitleObject subtitleObject = await subtitleProvider.getSubtitle();
    SubtitleParser parser = SubtitleParser(subtitleObject);
    subtitleFile = file;

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

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ["vtt"]);
    if (result == null) return;

    String? path = result.files.single.path;
    if (path == null) return;
    await parseSubs(path);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("subsPath", path);
  }

  Future<void> loadPreviousState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? path = prefs.getString("subsPath");
    if (path != null) await parseSubs(path);
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

  AudioState() {
    loadPreviousState();
  }

  void loadAudio(String audioPath) {
    File file = File(audioPath);
    if (!file.existsSync()) return;

    _player.open(Media.file(file), autoStart: false);
    _audioFile = file;
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

  Future<void> pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null) return;

    String? path = result.files.single.path;
    if (path == null) return;

    loadAudio(path);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("audioPath", path);
  }

  Future<void> loadPreviousState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? path = prefs.getString("audioPath");
    if (path != null) loadAudio(path);
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
    "gunther": Colors.blue.shade300,
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
  final Map<String, Color> _fileColors = {};

  final JsonEncoder encoder = const JsonEncoder.withIndent("  ");
  final JsonDecoder decoder = const JsonDecoder();

  ColorsState() {
    loadPreviousState();
  }

  Map<String, Color> get charColors => _activeColors;

  Color of(String character) {
    return _activeColors[character] ?? Colors.white;
  }

  void loadColors(List<String> characters) {
    Map<String, Color> colorMap = {}
      ..addAll(_defaultColors)
      ..addAll(_fileColors);

    Map<String, Color> newActiveMap = {};
    for (String character in characters) {
      newActiveMap[character] =
          colorMap[character] ?? _activeColors[character] ?? Colors.white;
    }
    _activeColors.clear();
    _activeColors.addAll(newActiveMap);
    notifyListeners();
  }

  void setCharacterColor(String character, Color color) {
    _activeColors[character] = color;
    notifyListeners();
  }

  Future<void> saveToFile() async {
    String? path = await FilePicker.platform.saveFile(
      allowedExtensions: ["json"],
      type: FileType.custom,
      fileName: "colors.json",
    );
    if (path == null) return;

    Map<String, String> colorMap =
        _activeColors.map((key, value) => MapEntry(key, value.hex));
    String jsonText = encoder.convert(colorMap);
    File file = File(path);
    await file.writeAsString(jsonText);

    _fileColors
      ..clear()
      ..addAll(_activeColors);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("colorsJsonPath", path);
  }

  Future<void> pickFile(List<String> characters) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ["json"],
      type: FileType.custom,
    );
    if (result == null ||
        result.count == 0 ||
        result.files.first.path == null) {
      return;
    }

    File file = File(result.files.first.path!);
    String jsonText = await file.readAsString();
    _fileColors
      ..clear()
      ..addAll(parseColorJson(jsonText));

    loadColors(characters);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("colorsJsonPath", file.path);
  }

  Map<String, Color> parseColorJson(String jsonText) {
    Map<String, dynamic> jsonData = decoder.convert(jsonText);
    return jsonData.map<String, Color>((key, value) {
      Color color = HexColor.fromHex(value);
      return MapEntry<String, Color>(key, color);
    });
  }

  Future<void> loadPreviousState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? path = prefs.getString("colorsJsonPath");
    if (path != null) {
      File file = File(path);
      if (!await file.exists()) return;
      String jsonText = await file.readAsString();

      _fileColors
        ..clear()
        ..addAll(parseColorJson(jsonText));
    }
  }
}
