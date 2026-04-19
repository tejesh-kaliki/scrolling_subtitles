import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scrolling_subtitles/data/subtitle_state.dart';
import 'package:scrolling_subtitles/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subtitle/subtitle.dart';

part 'subtitle_provider.g.dart';

const String subtitleSharedKey = "subsPath";

Future<SubtitleState> parseSubs(String subPath) async {
  File file = File(subPath);
  if (!await file.exists()) return SubtitleState();

  SubtitleProvider subtitleProvider = SubtitleProvider.fromFile(
    file,
    type: SubtitleType.vtt,
  );
  SubtitleObject subtitleObject = await subtitleProvider.getSubtitle();
  SubtitleParser parser = SubtitleParser(subtitleObject);

  final subtitles = List<Subtitle>.empty(growable: true);
  final backgroundSubs = List<Subtitle>.empty(growable: true);
  final characterSet = <String>{};
  parser.parsing().forEach((subtitle) {
    characterSet.addAll(subtitle.characters);
    if (subtitle.isBackgroundSub) {
      backgroundSubs.add(subtitle);
    } else {
      subtitles.add(subtitle);
    }
  });
  return SubtitleState(
    subtitles: subtitles,
    backgroundSubs: backgroundSubs,
    characterSet: characterSet,
    subtitleFile: file,
  );
}

@riverpod
class SubtitleNotifier extends _$SubtitleNotifier {
  @override
  SubtitleState build() {
    unawaited(loadPreviousState());
    return SubtitleState();
  }

  Future<void> loadPreviousState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? path = prefs.getString(subtitleSharedKey);
    if (path != null) state = await parseSubs(path);
  }

  Future<void> pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["vtt"],
    );
    if (result == null) return;

    String? path = result.files.single.path;
    if (path == null) return;
    state = await parseSubs(path);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(subtitleSharedKey, path);
  }
}
