// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TimelineNotifier)
final timelineProvider = TimelineNotifierProvider._();

final class TimelineNotifierProvider
    extends $NotifierProvider<TimelineNotifier, Duration> {
  TimelineNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'timelineProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$timelineNotifierHash();

  @$internal
  @override
  TimelineNotifier create() => TimelineNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$timelineNotifierHash() => r'0151e180265fb90d9814c1499ca66bd34b91741c';

abstract class _$TimelineNotifier extends $Notifier<Duration> {
  Duration build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Duration, Duration>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Duration, Duration>, Duration, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
