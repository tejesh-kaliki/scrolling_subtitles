// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dart_casing/dart_casing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:subtitle/subtitle.dart';

// Project imports:
import 'package:visual_subs/extensions.dart';
import 'package:visual_subs/states/colors_state.dart';

class CharacterName extends StatelessWidget {
  const CharacterName({
    super.key,
    required this.subtitle,
  });

  final Subtitle? subtitle;

  @override
  Widget build(BuildContext context) {
    if (subtitle == null || subtitle!.speaker == "none") return Container();
    String speaker = subtitle!.speaker;

    ColorsState colorsState = context.watch<ColorsState>();
    List<Color> colors =
        subtitle!.characters.map((c) => colorsState.of(c)).toList();

    LinearGradient gradient;
    double luminance;
    if (colors.length == 1) {
      gradient = LinearGradient(colors: [colors[0], colors[0]]);
      luminance = colors.first.computeLuminance();
    } else {
      gradient = LinearGradient(colors: colors);
      luminance = colors
          .reduce((a, b) => Color.lerp(a, b, 0.5) ?? Colors.white)
          .computeLuminance();
    }
    BoxDecoration decoration = BoxDecoration(
      gradient: gradient,
      border: Border.all(
        color: Colors.white70,
        width: 2,
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
      borderRadius: BorderRadius.circular(100),
    );

    Color textColor = luminance < 0.3 ? Colors.white : Colors.black;
    return AnimatedContainer(
      key: const ValueKey<String>("Character Name"),
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: decoration,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: GoogleFonts.acme(color: textColor, fontSize: 22),
        child: Text(
          Casing.titleCase(speaker),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
