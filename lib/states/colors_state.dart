// Dart imports:
import 'dart:convert';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:visual_subs/extensions.dart';

class ColorsState extends ChangeNotifier {
  static const String colorsSharedKey = "colorsJsonPath";
  static const String defaultColorsAssetPath = "assets/default_colors.json";

  static final Map<String, Color> _defaultColors = {};
  final Map<String, Color> _activeColors = {};
  final Map<String, Color> _fileColors = {};

  final JsonEncoder encoder = const JsonEncoder.withIndent("  ");
  final JsonDecoder decoder = const JsonDecoder();

  ColorsState() {
    Future.wait([loadDefaultColors(), loadPreviousState()])
        .then((_) => _activeColors
          ..clear()
          ..addAll(_defaultColors)
          ..addAll(_fileColors));
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

  Future<void> saveToFile(List<String> characters) async {
    String? path = await FilePicker.platform.saveFile(
      allowedExtensions: ["json"],
      type: FileType.custom,
      fileName: "colors.json",
    );
    if (path == null) return;

    Map<String, String> colorMap = {
      for (String character in characters) character: of(character).hex
    };
    String jsonText = encoder.convert(colorMap);
    File file = File(path);
    await file.writeAsString(jsonText);

    _fileColors
      ..clear()
      ..addAll(_activeColors);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(colorsSharedKey, path);
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
    prefs.setString(colorsSharedKey, file.path);
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
    String? path = prefs.getString(colorsSharedKey);
    if (path != null) {
      File file = File(path);
      if (!await file.exists()) return;
      String jsonText = await file.readAsString();

      _fileColors
        ..clear()
        ..addAll(parseColorJson(jsonText));
    }
  }

  Future<void> loadDefaultColors() async {
    String defaultColorsText =
        await rootBundle.loadString(defaultColorsAssetPath);

    _defaultColors
      ..clear()
      ..addAll(parseColorJson(defaultColorsText));
  }
}
