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
    this.nextSubtitle,
  });

  final Subtitle? subtitle;
  final Subtitle? nextSubtitle;
  final double progress;

  (LinearGradient, double) _gradientAndLuma(BuildContext context, Subtitle? s) {
    final colorsState = context.watch<ColorsState>();
    final colors = (s?.characters ?? []).map((c) => colorsState.of(c)).toList();

    if (colors.isEmpty) {
      return (const LinearGradient(colors: [Colors.white, Colors.white]), 1.0);
    }
    if (colors.length == 1) {
      return (
        LinearGradient(colors: [colors.first, colors.first]),
        colors.first.computeLuminance(),
      );
    }
    final mixed = colors.reduce((a, b) => Color.lerp(a, b, 0.5)!);
    return (LinearGradient(colors: colors), mixed.computeLuminance());
  }

  Widget _badge(LinearGradient gradient, double luminance, String speaker) {
    final textColor = luminance < 0.3 ? Colors.white : Colors.black;
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
        Casing.titleCase(speaker),
        style: GoogleFonts.acme(color: textColor, fontSize: 22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (subtitle == null || subtitle!.speaker == 'none')
      return const SizedBox();

    final (gCurr, lCurr) = _gradientAndLuma(context, subtitle);
    final showWipe =
        nextSubtitle != null && nextSubtitle!.speaker != subtitle!.speaker;

    if (!showWipe) return _badge(gCurr, lCurr, subtitle!.speaker);

    final (gNext, lNext) = _gradientAndLuma(context, nextSubtitle);

    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Opacity(opacity: 1 - progress, child: _badge(gCurr, lCurr, subtitle!.speaker)),
        Opacity(opacity: progress, child: _badge(gNext, lNext, nextSubtitle!.speaker)),
      ],
    );
  }
}
