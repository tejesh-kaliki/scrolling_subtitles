// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frame_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(frameState)
final frameStateProvider = FrameStateProvider._();

final class FrameStateProvider
    extends $FunctionalProvider<FrameState, FrameState, FrameState>
    with $Provider<FrameState> {
  FrameStateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'frameStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$frameStateHash();

  @$internal
  @override
  $ProviderElement<FrameState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FrameState create(Ref ref) {
    return frameState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FrameState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FrameState>(value),
    );
  }
}

String _$frameStateHash() => r'b04444a19ac981cf3c0ac190193d5212fda19cac';
