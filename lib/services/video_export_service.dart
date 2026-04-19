import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:scrolling_subtitles/providers/frame_state_provider.dart'
    show frameState, frameStateProvider;
import 'package:scrolling_subtitles/providers/timeline_provider.dart';
import 'package:scrolling_subtitles/states/colors_state.dart';
import 'package:scrolling_subtitles/states/image_state.dart';
import 'package:scrolling_subtitles/widgets/video_section/export_video_frame.dart';

class VideoExportService {
  static const int fps = 30;

  final BuildContext context;
  final ProviderContainer parentContainer;

  VideoExportService({
    required this.context,
    required this.parentContainer,
  });

  Future<void> exportVideo({
    required String outputPath,
    Duration duration = const Duration(minutes: 1),
    void Function(double progress, int frame, int total)? onProgress,
    void Function(int frame, int total)? onEncodingProgress,
  }) async {
    final exportContainer = ProviderContainer(
      parent: parentContainer,
      overrides: [
        timelineProvider.overrideWith(TimelineNotifier.new),
        // frameStateProvider must also be overridden so it is re-created in
        // this container's scope and watches the child's timelineProvider.
        // Without this, Riverpod uses the parent's instance, which watches
        // the main app timeline — so the export always renders the wrong time.
        frameStateProvider.overrideWith(frameState),
      ],
    );
    final timelineSub = exportContainer.listen(timelineProvider, (_, __) {});

    final imageState = legacy.Provider.of<ImageState>(context, listen: false);
    final colorsState = legacy.Provider.of<ColorsState>(context, listen: false);

    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Transform.translate(
        offset: const Offset(-99999, 0),
        child: UncontrolledProviderScope(
          container: exportContainer,
          child: legacy.MultiProvider(
            providers: [
              legacy.ChangeNotifierProvider<ImageState>.value(
                  value: imageState),
              legacy.ChangeNotifierProvider<ColorsState>.value(
                  value: colorsState),
            ],
            child: ExportVideoFrame(totalDuration: duration),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    await SchedulerBinding.instance.endOfFrame;
    await SchedulerBinding.instance.endOfFrame;

    // Render frame 0 first so we can read the actual pixel dimensions
    // from the ui.Image rather than guessing from float arithmetic.
    // Any mismatch between reported size and actual bytes = noise.
    RenderRepaintBoundary _boundary() {
      final b = ExportVideoFrame.repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (b == null) throw Exception('RepaintBoundary not found');
      return b;
    }

    exportContainer.read(timelineProvider.notifier).setTime(Duration.zero);
    await SchedulerBinding.instance.endOfFrame;

    final probeImage = await _boundary().toImage(pixelRatio: 1.0);
    final frameW = probeImage.width;   // ground-truth pixel width
    final frameH = probeImage.height;  // ground-truth pixel height
    final probeBytes = await probeImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    probeImage.dispose();
    if (probeBytes == null) throw Exception('Failed to read probe frame');

    final encoder = await _pickEncoder();
    final encoderArgs = _encoderArgs(encoder, frameW, frameH);

    final ffmpeg = await Process.start('ffmpeg', [
      '-y',
      '-framerate', '$fps',
      '-f', 'rawvideo',
      '-pix_fmt', 'rgba',
      '-video_size', '${frameW}x$frameH',
      '-i', 'pipe:0',
      ...encoderArgs,
      '-progress', 'pipe:2',
      '-loglevel', 'error',
      outputPath,
    ]);

    final totalFrames = (duration.inMilliseconds * fps / 1000).round();

    final stderrBuf = StringBuffer();
    var stderrRemainder = '';
    ffmpeg.stderr.listen((b) {
      final chunk = String.fromCharCodes(b);
      stderrBuf.write(chunk);
      stderrRemainder += chunk;
      while (stderrRemainder.contains('\n')) {
        final idx = stderrRemainder.indexOf('\n');
        final line = stderrRemainder.substring(0, idx).trim();
        stderrRemainder = stderrRemainder.substring(idx + 1);
        if (line.startsWith('frame=')) {
          final f = int.tryParse(line.substring(6).trim());
          if (f != null) onEncodingProgress?.call(f, totalFrames);
        }
      }
    });

    try {

      // Send frame 0 (already captured above).
      ffmpeg.stdin.add(probeBytes.buffer.asUint8List());
      onProgress?.call(0, 0, totalFrames);

      for (int frame = 1; frame < totalFrames; frame++) {
        final timestamp =
            Duration(microseconds: (frame * 1000000 / fps).round());

        exportContainer.read(timelineProvider.notifier).setTime(timestamp);

        await SchedulerBinding.instance.endOfFrame;

        final image = await _boundary().toImage(pixelRatio: 1.0);
        final byteData =
            await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        image.dispose();
        if (byteData == null) throw Exception('Failed to read frame $frame');

        ffmpeg.stdin.add(byteData.buffer.asUint8List());
        onProgress?.call(frame / totalFrames, frame, totalFrames);
      }

      await ffmpeg.stdin.close();
      final exitCode = await ffmpeg.exitCode;
      if (exitCode != 0) throw Exception('ffmpeg failed:\n$stderrBuf');
    } catch (e) {
      ffmpeg.stdin.close().ignore();
      ffmpeg.kill();
      rethrow;
    } finally {
      timelineSub.close();
      exportContainer.dispose();
      entry.remove();
    }
  }

  /// Returns the best available H.264 encoder name.
  static Future<String> _pickEncoder() async {
    final result = await Process.run('ffmpeg', ['-hide_banner', '-encoders'],
        runInShell: true);
    final out = result.stdout as String;
    for (final candidate in ['h264_nvenc', 'h264_vaapi']) {
      if (out.contains(candidate)) return candidate;
    }
    return 'libx264';
  }

  /// Returns ffmpeg codec args for the given encoder.
  /// [w] and [h] are the actual frame pixel dimensions so we can
  /// pad to even if needed (yuv420p requires even dimensions).
  static List<String> _encoderArgs(String encoder, int w, int h) {
    // scale=trunc(iw/2)*2:trunc(ih/2)*2 pads odd dimensions to even.
    final evenScale = (w.isEven && h.isEven)
        ? <String>[]
        : ['-vf', 'scale=trunc(iw/2)*2:trunc(ih/2)*2'];

    switch (encoder) {
      case 'h264_nvenc':
        return [
          ...evenScale,
          '-c:v', 'h264_nvenc',
          '-preset', 'p4',
          '-rc', 'vbr',
          '-cq', '18',
          '-pix_fmt', 'yuv420p',
        ];
      case 'h264_vaapi':
        return [
          '-vaapi_device', '/dev/dri/renderD128',
          '-vf', 'format=nv12,hwupload${(w.isEven && h.isEven) ? '' : ',scale=trunc(iw/2)*2:trunc(ih/2)*2'}',
          '-c:v', 'h264_vaapi',
          '-qp', '18',
        ];
      default:
        return [
          ...evenScale,
          '-c:v', 'libx264',
          '-crf', '18',
          '-pix_fmt', 'yuv420p',
        ];
    }
  }


}

