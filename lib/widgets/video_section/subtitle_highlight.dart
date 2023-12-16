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
    this.height = 80.0,
    this.maxHeight = double.infinity,
  });

  final Subtitle? subtitle;
  final double height;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    double borderRadius = 20, boxHeight = min(height, maxHeight);
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
      borderRadius: BorderRadius.circular(borderRadius),
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(height: boxHeight),
                      ),
                    ),
                    Container(
                      key: ValueKey(characters.toString()),
                      decoration: borderDecoration,
                      height: boxHeight,
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: Offset(10, -boxHeight / 2),
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
