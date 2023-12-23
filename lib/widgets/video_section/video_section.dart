// Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:subtitle/subtitle.dart';

// Project imports:
import 'package:visual_subs/extensions.dart';
import 'package:visual_subs/states/audio_state.dart';
import 'package:visual_subs/states/image_state.dart';
import 'package:visual_subs/states/options_state.dart';
import 'package:visual_subs/states/subtitle_state.dart';
import 'playback_position.dart';
import 'subtitle_display.dart';
import 'subtitle_highlight.dart';
import 'subtitle_list_view.dart';
import 'subtitle_painter.dart';

class VideoSection extends StatefulWidget {
  const VideoSection({super.key});

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
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

  void checkForBackgroundSub(Duration position) {
    List<Subtitle> backgroundSubs =
        Provider.of<SubtitleState>(context, listen: false).backgroundSubs ?? [];
    Duration subtitleDelay =
        Provider.of<OptionsState>(context, listen: false).subtitleDelay;
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

    ImageState imState = context.watch<ImageState>();
    AudioState audioState = context.watch<AudioState>();
    List<Subtitle>? subtitles =
        context.select<SubtitleState, List<Subtitle>?>((s) => s.subtitles);
    Duration subtitleDelay =
        context.select<OptionsState, Duration>((s) => s.subtitleDelay);

    Size imageSize = imState.imageSize;
    double subWidth = imageSize.width * subtitleWidthFactor;
    Duration subStartTime = const Duration(days: 999);
    if (subtitles != null && subtitles.isNotEmpty) {
      subStartTime = subtitles.first.start;
      subValue.value ??= subtitles.first;
    }

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        height: imageSize.height,
        width: imageSize.width,
        child: StreamBuilder<Duration>(
          stream: audioState.positionStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return displayImage(imState.image);

            Duration playerPos = snapshot.data!;
            Duration offset = playerPos - subStartTime;

            bool overlay =
                offset > -subtitleDelay - const Duration(milliseconds: 500);
            bool showSubs = offset > -subtitleDelay;

            return Stack(
              alignment: Alignment.center,
              children: [
                displayImage(imState.image),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: overlay ? 1.0 : 0.0,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: showSubtitleHighlight(imageSize.height, subWidth),
                  ),
                ),
                Opacity(
                  opacity: showSubs ? 1 : 0,
                  child: SizedBox(
                    width: subWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SubtitleListView(
                        onChange: onSubtitleChange,
                        blurPreview: true,
                        totalDivs: subsPerPage,
                        offset: subPosition.round() -
                            ((subsPerPage + 1) / 2).round() +
                            1,
                      ),
                    ),
                  ),
                ),
                showBackgroundSub(imageSize.height, subWidth),
                const Positioned(
                  top: 15,
                  right: 15,
                  child: PlaybackPosition(),
                ),
              ],
            );
          },
        ),
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
    Subtitle currentSub =
        Provider.of<SubtitleState>(context, listen: false).subtitles![index];
    subValue.value = currentSub;
  }

  Widget showSubtitleHighlight(double imageHeight, double subWidth) {
    return setPosAndHeight(
      pos: subPosition,
      subsPerPage: subsPerPage,
      child: ValueListenableBuilder<Subtitle?>(
        valueListenable: subValue,
        builder: (context, subtitle, child) {
          double height = imageHeight / subsPerPage;
          double subHeight = SubtitlePainter.getTextDisplayHeight(
            subtitle!.textWithoutSpeaker,
            subWidth - 40,
            Provider.of<OptionsState>(context, listen: false),
          );

          double highlightHeight = max(height * 0.8, subHeight + 35);

          return SubtitleHighlight(
            subtitle: subtitle,
            height: highlightHeight,
            maxHeight: height,
          );
        },
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
          Provider.of<OptionsState>(context, listen: false),
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
