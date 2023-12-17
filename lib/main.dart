import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:scrolling_subtitles/states/audio_state.dart';
import 'package:scrolling_subtitles/states/image_state.dart';
import 'package:scrolling_subtitles/states/options_state.dart';
import 'package:scrolling_subtitles/states/subtitle_state.dart';
import 'package:scrolling_subtitles/states/colors_state.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => OptionsState()),
        ChangeNotifierProvider(create: (context) => ImageState()),
        ChangeNotifierProvider(create: (context) => SubtitleState()),
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
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
        ],
      );
    });
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
