import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:subtitle/subtitle.dart';

part 'subtitle_state.freezed.dart';

@freezed
abstract class SubtitleState with _$SubtitleState {
  const factory SubtitleState({
    @Default([]) List<Subtitle> subtitles,
    @Default([]) List<Subtitle> backgroundSubs,
    @Default(<String>{}) Set<String> characterSet,
    File? subtitleFile,
  }) = _SubtitleState;
}
