import 'dart:math';

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
    required this.progress,
    this.previousSubtitle,
  });

  final Subtitle? subtitle;
  final Subtitle? previousSubtitle;
  final double progress;

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

  LinearGradient lerpGradient(LinearGradient a, LinearGradient b, double t) {
    final len = min(a.colors.length, b.colors.length);

    final colors = List.generate(
      len,
      (i) => Color.lerp(a.colors[i], b.colors[i], t)!,
    );

    return LinearGradient(colors: colors);
  }

  @override
  Widget build(BuildContext context) {
    if (subtitle == null || subtitle!.speaker == "none") {
      return const SizedBox();
    }

    final p = progress;
    final effectiveOpacity = previousSubtitle == null ? 1.0 : progress;

    final (gPrev, lPrev) = _gradientAndLuma(context, previousSubtitle);
    final (gCurr, lCurr) = _gradientAndLuma(context, subtitle);

    final gradient = lerpGradient(gPrev, gCurr, p);

    final luminance = lPrev * (1 - p) + lCurr * p;

    final textColor = luminance < 0.3 ? Colors.white : Colors.black;

    return Opacity(
      opacity: effectiveOpacity,
      child: Container(
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
      ),
    );
  }
}
