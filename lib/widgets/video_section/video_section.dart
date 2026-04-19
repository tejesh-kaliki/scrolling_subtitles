import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ConsumerState, ConsumerStatefulWidget, ProviderListenableSelect;
import 'package:provider/provider.dart';
import 'package:scrolling_subtitles/controllers/timeline_controller.dart';
import 'package:scrolling_subtitles/data/frame_state.dart';
import 'package:scrolling_subtitles/extensions.dart';
import 'package:scrolling_subtitles/providers/frame_state_provider.dart';
import 'package:scrolling_subtitles/providers/options_provider.dart';
import 'package:scrolling_subtitles/providers/subtitle_provider.dart';
import 'package:scrolling_subtitles/providers/timeline_provider.dart';
import 'package:scrolling_subtitles/states/audio_state.dart';
import 'package:scrolling_subtitles/states/image_state.dart';

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

  int subsPerPage = 8;
  double subPosition = 5.5;

  Duration correction = Duration.zero;

  late TimelineController _timeline;
  late AudioState _audio;

  Duration scale(Duration d, double factor) {
    return Duration(
      microseconds: (d.inMicroseconds * factor).round(),
    );
  }

  @override
  void initState() {
    super.initState();

    _audio = Provider.of<AudioState>(context, listen: false);

    _timeline = TimelineController(
      onTick: () {
        ref.read(timelineProvider.notifier).setTime(_timeline.currentTime);
      },
    );

    _audio.positionStream.listen((pos) {
      _timeline.updateAudioTime(pos);
    });

    _audio.addListener(() {
      _audio.isPlaying ? _timeline.play() : _timeline.pause();
    });

    if (_audio.isPlaying) {
      _timeline.play();
    }
  }

  @override
  void dispose() {
    _timeline.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ImageState imState = context.watch<ImageState>();
    AudioState audioState = context.watch<AudioState>();
    final frameState = ref.watch(frameStateProvider);

    final imageSize = imState.imageSize;

    const videoHeight = 1024.0;
    final videoWidth = imageSize.width * (videoHeight / imageSize.height);
    final subWidth = videoWidth * subtitleWidthFactor;

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        height: videoHeight,
        width: videoWidth,
        child: StreamBuilder(
            stream: audioState.durationStream,
            builder: (context, asyncSnapshot) {
              Duration total = asyncSnapshot.data ?? Duration.zero;
              return Stack(
                alignment: Alignment.center,
                children: [
                  displayImage(imState.image),
                  Opacity(
                    opacity: frameState.overlayOpacity,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: showSubtitleHighlight(1024, subWidth, frameState),
                    ),
                  ),
                  Opacity(
                    opacity: frameState.showSubs ? 1 : 0,
                    child: SizedBox(
                      width: subWidth,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SubtitleListView(
                          onChange: (index) {},
                          blurPreview: true,
                          totalDivs: subsPerPage,
                          subPosition: subPosition,
                          currentIndex: frameState.currentSubIndex,
                          scrollOffset: frameState.scrollOffset,
                        ),
                      ),
                    ),
                  ),
                  showBackgroundSub(1024, subWidth, frameState),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: PlaybackPosition(
                        position: _timeline.currentTime, total: total),
                  ),
                ],
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

  Widget showSubtitleHighlight(
    double imageHeight,
    double subWidth,
    FrameState frameState,
  ) {
    final subtitles =
        ref.read(subtitleProvider.select((state) => state.subtitles));

    final subtitle = (frameState.currentSubIndex >= 0 &&
            frameState.currentSubIndex < subtitles.length)
        ? subtitles[frameState.currentSubIndex]
        : null;
    final previousSubtitle = (frameState.currentSubIndex - 1 >= 0 &&
            frameState.currentSubIndex - 1 < subtitles.length)
        ? subtitles[frameState.currentSubIndex - 1]
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
        timestamp: frameState.effectiveTime,
        progress: frameState.transitionProgress,
        previousSubtitle: previousSubtitle,
      ),
    );
  }

  Widget showBackgroundSub(
    double imageHeight,
    double subWidth,
    FrameState frameState,
  ) {
    final bg = frameState.backgroundSub;
    if (bg == null) return const SizedBox();

    final subtitle = bg.subtitle;
    final opacity = bg.opacity;

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
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: bgsubScaleFactor,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SubtitleHighlight(
                subtitle: subtitle,
                height: highlightHeight,
                maxHeight: height,
                progress: 1.0,
                timestamp: frameState.effectiveTime,
              ),
              FractionallySizedBox(
                widthFactor: subtitleWidthFactor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SubtitleDisplay(
                    subtitle,
                    current: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
