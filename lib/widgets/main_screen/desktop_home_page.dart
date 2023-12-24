// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

// Project imports:
import 'package:visual_subs/intents.dart';
import 'package:visual_subs/options.dart';
import 'package:visual_subs/states/audio_state.dart';
import 'package:visual_subs/states/image_state.dart';
import 'package:visual_subs/widgets/video_section/video_section.dart';

class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({super.key});

  @override
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage> {
  FocusNode mainFocusNode = FocusNode();
  bool showJustVideo = false;
  bool isFullScreen = false;

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
              child: Consumer<AudioState>(builder: _audioOptionsBuilder),
            ),
            const Expanded(child: VideoSection()),
            Visibility(visible: !showJustVideo, child: const OptionsPanel()),
          ],
        ),
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

  Widget _audioOptionsBuilder(
      BuildContext context, AudioState audio, Widget? _) {
    bool audioLoaded = audio.isLoaded;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder(
          stream: audio.playingStream,
          builder: (context, snapshot) {
            if (!audioLoaded || !snapshot.hasData) {
              return const IconButton(
                onPressed: null,
                icon: Icon(Icons.play_arrow_rounded),
              );
            }
            return IconButton(
              onPressed: audio.togglePlayPause,
              icon: snapshot.data!
                  ? const Icon(Icons.pause_rounded)
                  : const Icon(Icons.play_arrow_rounded),
            );
          },
        ),
        IconButton(
          onPressed: audioLoaded ? () => audio.seekToPos(Duration.zero) : null,
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
  }
}
