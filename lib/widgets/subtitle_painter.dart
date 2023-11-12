import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubtitlePainter extends CustomPainter {
  final String text;
  final List<Color> colors;

  SubtitlePainter({
    this.text = "",
    this.colors = const [],
  });

  TextStyle getTextStyle() {
    return GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        letterSpacing: 1,
        fontSize: 24,
        height: 1.2,
      ),
    );
  }

  Paint getBorderPainter() {
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 5
      ..color = Colors.black.withOpacity(0.75);
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    TextStyle textStyle = getTextStyle();

    TextSpan borderTextSpan = TextSpan(
      text: text,
      style: textStyle.copyWith(foreground: getBorderPainter()),
    );

    TextPainter borderPainter =
        TextPainter(text: borderTextSpan, textDirection: TextDirection.ltr);

    borderPainter.layout(minWidth: 0, maxWidth: size.width - 10);
    borderPainter.paint(
        canvas, Offset(5, (size.height - borderPainter.height) / 2 + 3));

    if (colors.length == 1) {
      textStyle = textStyle.copyWith(color: colors.first);
    } else {
      textStyle = textStyle.copyWith(
        foreground: Paint()
          ..shader = LinearGradient(colors: colors).createShader(
            Rect.fromLTWH(0, 0, borderPainter.width, borderPainter.height),
          ),
      );
    }
    TextSpan textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    TextPainter painter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    painter.layout(minWidth: 0, maxWidth: size.width - 10);
    painter.paint(canvas, Offset(5, (size.height - painter.height) / 2 + 3));
  }

  @override
  bool shouldRepaint(covariant SubtitlePainter oldDelegate) {
    if (oldDelegate.text != text) return true;
    int oldLength = oldDelegate.colors.length;
    int newLength = colors.length;
    if (oldLength != newLength) return true;
    for (int i = 0; i < oldLength; i++) {
      if (oldDelegate.colors[i] != colors[i]) return true;
    }
    return false;
  }
}
