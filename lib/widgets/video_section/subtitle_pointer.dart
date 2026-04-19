import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrolling_subtitles/extensions.dart';

class SubtitlePointer extends StatelessWidget {
  const SubtitlePointer({
    super.key,
    this.colors = const [Colors.white],
    required this.timestamp,
  });

  final List<Color> colors;
  final Duration timestamp;

  @override
  Widget build(BuildContext context) {
    Color color1, color2;
    if (colors.length == 1) {
      color1 = color2 = colors.first.clampLightness(0.625, 0.94);
    } else {
      color1 = colors[0].clampLightness(0.625, 0.94);
      color2 = colors[1].clampLightness(0.625, 0.94);
    }

    // The animation should map every 2 seconds between 0 and pi.
    // So 0-pi for first 2 seconds. pi-0 for next 2, and so on.
    double offset = timestamp.inMilliseconds / 2000;
    offset = offset % 2;
    if (offset > 1) {
      offset = 2 - offset;
    }
    offset = sin(offset * pi);

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Positioned(
          right: 15,
          child: Transform.translate(
            offset: Offset(offset * 10, 0),
            child: Transform.rotate(
              angle: -1 / 2,
              child: Icon(
                CupertinoIcons.triangle,
                color: color1,
              ),
            ),
          ),
        ),
        Positioned(
          right: 30,
          child: Transform.translate(
            offset: Offset(offset * 15, 0),
            child: Transform.rotate(
              angle: -1 / 2,
              child: Icon(
                CupertinoIcons.triangle_fill,
                color: color2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
