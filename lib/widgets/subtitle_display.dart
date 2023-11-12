import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrolling_subtitles/extensions.dart';
import 'package:scrolling_subtitles/states/colors_state.dart';
import 'package:scrolling_subtitles/widgets/subtitle_painter.dart';
import 'package:subtitle/subtitle.dart';

class SubtitleDisplay extends StatelessWidget {
  final Subtitle subtitle;
  final bool blur;
  final bool current;

  const SubtitleDisplay(
    this.subtitle, {
    super.key,
    this.blur = false,
    this.current = false,
  });

  @override
  Widget build(BuildContext context) {
    ColorsState colorsState = context.watch<ColorsState>();
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
      painter: SubtitlePainter(text: text, colors: colors),
      child: Container(),
    );

    if (blur && text.isNotEmpty) {
      child = Blur(
        blurColor: Colors.white,
        blur: 5,
        colorOpacity: 0,
        child: child,
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}
