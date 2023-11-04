import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/painting.dart';
import 'package:subtitle/subtitle.dart';

extension SubtitleEx on Subtitle {
  static final RegExp _characterNameRegex =
      RegExp(r"^(?:([^:(]+)((?:\s*\([^)]+\))*)\s*:)?(.*)$");

  String get parsedData {
    RegExpMatch? match = _characterNameRegex.firstMatch(data);
    return match?.group(3)?.trim() ?? "";
  }

  List<String> get characters {
    final RegExp splitRegx = RegExp(r"[+&]");
    String text = speaker;
    if (text.contains(splitRegx)) {
      return text.split(splitRegx).map((e) => e.trim()).toList();
    }
    return [speaker];
  }

  String get speaker {
    RegExpMatch? match = _characterNameRegex.firstMatch(data.toLowerCase());
    if (match == null || match.group(1) == null) {
      return "none";
    } else if (match.group(2) == null) {
      return match.group(1)!.trim();
    } else if (!match.group(2)!.contains("(background)")) {
      return match.group(1)!.trim() + match.group(2)!.trim();
    } else {
      String extraText = match.group(2)!.replaceFirst("(background)", "");
      return match.group(1)!.trim() + extraText.trim();
    }
  }

  bool get isBackgroundSub {
    RegExpMatch? match = _characterNameRegex.firstMatch(data.toLowerCase());
    return match?.group(2)?.contains("(background)") ?? false;
  }
}

extension ColorLuminance on Color {
  double getLightness() {
    return HSLColor.fromColor(this).lightness;
  }

  Color withLightness(double lightness) {
    HSLColor hslColor = HSLColor.fromColor(this);
    return hslColor.withLightness(lightness).toColor();
  }

  Color clampLightness(double lower, double upper) {
    Color color;
    if (getLightness() < lower) {
      color = withLightness(lower);
    } else if (getLightness() > upper) {
      color = withLightness(upper);
    } else {
      color = this;
    }
    return color;
  }
}

extension HexColor on Color {
  static Color fromHex(String hex) {
    return Color(int.parse("FF${hex.toUpperCase()}", radix: 16));
  }

  String toJson() => hex;
}
