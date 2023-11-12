import 'dart:math';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:provider/provider.dart';
import 'package:scrolling_subtitles/extensions.dart';
import 'package:scrolling_subtitles/states/colors_state.dart';
import 'package:scrolling_subtitles/widgets/character_name.dart';
import 'package:scrolling_subtitles/widgets/subtitle_pointer.dart';
import 'package:subtitle/subtitle.dart';

class SubtitleHighlight extends StatelessWidget {
  const SubtitleHighlight({
    super.key,
    required this.subtitle,
    this.height = 80.0,
    this.maxHeight = double.infinity,
  });

  final Subtitle? subtitle;
  final double height;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    ColorsState colorsState = context.watch<ColorsState>();
    List<String> characters = subtitle?.characters ?? [];
    List<Color> colors = characters.map((e) => colorsState.of(e)).toList();
    if (colors.isEmpty) colors.add(Colors.white);

    BoxDecoration borderDecoration;
    LinearGradient gradient;
    if (colors.length == 1) {
      gradient = LinearGradient(colors: [colors.first, colors.first]);
    } else {
      gradient = LinearGradient(colors: colors);
    }
    borderDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: GradientBoxBorder(gradient: gradient, width: 3),
      gradient: gradient.scale(0.3),
    );

    return Row(
      children: [
        Flexible(fit: FlexFit.tight, child: SubtitlePointer(colors: colors)),
        Flexible(
          flex: 8,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Blur(
                borderRadius: BorderRadius.circular(20),
                blur: 10,
                colorOpacity: 0,
                blurColor: Colors.white,
                overlay: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Container(
                    key: ValueKey(characters.toString()),
                    decoration: borderDecoration,
                  ),
                ),
                child: Container(
                  // key: const ValueKey<String>("Subtitle Highlight Container"),
                  // duration: const Duration(milliseconds: 300),
                  height: min(height, maxHeight),
                ),
              ),
              Transform.translate(
                offset: Offset(10, -height / 2),
                child: CharacterName(subtitle: subtitle),
              ),
            ],
          ),
        ),
        Flexible(child: Container()),
      ],
    );
  }
}
