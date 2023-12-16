import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrolling_subtitles/states/audio_state.dart';
import 'package:scrolling_subtitles/states/options_state.dart';
import 'package:scrolling_subtitles/states/subtitle_state.dart';
import 'package:subtitle/subtitle.dart';

import 'subtitle_display.dart';

class SubtitleListView extends StatefulWidget {
  const SubtitleListView({
    super.key,
    required this.onChange,
    this.blurPreview = false,
    this.totalDivs = 7,
    this.offset = 1,
  });

  final void Function(int index) onChange;
  final bool blurPreview;
  final int totalDivs;
  final int offset;

  @override
  State<SubtitleListView> createState() => _SubtitleListViewState();
}

class _SubtitleListViewState extends State<SubtitleListView> {
  /// Current Subtitle Index
  ValueNotifier<int> csIndex = ValueNotifier(0);
  Subtitle? currentSub;
  int numSubs = 0;
  late PageController _controller;
  late int offset;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 1 / widget.totalDivs);
    Provider.of<AudioState>(context, listen: false)
        .positionStream
        .listen(onPositionChange);
    offset = widget.offset;
  }

  void onPositionChange(Duration position) {
    List<Subtitle>? subtitles =
        Provider.of<SubtitleState>(context, listen: false).subtitles;
    Duration subDelay =
        Provider.of<OptionsState>(context, listen: false).subtitleDelay;
    if (subtitles == null) return;
    int i = csIndex.value;
    Subtitle sub = subtitles[i];
    position += subDelay;
    if (position > sub.start && position <= sub.end) return;

    if (position > sub.end) {
      do {
        i++;
      } while (i < subtitles.length && subtitles[i].start < position);
      i--;
    } else if (position < sub.start) {
      do {
        i--;
      } while (i >= 0 && subtitles[i].end > position);
      i++;
    }
    if (csIndex.value != i) {
      int dif = (csIndex.value - i).abs();
      onPageChanged(i);
      if (dif < 5) {
        _controller.animateToPage(
          i,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _controller.jumpToPage(i);
      }
    }
  }

  void onPageChanged(int page) {
    csIndex.value = page;
    if (page < numSubs) {
      widget.onChange(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Subtitle> subtitles =
        Provider.of<SubtitleState>(context).subtitles ?? [];
    numSubs = subtitles.length;

    return ValueListenableBuilder<int>(
      valueListenable: csIndex,
      builder: (context, sub, _) {
        return PageView.custom(
          controller: _controller,
          scrollDirection: Axis.vertical,
          onPageChanged: onPageChanged,
          childrenDelegate: SliverChildBuilderDelegate(
            (context, i) {
              if (i < offset) return Container();
              return SubtitleDisplay(
                subtitles[i - offset],
                blur: widget.blurPreview ? i > sub + offset : false,
                current: i == sub + offset,
              );
            },
            childCount: subtitles.length + offset,
          ),
        );
      },
    );
  }
}
