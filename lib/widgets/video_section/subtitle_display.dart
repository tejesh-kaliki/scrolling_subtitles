import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:scrolling_subtitles/extensions.dart';
import 'package:scrolling_subtitles/providers/options_provider.dart';
import 'package:scrolling_subtitles/states/colors_state.dart';
import 'package:scrolling_subtitles/widgets/video_section/subtitle_painter.dart';
import 'package:subtitle/subtitle.dart';

class SubtitleDisplay extends ConsumerWidget {
  final Subtitle subtitle;
  final bool blur;
  final bool current;
  final double progress;

  const SubtitleDisplay(
    this.subtitle, {
    super.key,
    this.blur = false,
    this.current = false,
    this.progress = 1.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ColorsState colorsState = context.watch<ColorsState>();
    final options = ref.watch(optionsProvider);
    String text = subtitle.textWithoutSpeaker;

    List<Color> colors;
    if (blur || current) {
      colors = [];
    } else {
      colors = subtitle.characters
          .map((c) => colorsState.of(c).clampLightness(0.65, 1.0))
          .toList();
    }
    if (colors.isEmpty) colors = [Colors.white];

    Widget child = CustomPaint(
      painter: SubtitlePainter(
        text: text,
        colors: colors,
        options: options,
      ),
      child: Container(),
    );

    if (blur && text.isNotEmpty) {
      double blurAmount = 0;
      final p = Curves.easeOut.transform(progress);
      blurAmount = (1 - p) * 5;
      child = ImageFiltered(
        imageFilter: ImageFilter.blur(
            sigmaX: blurAmount, sigmaY: blurAmount, tileMode: TileMode.clamp),
        child: child,
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}
