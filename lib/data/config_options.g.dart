// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConfigOptions _$ConfigOptionsFromJson(Map<String, dynamic> json) =>
    _ConfigOptions(
      subDelay: json['subDelay'] == null
          ? const Duration(milliseconds: 500)
          : Duration(microseconds: (json['subDelay'] as num).toInt()),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 24,
      lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.2,
      textBorder: (json['textBorder'] as num?)?.toDouble() ?? 5,
      fontFamily: $enumDecodeNullable(
              _$SubtitleFontFamilyEnumMap, json['fontFamily']) ??
          SubtitleFontFamily.poppins,
    );

Map<String, dynamic> _$ConfigOptionsToJson(_ConfigOptions instance) =>
    <String, dynamic>{
      'subDelay': instance.subDelay.inMicroseconds,
      'fontSize': instance.fontSize,
      'lineHeight': instance.lineHeight,
      'textBorder': instance.textBorder,
      'fontFamily': _$SubtitleFontFamilyEnumMap[instance.fontFamily]!,
    };

const _$SubtitleFontFamilyEnumMap = {
  SubtitleFontFamily.poppins: 'poppins',
  SubtitleFontFamily.verdana: 'verdana',
  SubtitleFontFamily.arial: 'arial',
};
