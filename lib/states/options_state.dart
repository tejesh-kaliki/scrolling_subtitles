import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SubtitleFontFamily {
  poppins,
  verdana,
  arial,
}

class OptionsState extends ChangeNotifier {
  static const String fontSizeKey = "fontSize";
  static const String lineHeightKey = "lineHeight";
  static const String fontFamilyKey = "fontFamily";
  static const String borderWidthKey = "borderWidth";

  Duration _subDelay = const Duration(milliseconds: 500);
  double _fontSize = 24.0;
  double _lineHeight = 1.2;
  double _textBorder = 5;
  SubtitleFontFamily _fontFamily = SubtitleFontFamily.poppins;

  Duration get subtitleDelay => _subDelay;
  set subtitleDelay(Duration delay) {
    _subDelay = delay;
    notifyListeners();
  }

  double get fontSize => _fontSize;
  set fontSize(double size) {
    _fontSize = size;
    notifyListeners();

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setDouble(fontSizeKey, size));
  }

  double get lineHeight => _lineHeight;
  set lineHeight(double height) {
    _lineHeight = height;
    notifyListeners();

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setDouble(lineHeightKey, height));
  }

  double get borderWidth => _textBorder;
  set borderWidth(double width) {
    _textBorder = width;
    notifyListeners();

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setDouble(borderWidthKey, width));
  }

  SubtitleFontFamily get fontFamily => _fontFamily;
  set fontFamily(SubtitleFontFamily font) {
    _fontFamily = font;
    notifyListeners();

    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(fontFamilyKey, font.index));
  }

  Future<void> loadPreviousState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _fontSize = prefs.getDouble(fontSizeKey) ?? 24.0;
    _lineHeight = prefs.getDouble(lineHeightKey) ?? 1.2;
    _textBorder = prefs.getDouble(borderWidthKey) ?? 5.0;

    int fontFamilyIndex =
        prefs.getInt(fontFamilyKey) ?? SubtitleFontFamily.poppins.index;
    _fontFamily = SubtitleFontFamily.values[fontFamilyIndex];

    notifyListeners();
  }
}
