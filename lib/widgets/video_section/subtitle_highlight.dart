import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:provider/provider.dart';
import 'package:scrolling_subtitles/extensions.dart';
import 'package:scrolling_subtitles/states/colors_state.dart';
import 'package:scrolling_subtitles/widgets/video_section/character_name.dart';
import 'package:scrolling_subtitles/widgets/video_section/subtitle_pointer.dart';
import 'package:subtitle/subtitle.dart';

class SubtitleHighlight extends StatelessWidget {
  const SubtitleHighlight({
    super.key,
    required this.subtitle,
    required this.progress,
    required this.timestamp,
    this.previousSubtitle,
    this.height = 80.0,
    this.maxHeight = double.infinity,
  });

  final Subtitle? subtitle;
  final Subtitle? previousSubtitle;
  final Duration timestamp;
  final double progress;
  final double height;
  final double maxHeight;

  List<Color> _colors(BuildContext context, Subtitle? s) {
    final colorsState = context.watch<ColorsState>();
    final chars = s?.characters ?? const <String>[];
    final cols = chars.map((e) => colorsState.of(e)).toList();
    if (cols.isEmpty) return [Colors.white];
    return cols;
  }

  BoxDecoration _decoration(List<Color> colors, double borderRadius) {
    final gradient = colors.length == 1
        ? LinearGradient(colors: [colors.first, colors.first])
        : LinearGradient(colors: colors);

    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: GradientBoxBorder(gradient: gradient, width: 3),
      gradient: gradient.scale(0.3),
    );
  }

  Widget _box(BuildContext context, Subtitle? s, double boxHeight) {
    final colors = _colors(context, s);
    final borderRadius = 20.0;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(height: boxHeight),
          ),
        ),
        Container(
          decoration: _decoration(colors, borderRadius),
          height: boxHeight,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final boxHeight = min(height, maxHeight);
    final p = previousSubtitle == null ? 1.0 : progress;

    final colors = _colors(context, subtitle);

    return Row(
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: SubtitlePointer(colors: colors, timestamp: timestamp),
        ),
        Flexible(
          flex: 8,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              if (previousSubtitle != null)
                Opacity(
                  opacity: 1 - p,
                  child: _box(context, previousSubtitle, boxHeight),
                ),
              Opacity(
                opacity: p,
                child: _box(context, subtitle, boxHeight),
              ),
              Transform.translate(
                offset: Offset(10, -boxHeight / 2),
                child: CharacterName(
                  subtitle: subtitle,
                  previousSubtitle: previousSubtitle,
                  progress: p,
                ),
              ),
            ],
          ),
        ),
        const Flexible(child: SizedBox()),
      ],
    );
  }
}
