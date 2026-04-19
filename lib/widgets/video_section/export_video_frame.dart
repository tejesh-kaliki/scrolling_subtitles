import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrolling_subtitles/data/frame_state.dart';
import 'package:scrolling_subtitles/extensions.dart';
import 'package:scrolling_subtitles/providers/frame_state_provider.dart';
import 'package:scrolling_subtitles/providers/options_provider.dart';
import 'package:scrolling_subtitles/providers/subtitle_provider.dart';
import 'package:scrolling_subtitles/states/image_state.dart';
import 'package:provider/provider.dart';

import 'playback_position.dart';
import 'subtitle_display.dart';
import 'subtitle_highlight.dart';
import 'subtitle_list_view.dart';
import 'subtitle_painter.dart';

/// Renders a single video frame driven purely by [frameStateProvider].
/// No audio dependency — meant to be scoped to an export ProviderContainer.
class ExportVideoFrame extends ConsumerWidget {
  static final repaintKey = GlobalKey();

  static const int subsPerPage = 8;
  static const double subPosition = 5.5;
  static const double subtitleWidthFactor = 4 / 5;
  static const double bgsubScaleFactor = 0.85;
  static const double videoHeight = 1024.0;

  final Duration totalDuration;

  const ExportVideoFrame({super.key, this.totalDuration = Duration.zero});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageState = context.watch<ImageState>();
    final frameState = ref.watch(frameStateProvider);
    final imageSize = imageState.imageSize;
    final videoWidth = imageSize.width * (videoHeight / imageSize.height);
    final subWidth = videoWidth * subtitleWidthFactor;

    // Material provides DefaultTextStyle; UnconstrainedBox breaks the
    // overlay's tight screen-size constraints so SizedBox can set its own size.
    return Material(
      color: Colors.transparent,
      child: UnconstrainedBox(
        child: RepaintBoundary(
          key: ExportVideoFrame.repaintKey,
          child: SizedBox(
            width: videoWidth,
            height: videoHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _displayImage(imageState.image),
                Opacity(
                  opacity: frameState.overlayOpacity,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: _showSubtitleHighlight(
                        ref, videoHeight, subWidth, frameState),
                  ),
                ),
                Opacity(
                  opacity: frameState.showSubs ? 1 : 0,
                  child: SizedBox(
                    width: subWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SubtitleListView(
                        onChange: (_) {},
                        blurPreview: true,
                        totalDivs: subsPerPage,
                        subPosition: subPosition,
                        currentIndex: frameState.currentSubIndex,
                        scrollOffset: frameState.scrollOffset,
                      ),
                    ),
                  ),
                ),
                _showBackgroundSub(ref, videoHeight, subWidth, frameState),
                Positioned(
                  top: 15,
                  right: 15,
                  child: PlaybackPosition(
                    position: frameState.effectiveTime,
                    total: totalDuration,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _displayImage(File? image) {
    if (image == null) {
      return const Center(
        child: Icon(Icons.add_photo_alternate_rounded,
            size: 300, color: Colors.grey),
      );
    }
    return Image.file(image, isAntiAlias: true);
  }

  Widget _showSubtitleHighlight(
    WidgetRef ref,
    double imageHeight,
    double subWidth,
    FrameState frameState,
  ) {
    final subtitles =
        ref.read(subtitleProvider.select((s) => s.subtitles));
    final subtitle = (frameState.currentSubIndex >= 0 &&
            frameState.currentSubIndex < subtitles.length)
        ? subtitles[frameState.currentSubIndex]
        : null;
    final nextSubtitle = (frameState.currentSubIndex + 1 < subtitles.length)
        ? subtitles[frameState.currentSubIndex + 1]
        : null;
    if (subtitle == null) return Container();

    final height = imageHeight / subsPerPage;
    final subHeight = SubtitlePainter.getTextDisplayHeight(
      subtitle.textWithoutSpeaker,
      subWidth - 40,
      ref.read(optionsProvider),
    );
    final highlightHeight = max(height * 0.8, subHeight + 35);

    return _setPosAndHeight(
      pos: subPosition,
      child: SubtitleHighlight(
        subtitle: subtitle,
        height: highlightHeight,
        maxHeight: height,
        timestamp: frameState.effectiveTime,
        progress: frameState.transitionProgress,
        colorProgress: frameState.colorTransitionProgress,
        nextSubtitle: nextSubtitle,
      ),
    );
  }

  Widget _showBackgroundSub(
    WidgetRef ref,
    double imageHeight,
    double subWidth,
    FrameState frameState,
  ) {
    final bg = frameState.backgroundSub;
    if (bg == null) return const SizedBox();

    final height = imageHeight / subsPerPage;
    final subHeight = SubtitlePainter.getTextDisplayHeight(
      bg.subtitle.textWithoutSpeaker,
      subWidth - 40,
      ref.read(optionsProvider),
    );
    final highlightHeight = max(height * 0.8, subHeight + 35);

    return _setPosAndHeight(
      pos: subPosition + 1,
      child: Opacity(
        opacity: bg.opacity,
        child: Transform.scale(
          scale: bgsubScaleFactor,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SubtitleHighlight(
                subtitle: bg.subtitle,
                height: highlightHeight,
                maxHeight: height,
                progress: 1.0,
                colorProgress: 1.0,
                timestamp: frameState.effectiveTime,
              ),
              FractionallySizedBox(
                widthFactor: subtitleWidthFactor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SubtitleDisplay(bg.subtitle, current: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _setPosAndHeight({required Widget child, required double pos}) {
    return Align(
      alignment: FractionalOffset(0, pos / (subsPerPage - 1)),
      child:
          FractionallySizedBox(heightFactor: 1 / subsPerPage, child: child),
    );
  }
}
