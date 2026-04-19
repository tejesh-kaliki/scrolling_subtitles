import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timeline_provider.g.dart';

@riverpod
class TimelineNotifier extends _$TimelineNotifier {
  @override
  Duration build() {
    return Duration.zero;
  }

  void setTime(Duration time) {
    state = time;
  }
}
