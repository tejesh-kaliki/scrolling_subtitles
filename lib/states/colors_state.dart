import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:scrolling_subtitles/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void clearColors() async {
    _activeColors.clear();
    _fileColors.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("colorsJsonPath");
    notifyListeners();
  }

  void loadColors(Set<String> characters) {
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

  Future<void> pickFile(Set<String> characters) async {
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
