import 'package:freezed_annotation/freezed_annotation.dart';

part 'config_options.freezed.dart';
part 'config_options.g.dart';

enum SubtitleFontFamily {
  poppins,
  verdana,
  arial,
}

@freezed
abstract class ConfigOptions with _$ConfigOptions {
  const factory ConfigOptions({
    @Default(Duration(milliseconds: 500)) Duration subDelay,
    @Default(24) double fontSize,
    @Default(1.2) double lineHeight,
    @Default(5) double textBorder,
    @Default(SubtitleFontFamily.poppins) SubtitleFontFamily fontFamily,
  }) = _ConfigOptions;

  factory ConfigOptions.fromJson(Map<String, dynamic> json) =>
      _$ConfigOptionsFromJson(json);
}
