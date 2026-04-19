// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'frame_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FrameState {
  bool get showSubs;
  int get currentSubIndex;
  double get scrollOffset;
  Subtitle? get backgroundSub;
  double get overlayOpacity;

  /// Create a copy of FrameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FrameStateCopyWith<FrameState> get copyWith =>
      _$FrameStateCopyWithImpl<FrameState>(this as FrameState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FrameState &&
            (identical(other.showSubs, showSubs) ||
                other.showSubs == showSubs) &&
            (identical(other.currentSubIndex, currentSubIndex) ||
                other.currentSubIndex == currentSubIndex) &&
            (identical(other.scrollOffset, scrollOffset) ||
                other.scrollOffset == scrollOffset) &&
            (identical(other.backgroundSub, backgroundSub) ||
                other.backgroundSub == backgroundSub) &&
            (identical(other.overlayOpacity, overlayOpacity) ||
                other.overlayOpacity == overlayOpacity));
  }

  @override
  int get hashCode => Object.hash(runtimeType, showSubs, currentSubIndex,
      scrollOffset, backgroundSub, overlayOpacity);

  @override
  String toString() {
    return 'FrameState(showSubs: $showSubs, currentSubIndex: $currentSubIndex, scrollOffset: $scrollOffset, backgroundSub: $backgroundSub, overlayOpacity: $overlayOpacity)';
  }
}

/// @nodoc
abstract mixin class $FrameStateCopyWith<$Res> {
  factory $FrameStateCopyWith(
          FrameState value, $Res Function(FrameState) _then) =
      _$FrameStateCopyWithImpl;
  @useResult
  $Res call(
      {bool showSubs,
      int currentSubIndex,
      double scrollOffset,
      Subtitle? backgroundSub,
      double overlayOpacity});
}

/// @nodoc
class _$FrameStateCopyWithImpl<$Res> implements $FrameStateCopyWith<$Res> {
  _$FrameStateCopyWithImpl(this._self, this._then);

  final FrameState _self;
  final $Res Function(FrameState) _then;

  /// Create a copy of FrameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? showSubs = null,
    Object? currentSubIndex = null,
    Object? scrollOffset = null,
    Object? backgroundSub = freezed,
    Object? overlayOpacity = null,
  }) {
    return _then(_self.copyWith(
      showSubs: null == showSubs
          ? _self.showSubs
          : showSubs // ignore: cast_nullable_to_non_nullable
              as bool,
      currentSubIndex: null == currentSubIndex
          ? _self.currentSubIndex
          : currentSubIndex // ignore: cast_nullable_to_non_nullable
              as int,
      scrollOffset: null == scrollOffset
          ? _self.scrollOffset
          : scrollOffset // ignore: cast_nullable_to_non_nullable
              as double,
      backgroundSub: freezed == backgroundSub
          ? _self.backgroundSub
          : backgroundSub // ignore: cast_nullable_to_non_nullable
              as Subtitle?,
      overlayOpacity: null == overlayOpacity
          ? _self.overlayOpacity
          : overlayOpacity // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [FrameState].
extension FrameStatePatterns on FrameState {
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
    TResult Function(_FrameState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FrameState() when $default != null:
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
    TResult Function(_FrameState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FrameState():
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
    TResult? Function(_FrameState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FrameState() when $default != null:
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
    TResult Function(bool showSubs, int currentSubIndex, double scrollOffset,
            Subtitle? backgroundSub, double overlayOpacity)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FrameState() when $default != null:
        return $default(_that.showSubs, _that.currentSubIndex,
            _that.scrollOffset, _that.backgroundSub, _that.overlayOpacity);
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
    TResult Function(bool showSubs, int currentSubIndex, double scrollOffset,
            Subtitle? backgroundSub, double overlayOpacity)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FrameState():
        return $default(_that.showSubs, _that.currentSubIndex,
            _that.scrollOffset, _that.backgroundSub, _that.overlayOpacity);
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
    TResult? Function(bool showSubs, int currentSubIndex, double scrollOffset,
            Subtitle? backgroundSub, double overlayOpacity)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FrameState() when $default != null:
        return $default(_that.showSubs, _that.currentSubIndex,
            _that.scrollOffset, _that.backgroundSub, _that.overlayOpacity);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _FrameState implements FrameState {
  const _FrameState(
      {required this.showSubs,
      required this.currentSubIndex,
      required this.scrollOffset,
      this.backgroundSub,
      required this.overlayOpacity});

  @override
  final bool showSubs;
  @override
  final int currentSubIndex;
  @override
  final double scrollOffset;
  @override
  final Subtitle? backgroundSub;
  @override
  final double overlayOpacity;

  /// Create a copy of FrameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FrameStateCopyWith<_FrameState> get copyWith =>
      __$FrameStateCopyWithImpl<_FrameState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FrameState &&
            (identical(other.showSubs, showSubs) ||
                other.showSubs == showSubs) &&
            (identical(other.currentSubIndex, currentSubIndex) ||
                other.currentSubIndex == currentSubIndex) &&
            (identical(other.scrollOffset, scrollOffset) ||
                other.scrollOffset == scrollOffset) &&
            (identical(other.backgroundSub, backgroundSub) ||
                other.backgroundSub == backgroundSub) &&
            (identical(other.overlayOpacity, overlayOpacity) ||
                other.overlayOpacity == overlayOpacity));
  }

  @override
  int get hashCode => Object.hash(runtimeType, showSubs, currentSubIndex,
      scrollOffset, backgroundSub, overlayOpacity);

  @override
  String toString() {
    return 'FrameState(showSubs: $showSubs, currentSubIndex: $currentSubIndex, scrollOffset: $scrollOffset, backgroundSub: $backgroundSub, overlayOpacity: $overlayOpacity)';
  }
}

/// @nodoc
abstract mixin class _$FrameStateCopyWith<$Res>
    implements $FrameStateCopyWith<$Res> {
  factory _$FrameStateCopyWith(
          _FrameState value, $Res Function(_FrameState) _then) =
      __$FrameStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool showSubs,
      int currentSubIndex,
      double scrollOffset,
      Subtitle? backgroundSub,
      double overlayOpacity});
}

/// @nodoc
class __$FrameStateCopyWithImpl<$Res> implements _$FrameStateCopyWith<$Res> {
  __$FrameStateCopyWithImpl(this._self, this._then);

  final _FrameState _self;
  final $Res Function(_FrameState) _then;

  /// Create a copy of FrameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? showSubs = null,
    Object? currentSubIndex = null,
    Object? scrollOffset = null,
    Object? backgroundSub = freezed,
    Object? overlayOpacity = null,
  }) {
    return _then(_FrameState(
      showSubs: null == showSubs
          ? _self.showSubs
          : showSubs // ignore: cast_nullable_to_non_nullable
              as bool,
      currentSubIndex: null == currentSubIndex
          ? _self.currentSubIndex
          : currentSubIndex // ignore: cast_nullable_to_non_nullable
              as int,
      scrollOffset: null == scrollOffset
          ? _self.scrollOffset
          : scrollOffset // ignore: cast_nullable_to_non_nullable
              as double,
      backgroundSub: freezed == backgroundSub
          ? _self.backgroundSub
          : backgroundSub // ignore: cast_nullable_to_non_nullable
              as Subtitle?,
      overlayOpacity: null == overlayOpacity
          ? _self.overlayOpacity
          : overlayOpacity // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

// dart format on
