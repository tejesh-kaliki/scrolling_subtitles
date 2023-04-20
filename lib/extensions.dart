import 'package:subtitle/subtitle.dart';

extension SubtitleEx on Subtitle {
  String get parsedData {
    int i = data.indexOf(":");
    if (i == -1) return data;
    return data.substring(i + 1).trim();
  }

  String get character {
    int i = data.indexOf(":");
    if (i == -1) return "none";
    return data.substring(0, i).trim().toLowerCase();
  }

  bool get isBackgroundSub {
    int i = data.indexOf(":");
    if (i == -1) return false;
    return data.substring(0, i).trim().contains("(background)");
  }
}
