import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrolling_subtitles/extensions.dart';

class SubtitlePointer extends StatefulWidget {
  const SubtitlePointer({
    super.key,
    this.colors = const [Colors.white],
  });

  final List<Color> colors;

  @override
  State<SubtitlePointer> createState() => _SubtitlePointerState();
}

class _SubtitlePointerState extends State<SubtitlePointer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )
      ..forward()
      ..addListener(() {
        if (_controller.isDismissed) {
          _controller.forward();
        } else if (_controller.isCompleted) {
          _controller.reverse();
        }
      });
    _animation1 = Tween<double>(begin: 0, end: pi).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Color> colors =
        widget.colors.map((e) => e.clampLightness(0.625, 0.94)).toList();
    Color color1, color2;
    if (colors.length == 1) {
      color1 = color2 = colors.first;
    } else {
      color1 = colors[0];
      color2 = colors[1];
    }

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Positioned(
          right: 15,
          child: Transform.translate(
            offset: Offset(sin(_animation1.value) * 10, 0),
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
            offset: Offset(sin(_animation1.value) * 15, 0),
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
