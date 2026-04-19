// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtitle_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SubtitleNotifier)
final subtitleProvider = SubtitleNotifierProvider._();

final class SubtitleNotifierProvider
    extends $NotifierProvider<SubtitleNotifier, SubtitleState> {
  SubtitleNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'subtitleProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$subtitleNotifierHash();

  @$internal
  @override
  SubtitleNotifier create() => SubtitleNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubtitleState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubtitleState>(value),
    );
  }
}

String _$subtitleNotifierHash() => r'ceb92d9433e576cafe3d5ad8d14bfd808aa284ee';

abstract class _$SubtitleNotifier extends $Notifier<SubtitleState> {
  SubtitleState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SubtitleState, SubtitleState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SubtitleState, SubtitleState>,
        SubtitleState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
