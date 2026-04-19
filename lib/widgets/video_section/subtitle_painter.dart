import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrolling_subtitles/data/config_options.dart';

class SubtitlePainter extends CustomPainter {
  final String text;
  final List<Color> colors;
  final ConfigOptions options;

  SubtitlePainter({
    required this.options,
    this.text = "",
    this.colors = const [],
  });

  static TextStyle getTextStyle(ConfigOptions options) {
    TextStyle style = TextStyle(
      fontWeight: FontWeight.w500,
      letterSpacing: 1,
      fontSize: options.fontSize,
      height: options.lineHeight,
    );
    switch (options.fontFamily) {
      case SubtitleFontFamily.poppins:
        return GoogleFonts.poppins(textStyle: style);
      case SubtitleFontFamily.verdana:
        return style.copyWith(fontFamily: "Verdana");
      case SubtitleFontFamily.arial:
        return style.copyWith(fontFamily: "Arial");
    }
  }

  Paint getBorderPainter() {
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = options.textBorder
      ..color = Colors.black.withValues(alpha: 0.75);
  }

  static List<InlineSpan> getTextSpans(String text) {
    // Matches the italic text, i.e., text between *s.
    // But does not match if * is preceded with \, like \*
    RegExp italicRegex = RegExp(r"(?<!\\)\*(.*?)(?<!\\)\*");
    List<InlineSpan> spans = [];

    Iterable<RegExpMatch> allMatches = italicRegex.allMatches(text);
    int currentIndex = 0;

    for (RegExpMatch match in allMatches) {
      spans.add(TextSpan(
        text: text.substring(currentIndex, match.start).replaceAll(r"\*", "*"),
      ));

      spans.add(TextSpan(
        text: match.group(1)!.replaceAll(r"\*", "*"),
        style: const TextStyle(fontStyle: FontStyle.italic),
      ));

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex).replaceAll(r"\*", "*"),
      ));
    }

    return spans;
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    TextStyle textStyle = getTextStyle(options);
    List<InlineSpan> textSpans = getTextSpans(text);

    TextSpan borderTextSpan = TextSpan(
      children: textSpans,
      style: textStyle.copyWith(foreground: getBorderPainter()),
    );
    TextPainter borderPainter = TextPainter(
      text: borderTextSpan,
      textDirection: TextDirection.ltr,
    );

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
    TextSpan textSpan = TextSpan(children: textSpans, style: textStyle);
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

    return options != oldDelegate.options;
  }

  static double getTextDisplayHeight(
      String text, double width, ConfigOptions options) {
    TextStyle textStyle = getTextStyle(options);
    List<InlineSpan> textSpans = getTextSpans(text);

    TextSpan textSpan = TextSpan(children: textSpans, style: textStyle);
    TextPainter painter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    painter.layout(minWidth: 0, maxWidth: width - 10);
    return painter.height;
  }
}
