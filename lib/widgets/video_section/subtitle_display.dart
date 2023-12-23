// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:subtitle/subtitle.dart';

// Project imports:
import 'package:visual_subs/extensions.dart';
import 'package:visual_subs/states/colors_state.dart';
import 'package:visual_subs/states/options_state.dart';
import 'package:visual_subs/widgets/video_section/subtitle_painter.dart';

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
    OptionsState optionsState = context.watch<OptionsState>();
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
        options: optionsState,
      ),
      child: Container(),
    );

    if (blur && text.isNotEmpty) {
      child = ImageFiltered(
        imageFilter:
            ImageFilter.blur(sigmaX: 5, sigmaY: 5, tileMode: TileMode.clamp),
        child: child,
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}
