import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrolling_subtitles/providers/subtitle_provider.dart';

import 'subtitle_display.dart';

class SubtitleListView extends ConsumerWidget {
  const SubtitleListView({
    super.key,
    required this.scrollOffset,
    required this.currentIndex,
    required this.onChange,
    required this.subPosition,
    this.blurPreview = false,
    this.totalDivs = 7,
  });

  final void Function(int index) onChange;
  final bool blurPreview;
  final int totalDivs;
  final int currentIndex;
  final double scrollOffset;
  final double subPosition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitles =
        ref.watch(subtitleProvider.select((state) => state.subtitles));

    const buffer = 2;

    final start =
        (currentIndex - buffer - subPosition.ceil()).clamp(0, subtitles.length);
    final end = (currentIndex + totalDivs + buffer - subPosition.ceil())
        .clamp(0, subtitles.length);
    final lineHeight = 1024 / totalDivs;

    final anchorOffset = subPosition * lineHeight;

    return ClipRect(
      child: Stack(
        children: [
          for (int i = start; i < end; i++)
            Positioned(
              top:
                  (i - currentIndex) * lineHeight - scrollOffset + anchorOffset,
              left: 0,
              right: 0,
              height: lineHeight,
              child: SubtitleDisplay(
                subtitles[i],
                current: i == currentIndex,
                blur: blurPreview && i > currentIndex,
              ),
            ),
        ],
      ),
    );
  }
}
