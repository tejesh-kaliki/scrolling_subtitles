import 'package:dart_casing/dart_casing.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scrolling_subtitles/extensions.dart';
import 'package:scrolling_subtitles/states/colors_state.dart';
import 'package:subtitle/subtitle.dart';

class CharacterName extends StatelessWidget {
  const CharacterName({
    super.key,
    required this.subtitle,
    required this.timestamp,
    this.previousSubtitle,
  });

  final Subtitle? subtitle;
  final Subtitle? previousSubtitle;
  final Duration timestamp;

  Duration scale(Duration d, double f) =>
      Duration(microseconds: (d.inMicroseconds * f).round());

  double _progress() {
    if (previousSubtitle == null) return 1.0;

    const dur = Duration(milliseconds: 300);
    final start = previousSubtitle!.end;

    final t = (timestamp - start).inMilliseconds / dur.inMilliseconds;

    return t.clamp(0.0, 1.0);
  }

  (LinearGradient, double) _gradientAndLuma(BuildContext context, Subtitle? s) {
    final colorsState = context.watch<ColorsState>();

    final colors = (s?.characters ?? []).map((c) => colorsState.of(c)).toList();

    if (colors.isEmpty) {
      return (LinearGradient(colors: [Colors.white, Colors.white]), 1);
    }

    if (colors.length == 1) {
      return (
        LinearGradient(colors: [colors.first, colors.first]),
        colors.first.computeLuminance()
      );
    }

    final mixed = colors.reduce((a, b) => Color.lerp(a, b, 0.5)!);

    return (LinearGradient(colors: colors), mixed.computeLuminance());
  }

  @override
  Widget build(BuildContext context) {
    if (subtitle == null || subtitle!.speaker == "none") {
      return const SizedBox();
    }

    final progress = _progress();

    final (gPrev, lPrev) = _gradientAndLuma(context, previousSubtitle);
    final (gCurr, lCurr) = _gradientAndLuma(context, subtitle);

    final luminance = lPrev * (1 - progress) + lCurr * progress;

    final textColor = luminance < 0.3 ? Colors.white : Colors.black;

    // NOTE: gradient interpolation simplified (good enough visually)
    final gradient = progress < 0.5 ? gPrev : gCurr;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        gradient: gradient,
        border: Border.all(
          color: Colors.white70,
          width: 2,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        Casing.titleCase(subtitle!.speaker),
        style: GoogleFonts.acme(
          color: textColor,
          fontSize: 22,
        ),
      ),
    );
  }
}
