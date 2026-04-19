// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'options_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OptionsNotifier)
final optionsProvider = OptionsNotifierProvider._();

final class OptionsNotifierProvider
    extends $NotifierProvider<OptionsNotifier, ConfigOptions> {
  OptionsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'optionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$optionsNotifierHash();

  @$internal
  @override
  OptionsNotifier create() => OptionsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConfigOptions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConfigOptions>(value),
    );
  }
}

String _$optionsNotifierHash() => r'c250b4d891f04ab681f12b3e3ed8cf8dbf0fc1dc';

abstract class _$OptionsNotifier extends $Notifier<ConfigOptions> {
  ConfigOptions build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ConfigOptions, ConfigOptions>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ConfigOptions, ConfigOptions>,
        ConfigOptions,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
