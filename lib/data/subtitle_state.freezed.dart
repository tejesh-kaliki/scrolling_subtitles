// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subtitle_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubtitleState {
  List<Subtitle> get subtitles;
  List<Subtitle> get backgroundSubs;
  Set<String> get characterSet;
  File? get subtitleFile;

  /// Create a copy of SubtitleState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SubtitleStateCopyWith<SubtitleState> get copyWith =>
      _$SubtitleStateCopyWithImpl<SubtitleState>(
          this as SubtitleState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SubtitleState &&
            const DeepCollectionEquality().equals(other.subtitles, subtitles) &&
            const DeepCollectionEquality()
                .equals(other.backgroundSubs, backgroundSubs) &&
            const DeepCollectionEquality()
                .equals(other.characterSet, characterSet) &&
            (identical(other.subtitleFile, subtitleFile) ||
                other.subtitleFile == subtitleFile));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(subtitles),
      const DeepCollectionEquality().hash(backgroundSubs),
      const DeepCollectionEquality().hash(characterSet),
      subtitleFile);

  @override
  String toString() {
    return 'SubtitleState(subtitles: $subtitles, backgroundSubs: $backgroundSubs, characterSet: $characterSet, subtitleFile: $subtitleFile)';
  }
}

/// @nodoc
abstract mixin class $SubtitleStateCopyWith<$Res> {
  factory $SubtitleStateCopyWith(
          SubtitleState value, $Res Function(SubtitleState) _then) =
      _$SubtitleStateCopyWithImpl;
  @useResult
  $Res call(
      {List<Subtitle> subtitles,
      List<Subtitle> backgroundSubs,
      Set<String> characterSet,
      File? subtitleFile});
}

/// @nodoc
class _$SubtitleStateCopyWithImpl<$Res>
    implements $SubtitleStateCopyWith<$Res> {
  _$SubtitleStateCopyWithImpl(this._self, this._then);

  final SubtitleState _self;
  final $Res Function(SubtitleState) _then;

  /// Create a copy of SubtitleState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subtitles = null,
    Object? backgroundSubs = null,
    Object? characterSet = null,
    Object? subtitleFile = freezed,
  }) {
    return _then(_self.copyWith(
      subtitles: null == subtitles
          ? _self.subtitles
          : subtitles // ignore: cast_nullable_to_non_nullable
              as List<Subtitle>,
      backgroundSubs: null == backgroundSubs
          ? _self.backgroundSubs
          : backgroundSubs // ignore: cast_nullable_to_non_nullable
              as List<Subtitle>,
      characterSet: null == characterSet
          ? _self.characterSet
          : characterSet // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      subtitleFile: freezed == subtitleFile
          ? _self.subtitleFile
          : subtitleFile // ignore: cast_nullable_to_non_nullable
              as File?,
    ));
  }
}

/// Adds pattern-matching-related methods to [SubtitleState].
extension SubtitleStatePatterns on SubtitleState {
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
    TResult Function(_SubtitleState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SubtitleState() when $default != null:
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
    TResult Function(_SubtitleState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubtitleState():
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
    TResult? Function(_SubtitleState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubtitleState() when $default != null:
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
    TResult Function(List<Subtitle> subtitles, List<Subtitle> backgroundSubs,
            Set<String> characterSet, File? subtitleFile)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SubtitleState() when $default != null:
        return $default(_that.subtitles, _that.backgroundSubs,
            _that.characterSet, _that.subtitleFile);
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
    TResult Function(List<Subtitle> subtitles, List<Subtitle> backgroundSubs,
            Set<String> characterSet, File? subtitleFile)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubtitleState():
        return $default(_that.subtitles, _that.backgroundSubs,
            _that.characterSet, _that.subtitleFile);
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
    TResult? Function(List<Subtitle> subtitles, List<Subtitle> backgroundSubs,
            Set<String> characterSet, File? subtitleFile)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubtitleState() when $default != null:
        return $default(_that.subtitles, _that.backgroundSubs,
            _that.characterSet, _that.subtitleFile);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _SubtitleState implements SubtitleState {
  const _SubtitleState(
      {final List<Subtitle> subtitles = const [],
      final List<Subtitle> backgroundSubs = const [],
      final Set<String> characterSet = const <String>{},
      this.subtitleFile})
      : _subtitles = subtitles,
        _backgroundSubs = backgroundSubs,
        _characterSet = characterSet;

  final List<Subtitle> _subtitles;
  @override
  @JsonKey()
  List<Subtitle> get subtitles {
    if (_subtitles is EqualUnmodifiableListView) return _subtitles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subtitles);
  }

  final List<Subtitle> _backgroundSubs;
  @override
  @JsonKey()
  List<Subtitle> get backgroundSubs {
    if (_backgroundSubs is EqualUnmodifiableListView) return _backgroundSubs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_backgroundSubs);
  }

  final Set<String> _characterSet;
  @override
  @JsonKey()
  Set<String> get characterSet {
    if (_characterSet is EqualUnmodifiableSetView) return _characterSet;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_characterSet);
  }

  @override
  final File? subtitleFile;

  /// Create a copy of SubtitleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SubtitleStateCopyWith<_SubtitleState> get copyWith =>
      __$SubtitleStateCopyWithImpl<_SubtitleState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SubtitleState &&
            const DeepCollectionEquality()
                .equals(other._subtitles, _subtitles) &&
            const DeepCollectionEquality()
                .equals(other._backgroundSubs, _backgroundSubs) &&
            const DeepCollectionEquality()
                .equals(other._characterSet, _characterSet) &&
            (identical(other.subtitleFile, subtitleFile) ||
                other.subtitleFile == subtitleFile));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_subtitles),
      const DeepCollectionEquality().hash(_backgroundSubs),
      const DeepCollectionEquality().hash(_characterSet),
      subtitleFile);

  @override
  String toString() {
    return 'SubtitleState(subtitles: $subtitles, backgroundSubs: $backgroundSubs, characterSet: $characterSet, subtitleFile: $subtitleFile)';
  }
}

/// @nodoc
abstract mixin class _$SubtitleStateCopyWith<$Res>
    implements $SubtitleStateCopyWith<$Res> {
  factory _$SubtitleStateCopyWith(
          _SubtitleState value, $Res Function(_SubtitleState) _then) =
      __$SubtitleStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<Subtitle> subtitles,
      List<Subtitle> backgroundSubs,
      Set<String> characterSet,
      File? subtitleFile});
}

/// @nodoc
class __$SubtitleStateCopyWithImpl<$Res>
    implements _$SubtitleStateCopyWith<$Res> {
  __$SubtitleStateCopyWithImpl(this._self, this._then);

  final _SubtitleState _self;
  final $Res Function(_SubtitleState) _then;

  /// Create a copy of SubtitleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? subtitles = null,
    Object? backgroundSubs = null,
    Object? characterSet = null,
    Object? subtitleFile = freezed,
  }) {
    return _then(_SubtitleState(
      subtitles: null == subtitles
          ? _self._subtitles
          : subtitles // ignore: cast_nullable_to_non_nullable
              as List<Subtitle>,
      backgroundSubs: null == backgroundSubs
          ? _self._backgroundSubs
          : backgroundSubs // ignore: cast_nullable_to_non_nullable
              as List<Subtitle>,
      characterSet: null == characterSet
          ? _self._characterSet
          : characterSet // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      subtitleFile: freezed == subtitleFile
          ? _self.subtitleFile
          : subtitleFile // ignore: cast_nullable_to_non_nullable
              as File?,
    ));
  }
}

// dart format on
