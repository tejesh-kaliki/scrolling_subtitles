import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show
        ConsumerStatefulWidget,
        ConsumerState,
        ProviderScope,
        ProviderContainer;
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:scrolling_subtitles/services/video_export_service.dart';
import 'package:scrolling_subtitles/states/audio_state.dart';
import 'package:scrolling_subtitles/states/colors_state.dart';
import 'package:scrolling_subtitles/states/image_state.dart';
import 'package:scrolling_subtitles/widgets/video_section/video_section.dart';
import 'package:window_manager/window_manager.dart';

import 'intents.dart';
import 'options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  MediaKit.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ImageState()),
          ChangeNotifierProvider(create: (context) => AudioState()),
          ChangeNotifierProvider(create: (context) => ColorsState()),
        ],
        child: MaterialApp(
          title: 'Scrolling Subtitles',
          theme: ThemeData(
            primarySwatch: Colors.teal,
          ),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: const MyHomePage(),
        ),
      ),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});
  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  FocusNode mainFocusNode = FocusNode();
  bool showJustVideo = false;
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FocusableActionDetector(
        autofocus: true,
        focusNode: mainFocusNode,
        shortcuts: {
          const SingleActivator(LogicalKeyboardKey.space): PausePlayIntent(),
          const SingleActivator(LogicalKeyboardKey.arrowRight): ForwardIntent(),
          const SingleActivator(LogicalKeyboardKey.arrowLeft): RewindIntent(),
          const SingleActivator(LogicalKeyboardKey.keyF):
              FitWindowToCanvasIntent(),
          const SingleActivator(LogicalKeyboardKey.f11): FullScreenIntent(),
        },
        actions: {
          PausePlayIntent: CallbackAction(
              onInvoke: (e) => audioActionInvoke(PausePlayIntent)),
          ForwardIntent:
              CallbackAction(onInvoke: (e) => audioActionInvoke(ForwardIntent)),
          RewindIntent:
              CallbackAction(onInvoke: (e) => audioActionInvoke(RewindIntent)),
          FitWindowToCanvasIntent: CallbackAction(onInvoke: (e) => fitWindow()),
          FullScreenIntent: CallbackAction(onInvoke: (e) => fullScreen()),
        },
        onFocusChange: (v) {
          if (!mainFocusNode.hasFocus) {
            mainFocusNode.requestFocus();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: !showJustVideo,
              child: displayAudioPlaybackOptions(),
            ),
            const Expanded(child: VideoSection()),
            Visibility(visible: !showJustVideo, child: const OptionsPanel()),
          ],
        ),
      ),
    );
  }

  Widget displayAudioPlaybackOptions() {
    return Consumer<AudioState>(builder: (context, audio, _) {
      bool audioLoaded = audio.isLoaded;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: audioLoaded ? audio.togglePlayPause : null,
            icon: audio.isPlaying
                ? const Icon(Icons.pause_rounded)
                : const Icon(Icons.play_arrow_rounded),
          ),
          IconButton(
            onPressed:
                audioLoaded ? () => audio.seekToPos(Duration.zero) : null,
            icon: const Icon(Icons.fast_rewind_rounded),
          ),
          IconButton(
            onPressed: audioLoaded ? audio.forward10s : null,
            icon: const Icon(Icons.forward_10_rounded),
          ),
          IconButton(
            onPressed: audioLoaded ? audio.rewind10s : null,
            icon: const Icon(Icons.replay_10_rounded),
          ),
          const SizedBox(height: 16),
          IconButton(
            tooltip: 'Export first 5 min as video',
            onPressed: _startExport,
            icon: const Icon(Icons.video_file_rounded),
          ),
        ],
      );
    });
  }

  Future<void> _startExport() async {
    final outputPath = await FilePicker.saveFile(
      dialogTitle: 'Save exported video',
      fileName: 'export.mp4',
      type: FileType.video,
    );
    if (outputPath == null) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ExportDialog(
        outputPath: outputPath,
        exportContext: context,
        container: ProviderScope.containerOf(context),
      ),
    );
  }

  void fitWindow() async {
    if (!showJustVideo) {
      setState(() => showJustVideo = true);
      Size size = Provider.of<ImageState>(context, listen: false).imageSize;
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      await windowManager.setSize(Size(size.width + 4, size.height));
    } else {
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      await windowManager.maximize();
      setState(() => showJustVideo = false);
    }
  }

  void fullScreen() async {
    if (!isFullScreen) {
      await windowManager.setFullScreen(true);
      setState(() => isFullScreen = true);
    } else {
      await windowManager.setFullScreen(false);
      setState(() => isFullScreen = false);
    }
  }

  bool audioActionInvoke(Type intent) {
    if (FocusManager.instance.primaryFocus == mainFocusNode) {
      AudioState audio = Provider.of<AudioState>(context, listen: false);
      if (audio.isLoaded) {
        switch (intent) {
          case const (PausePlayIntent):
            audio.togglePlayPause();
            break;
          case const (ForwardIntent):
            audio.forward10s();
            break;
          case const (RewindIntent):
            audio.rewind10s();
            break;
          default:
            return false;
        }
        return true;
      }
    }
    return false;
  }
}

class _ExportDialog extends StatefulWidget {
  final String outputPath;
  final BuildContext exportContext;
  final ProviderContainer container;

  const _ExportDialog({
    required this.outputPath,
    required this.exportContext,
    required this.container,
  });

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  int captureFrame = 0;
  int totalFrames = 0;
  int encodingFrame = 0;
  bool done = false;
  String? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runExport());
  }

  void _runExport() {
    final service = VideoExportService(
      context: widget.exportContext,
      parentContainer: widget.container,
    );
    service
        .exportVideo(
      outputPath: widget.outputPath,
      duration: const Duration(minutes: 5),
      onProgress: (_, frame, total) {
        if (mounted) setState(() { captureFrame = frame; totalFrames = total; });
      },
      onEncodingProgress: (frame, _) {
        if (mounted) setState(() => encodingFrame = frame);
      },
    )
        .then((_) {
      if (mounted) setState(() => done = true);
    }).catchError((e) {
      if (mounted) setState(() => error = e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(done
          ? 'Export complete'
          : error != null
              ? 'Export failed'
              : 'Exporting video...'),
      content: done
          ? Text('Saved to ${widget.outputPath}')
          : error != null
              ? Text(error!)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Capturing')),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: totalFrames > 0 ? captureFrame / totalFrames : null,
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(totalFrames > 0
                          ? '$captureFrame / $totalFrames'
                          : 'Starting...'),
                    ),
                    const SizedBox(height: 12),
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Encoding')),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: totalFrames > 0 ? encodingFrame / totalFrames : null,
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(totalFrames > 0
                          ? '$encodingFrame / $totalFrames'
                          : '—'),
                    ),
                  ],
                ),
      actions: (done || error != null)
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ]
          : null,
    );
  }
}
