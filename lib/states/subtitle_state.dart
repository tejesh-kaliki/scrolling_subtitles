// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subtitle/subtitle.dart';

// Project imports:
import 'package:visual_subs/extensions.dart';

class SubtitleState extends ChangeNotifier {
  static const String subtitleSharedKey = "subsPath";

  List<Subtitle>? _subtitles;
  List<Subtitle>? _backgroundSubs;
  final Set<String> _characterSet = {};
  File? subtitleFile;

  List<Subtitle>? get subtitles => _subtitles;
  List<Subtitle>? get backgroundSubs => _backgroundSubs;
  String? get filePath => subtitleFile?.path;
  Set<String> get characters => _characterSet;

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
    prefs.setString(subtitleSharedKey, path);
  }

  Future<void> loadPreviousState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? path = prefs.getString(subtitleSharedKey);
    if (path != null) await parseSubs(path);
  }
}
