import 'dart:async';
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scrolling_subtitles/data/config_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'options_provider.g.dart';

const optionsKey = 'options';

@riverpod
class OptionsNotifier extends _$OptionsNotifier {
  @override
  ConfigOptions build() {
    unawaited(loadPreviousState());
    return ConfigOptions();
  }

  Future<void> loadPreviousState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? json = prefs.getString(optionsKey);
    if (json == null) return;
    state = ConfigOptions.fromJson(jsonDecode(json));
  }

  Future<void> setOptions(ConfigOptions options) async {
    state = options;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(optionsKey, jsonEncode(options.toJson()));
  }
}
