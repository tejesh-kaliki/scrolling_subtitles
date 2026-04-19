import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scrolling_subtitles/data/frame_state.dart';
import 'package:scrolling_subtitles/providers/options_provider.dart';
import 'package:scrolling_subtitles/providers/subtitle_provider.dart';
import 'package:scrolling_subtitles/providers/timeline_provider.dart';
import 'package:subtitle/subtitle.dart';

part 'frame_state_provider.g.dart';

@riverpod
FrameState frameState(Ref ref) {
  final time = ref.watch(timelineProvider);

  final subtitles = ref.watch(subtitleProvider.select((s) => s.subtitles));
  final backgroundSubs =
      ref.watch(subtitleProvider.select((s) => s.backgroundSubs));
  final options = ref.watch(optionsProvider);

  final effectiveTime = time + options.subDelay;

  final subStartTime =
      subtitles.isNotEmpty ? subtitles.first.start : Duration(days: 999);

  final showSubs = effectiveTime > subStartTime;

  const transitionDuration = Duration(milliseconds: 500);

  final currentIndex =
      subtitles.lastIndexWhere((sub) => sub.start <= effectiveTime);

  final safeIndex =
      subtitles.isEmpty ? 0 : currentIndex.clamp(0, subtitles.length - 1);

  final transitionStart = subtitles.isEmpty
      ? Duration.zero
      : subtitles[safeIndex].end - transitionDuration;

  final t = (effectiveTime - transitionStart).inMilliseconds /
      transitionDuration.inMilliseconds;

  final progress = Curves.easeInOut.transform(t.clamp(0.0, 1.0));

  // Color starts changing when scroll is 20% through.
  // Rescale 0.2–1.0 → 0.0–1.0 so the transition finishes exactly as scroll does.
  const colorOffset = 0.2;
  final colorProgress =
      Curves.easeOut.transform(((progress - colorOffset) / (1 - colorOffset)).clamp(0.0, 1.0));

  final lineHeight = 1024 / 8;

  return FrameState(
    effectiveTime: effectiveTime,
    showSubs: showSubs,
    currentSubIndex: safeIndex,
    scrollOffset: progress * lineHeight,
    overlayOpacity: computeOverlayOpacity(effectiveTime, subStartTime),
    backgroundSub: computeBackgroundSub(backgroundSubs, effectiveTime),
    transitionStart: transitionStart,
    transitionProgress: progress,
    colorTransitionProgress: colorProgress,
  );
}

double computeOverlayOpacity(Duration effectiveTime, Duration subStartTime) {
  const fadeDuration = Duration(milliseconds: 300);
  final triggerTime = subStartTime - const Duration(milliseconds: 500);
  final t = (effectiveTime - triggerTime).inMilliseconds /
      fadeDuration.inMilliseconds;
  return Curves.easeOut.transform(t.clamp(0.0, 1.0));
}

ActiveBackgroundSub? computeBackgroundSub(
  List<Subtitle> subs,
  Duration time,
) {
  const fade = Duration(milliseconds: 300);

  for (final s in subs) {
    final start = s.start;
    final end = s.end;

    if (time < start - fade || time > end + fade) continue;

    double opacity;

    if (time < start) {
      final t = (time - (start - fade)).inMilliseconds / fade.inMilliseconds;
      opacity = Curves.easeOut.transform(t.clamp(0, 1));
    } else if (time > end) {
      final t = (end + fade - time).inMilliseconds / fade.inMilliseconds;
      opacity = Curves.easeIn.transform(t.clamp(0, 1));
    } else {
      // fully visible
      opacity = 1.0;
    }

    return ActiveBackgroundSub(subtitle: s, opacity: opacity);
  }

  return null;
}
