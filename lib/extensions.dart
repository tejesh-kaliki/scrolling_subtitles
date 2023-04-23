import 'package:subtitle/subtitle.dart';

extension SubtitleEx on Subtitle {
  RegExp get _characterNameRegex =>
      RegExp(r"^(?:([^:(]+)((?:\s*\([^)]+\))*)\s*:)?(.*)$");

  String get parsedData {
    RegExpMatch? match = _characterNameRegex.firstMatch(data);
    return match?.group(3)?.trim() ?? "";
  }

  String get character {
    RegExpMatch? match = _characterNameRegex.firstMatch(data);
    String name;
    if (match == null) {
      name = "none";
    } else if (match.group(2) == null) {
      name = match.group(1)!.trim();
    } else if (!match.group(2)!.contains("(background)")) {
      name = match.group(1)!.trim() + match.group(2)!.trim();
    } else {
      String extraText = match.group(2)!.replaceFirst("(background)", "");
      name = match.group(1)!.trim() + extraText.trim();
    }
    return name.toLowerCase();
  }

  bool get isBackgroundSub {
    RegExpMatch? match = _characterNameRegex.firstMatch(data);
    if (match == null || match.group(2) == null) return false;
    return match.group(2)!.contains("(background)");
  }
}
