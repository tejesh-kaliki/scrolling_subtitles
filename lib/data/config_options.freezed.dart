// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config_options.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConfigOptions {
  Duration get subDelay;
  double get fontSize;
  double get lineHeight;
  double get textBorder;
  SubtitleFontFamily get fontFamily;

  /// Create a copy of ConfigOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ConfigOptionsCopyWith<ConfigOptions> get copyWith =>
      _$ConfigOptionsCopyWithImpl<ConfigOptions>(
          this as ConfigOptions, _$identity);

  /// Serializes this ConfigOptions to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ConfigOptions &&
            (identical(other.subDelay, subDelay) ||
                other.subDelay == subDelay) &&
            (identical(other.fontSize, fontSize) ||
                other.fontSize == fontSize) &&
            (identical(other.lineHeight, lineHeight) ||
                other.lineHeight == lineHeight) &&
            (identical(other.textBorder, textBorder) ||
                other.textBorder == textBorder) &&
            (identical(other.fontFamily, fontFamily) ||
                other.fontFamily == fontFamily));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, subDelay, fontSize, lineHeight, textBorder, fontFamily);

  @override
  String toString() {
    return 'ConfigOptions(subDelay: $subDelay, fontSize: $fontSize, lineHeight: $lineHeight, textBorder: $textBorder, fontFamily: $fontFamily)';
  }
}

/// @nodoc
abstract mixin class $ConfigOptionsCopyWith<$Res> {
  factory $ConfigOptionsCopyWith(
          ConfigOptions value, $Res Function(ConfigOptions) _then) =
      _$ConfigOptionsCopyWithImpl;
  @useResult
  $Res call(
      {Duration subDelay,
      double fontSize,
      double lineHeight,
      double textBorder,
      SubtitleFontFamily fontFamily});
}

/// @nodoc
class _$ConfigOptionsCopyWithImpl<$Res>
    implements $ConfigOptionsCopyWith<$Res> {
  _$ConfigOptionsCopyWithImpl(this._self, this._then);

  final ConfigOptions _self;
  final $Res Function(ConfigOptions) _then;

  /// Create a copy of ConfigOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subDelay = null,
    Object? fontSize = null,
    Object? lineHeight = null,
    Object? textBorder = null,
    Object? fontFamily = null,
  }) {
    return _then(_self.copyWith(
      subDelay: null == subDelay
          ? _self.subDelay
          : subDelay // ignore: cast_nullable_to_non_nullable
              as Duration,
      fontSize: null == fontSize
          ? _self.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double,
      lineHeight: null == lineHeight
          ? _self.lineHeight
          : lineHeight // ignore: cast_nullable_to_non_nullable
              as double,
      textBorder: null == textBorder
          ? _self.textBorder
          : textBorder // ignore: cast_nullable_to_non_nullable
              as double,
      fontFamily: null == fontFamily
          ? _self.fontFamily
          : fontFamily // ignore: cast_nullable_to_non_nullable
              as SubtitleFontFamily,
    ));
  }
}

/// Adds pattern-matching-related methods to [ConfigOptions].
extension ConfigOptionsPatterns on ConfigOptions {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ConfigOptions value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ConfigOptions() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ConfigOptions value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConfigOptions():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ConfigOptions value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConfigOptions() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(Duration subDelay, double fontSize, double lineHeight,
            double textBorder, SubtitleFontFamily fontFamily)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ConfigOptions() when $default != null:
        return $default(_that.subDelay, _that.fontSize, _that.lineHeight,
            _that.textBorder, _that.fontFamily);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(Duration subDelay, double fontSize, double lineHeight,
            double textBorder, SubtitleFontFamily fontFamily)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConfigOptions():
        return $default(_that.subDelay, _that.fontSize, _that.lineHeight,
            _that.textBorder, _that.fontFamily);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(Duration subDelay, double fontSize, double lineHeight,
            double textBorder, SubtitleFontFamily fontFamily)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConfigOptions() when $default != null:
        return $default(_that.subDelay, _that.fontSize, _that.lineHeight,
            _that.textBorder, _that.fontFamily);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ConfigOptions implements ConfigOptions {
  const _ConfigOptions(
      {this.subDelay = const Duration(milliseconds: 500),
      this.fontSize = 24,
      this.lineHeight = 1.2,
      this.textBorder = 5,
      this.fontFamily = SubtitleFontFamily.poppins});
  factory _ConfigOptions.fromJson(Map<String, dynamic> json) =>
      _$ConfigOptionsFromJson(json);

  @override
  @JsonKey()
  final Duration subDelay;
  @override
  @JsonKey()
  final double fontSize;
  @override
  @JsonKey()
  final double lineHeight;
  @override
  @JsonKey()
  final double textBorder;
  @override
  @JsonKey()
  final SubtitleFontFamily fontFamily;

  /// Create a copy of ConfigOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ConfigOptionsCopyWith<_ConfigOptions> get copyWith =>
      __$ConfigOptionsCopyWithImpl<_ConfigOptions>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ConfigOptionsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ConfigOptions &&
            (identical(other.subDelay, subDelay) ||
                other.subDelay == subDelay) &&
            (identical(other.fontSize, fontSize) ||
                other.fontSize == fontSize) &&
            (identical(other.lineHeight, lineHeight) ||
                other.lineHeight == lineHeight) &&
            (identical(other.textBorder, textBorder) ||
                other.textBorder == textBorder) &&
            (identical(other.fontFamily, fontFamily) ||
                other.fontFamily == fontFamily));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, subDelay, fontSize, lineHeight, textBorder, fontFamily);

  @override
  String toString() {
    return 'ConfigOptions(subDelay: $subDelay, fontSize: $fontSize, lineHeight: $lineHeight, textBorder: $textBorder, fontFamily: $fontFamily)';
  }
}

/// @nodoc
abstract mixin class _$ConfigOptionsCopyWith<$Res>
    implements $ConfigOptionsCopyWith<$Res> {
  factory _$ConfigOptionsCopyWith(
          _ConfigOptions value, $Res Function(_ConfigOptions) _then) =
      __$ConfigOptionsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Duration subDelay,
      double fontSize,
      double lineHeight,
      double textBorder,
      SubtitleFontFamily fontFamily});
}

/// @nodoc
class __$ConfigOptionsCopyWithImpl<$Res>
    implements _$ConfigOptionsCopyWith<$Res> {
  __$ConfigOptionsCopyWithImpl(this._self, this._then);

  final _ConfigOptions _self;
  final $Res Function(_ConfigOptions) _then;

  /// Create a copy of ConfigOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? subDelay = null,
    Object? fontSize = null,
    Object? lineHeight = null,
    Object? textBorder = null,
    Object? fontFamily = null,
  }) {
    return _then(_ConfigOptions(
      subDelay: null == subDelay
          ? _self.subDelay
          : subDelay // ignore: cast_nullable_to_non_nullable
              as Duration,
      fontSize: null == fontSize
          ? _self.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double,
      lineHeight: null == lineHeight
          ? _self.lineHeight
          : lineHeight // ignore: cast_nullable_to_non_nullable
              as double,
      textBorder: null == textBorder
          ? _self.textBorder
          : textBorder // ignore: cast_nullable_to_non_nullable
              as double,
      fontFamily: null == fontFamily
          ? _self.fontFamily
          : fontFamily // ignore: cast_nullable_to_non_nullable
              as SubtitleFontFamily,
    ));
  }
}

// dart format on
