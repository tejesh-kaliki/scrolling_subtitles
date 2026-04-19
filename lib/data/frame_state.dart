import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:subtitle/subtitle.dart';

part 'frame_state.freezed.dart';

class ActiveBackgroundSub {
  const ActiveBackgroundSub({
    required this.subtitle,
    required this.opacity,
  });

  final Subtitle subtitle;
  final double opacity; // 0 → 1
}

@freezed
abstract class FrameState with _$FrameState {
  const factory FrameState({
    required bool showSubs,
    required int currentSubIndex,
    required double scrollOffset,
    final ActiveBackgroundSub? backgroundSub,
    required double overlayOpacity,
    required Duration effectiveTime,
    required Duration transitionStart,
    required double transitionProgress,
    required double colorTransitionProgress,
  }) = _FrameState;
}
