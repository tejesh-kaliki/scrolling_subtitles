import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ConsumerState, ConsumerStatefulWidget, ProviderListenableSelect;
import 'package:provider/provider.dart';
import 'package:scrolling_subtitles/data/frame_state.dart';
import 'package:scrolling_subtitles/extensions.dart';
import 'package:scrolling_subtitles/providers/options_provider.dart';
import 'package:scrolling_subtitles/providers/subtitle_provider.dart';
import 'package:scrolling_subtitles/states/audio_state.dart';
import 'package:scrolling_subtitles/states/image_state.dart';
import 'package:subtitle/subtitle.dart';

import 'playback_position.dart';
import 'subtitle_display.dart';
import 'subtitle_highlight.dart';
import 'subtitle_list_view.dart';
import 'subtitle_painter.dart';

class VideoSection extends ConsumerStatefulWidget {
  const VideoSection({super.key});

  @override
  ConsumerState<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends ConsumerState<VideoSection> {
  final double subtitleWidthFactor = 4 / 5;
  final double bgsubScaleFactor = 0.85;

  late ValueNotifier<Subtitle?> subValue = ValueNotifier(null);
  late StreamSubscription<Duration> _streamSubscription;

  int subsPerPage = 7;
  double subPosition = 4;

  /// Denotes the current background sub.
  /// null means that no background sub will be displayed.
  ValueNotifier<Subtitle?> bgSubValue = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _streamSubscription = Provider.of<AudioState>(context, listen: false)
        .positionStream
        .listen(checkForBackgroundSub);
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  FrameState computeState(Duration position) {
    final subtitles =
        ref.read(subtitleProvider.select((state) => state.subtitles));
    final options = ref.read(optionsProvider);
    final effectiveTime = position + options.subDelay;
    final subStartTime =
        subtitles.isNotEmpty ? subtitles.first.start : Duration(days: 999);

    final showSubs = effectiveTime > subStartTime;
    final currentSubIndex =
        subtitles.indexWhere((sub) => sub.start <= position + options.subDelay);

    return FrameState(
      showSubs: showSubs,
      currentSubIndex: currentSubIndex.clamp(0, subtitles.length - 1),
      scrollOffset: 0,
      overlayOpacity: computeOverlayOpacity(effectiveTime, subStartTime),
    );
  }

  double computeOverlayOpacity(Duration effectiveTime, Duration subStartTime) {
    const fadeDuration = Duration(milliseconds: 300);
    final triggerTime = subStartTime - const Duration(milliseconds: 500);
    final t = (effectiveTime - triggerTime).inMilliseconds /
        fadeDuration.inMilliseconds;
    return Curves.easeInOut.transform(t.clamp(0.0, 1.0));
  }

  void checkForBackgroundSub(Duration position) {
    final backgroundSubs =
        ref.read(subtitleProvider.select((state) => state.backgroundSubs));
    Duration subtitleDelay =
        ref.read(optionsProvider.select((state) => state.subDelay));
    // Duration playerPos = state.position ?? Duration.zero;

    Subtitle? cSub = bgSubValue.value;
    if (cSub != null && cSub.start < position && cSub.end > position) return;

    Subtitle? finalSub;
    for (Subtitle s in backgroundSubs) {
      Duration start = s.start - subtitleDelay;
      Duration end = s.end + subtitleDelay;

      if (start < position && position < end) finalSub = s;
    }

    if (cSub != finalSub) bgSubValue.value = finalSub;
  }

  @override
  Widget build(BuildContext context) {
    subsPerPage = 8;
    subPosition = 5.5;

    final subOffset = subPosition.round() - ((subsPerPage + 1) / 2).round() + 1;

    ImageState imState = context.watch<ImageState>();
    AudioState audioState = context.watch<AudioState>();

    Size imageSize = imState.imageSize;
    double subWidth = imageSize.width * subtitleWidthFactor;

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        height: imageSize.height,
        width: imageSize.width,
        child: StreamBuilder(
            stream: audioState.durationStream,
            builder: (context, asyncSnapshot) {
              Duration total = asyncSnapshot.data ?? Duration.zero;
              return StreamBuilder<Duration>(
                stream: audioState.positionStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return displayImage(imState.image);

                  Duration playerPos = snapshot.data!;
                  final frameState = computeState(playerPos);

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      displayImage(imState.image),
                      Opacity(
                        opacity: frameState.overlayOpacity,
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.5),
                          child: showSubtitleHighlight(
                              imageSize.height, subWidth, frameState),
                        ),
                      ),
                      Opacity(
                        opacity: frameState.showSubs ? 1 : 0,
                        child: SizedBox(
                          width: subWidth,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SubtitleListView(
                              onChange: onSubtitleChange,
                              blurPreview: true,
                              totalDivs: subsPerPage,
                              offset: subOffset,
                            ),
                          ),
                        ),
                      ),
                      showBackgroundSub(imageSize.height, subWidth),
                      Positioned(
                        top: 15,
                        right: 15,
                        child:
                            PlaybackPosition(position: playerPos, total: total),
                      ),
                    ],
                  );
                },
              );
            }),
      ),
    );
  }

  Widget displayImage(File? image) {
    if (image == null) {
      return const Center(
        child: Icon(
          Icons.add_photo_alternate_rounded,
          size: 300,
          color: Colors.grey,
        ),
      );
    }
    return Image.file(image, isAntiAlias: true);
  }

  void onSubtitleChange(int index) {
    final currentSub =
        ref.read(subtitleProvider.select((state) => state.subtitles[index]));
    subValue.value = currentSub;
  }

  Widget showSubtitleHighlight(
      double imageHeight, double subWidth, FrameState frameState) {
    final subtitles =
        ref.read(subtitleProvider.select((state) => state.subtitles));

    final subtitle = (frameState.currentSubIndex >= 0 &&
            frameState.currentSubIndex < subtitles.length)
        ? subtitles[frameState.currentSubIndex]
        : null;

    if (subtitle == null) return Container();

    double height = imageHeight / subsPerPage;
    double subHeight = SubtitlePainter.getTextDisplayHeight(
      subtitle.textWithoutSpeaker,
      subWidth - 40,
      ref.read(optionsProvider),
    );

    double highlightHeight = max(height * 0.8, subHeight + 35);

    return setPosAndHeight(
      pos: subPosition,
      subsPerPage: subsPerPage,
      child: SubtitleHighlight(
        subtitle: subtitle,
        height: highlightHeight,
        maxHeight: height,
      ),
    );
  }

  Widget showBackgroundSub(double imageHeight, double subWidth) {
    return ValueListenableBuilder<Subtitle?>(
      valueListenable: bgSubValue,
      builder: (context, subtitle, child) {
        if (subtitle == null) return Container();

        double height = imageHeight / subsPerPage;
        double subHeight = SubtitlePainter.getTextDisplayHeight(
          subtitle.textWithoutSpeaker,
          subWidth - 40,
          ref.read(optionsProvider),
        );

        double highlightHeight = max(height * 0.8, subHeight + 35);

        return setPosAndHeight(
          pos: subPosition + 1,
          subsPerPage: subsPerPage,
          child: Transform.scale(
            scale: bgsubScaleFactor,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SubtitleHighlight(
                  subtitle: subtitle,
                  height: highlightHeight,
                  maxHeight: height,
                ),
                FractionallySizedBox(
                  widthFactor: subtitleWidthFactor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SubtitleDisplay(subtitle, current: true),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Sets the position and height of the subtitle highlight.
  ///
  /// subsPerPage: the number of divisions in the entire page vertically.
  /// pos: position of the highlight or subtitle, based on number of divisions.
  Widget setPosAndHeight(
      {required Widget child, required double pos, required int subsPerPage}) {
    FractionalOffset offset = FractionalOffset(0, pos / (subsPerPage - 1));
    return Align(
      alignment: offset,
      child: FractionallySizedBox(heightFactor: 1 / subsPerPage, child: child),
    );
  }
}
