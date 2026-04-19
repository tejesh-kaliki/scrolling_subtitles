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
    required this.transitionStart,
    required this.timestamp,
    this.previousSubtitle,
    this.height = 80.0,
    this.maxHeight = double.infinity,
  });

  final Subtitle? subtitle;
  final Subtitle? previousSubtitle;
  final Duration timestamp;
  final double height;
  final double maxHeight;
  final Duration transitionStart;

  // ---- helpers ----

  Duration scale(Duration d, double f) =>
      Duration(microseconds: (d.inMicroseconds * f).round());

  double _progress(Duration now, Duration start, Duration dur) {
    final t = (now - start).inMilliseconds / dur.inMilliseconds;
    return t.clamp(0.0, 1.0);
  }

  double _fadeProgress() {
    if (previousSubtitle == null) return 1.0;

    const dur = Duration(milliseconds: 300);
    final start = transitionStart;

    return _progress(timestamp, start, dur);
  }

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

    final decoration = _decoration(colors, borderRadius);

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
          decoration: decoration,
          height: boxHeight,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final boxHeight = min(height, maxHeight);
    final progress = _fadeProgress();

    final colors = _colors(context, subtitle);

    return Row(
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: SubtitlePointer(
            colors: colors,
            timestamp: timestamp,
          ),
        ),
        Flexible(
          flex: 8,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // previous → fade out
              if (previousSubtitle != null)
                Opacity(
                  opacity: 1 - progress,
                  child: _box(context, previousSubtitle, boxHeight),
                ),

              // current → fade in
              Opacity(
                opacity: progress,
                child: _box(context, subtitle, boxHeight),
              ),

              // character name (same progress)
              Transform.translate(
                offset: Offset(10, -boxHeight / 2),
                child: CharacterName(
                  subtitle: subtitle,
                  previousSubtitle: previousSubtitle,
                  timestamp: timestamp,
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
