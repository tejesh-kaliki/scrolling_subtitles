import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:subtitle/subtitle.dart';

part 'frame_state.freezed.dart';

@freezed
abstract class FrameState with _$FrameState {
  const factory FrameState({
    required bool showSubs,
    required int currentSubIndex,
    required double scrollOffset,
    final Subtitle? backgroundSub,
    required double overlayOpacity,
  }) = _FrameState;
}
