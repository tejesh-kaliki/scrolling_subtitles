import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:scrolling_subtitles/states/audio_state.dart';
import 'package:scrolling_subtitles/states/image_state.dart';
import 'package:scrolling_subtitles/states/options_state.dart';
import 'package:scrolling_subtitles/states/subtitle_state.dart';
import 'package:scrolling_subtitles/states/colors_state.dart';
import 'package:scrolling_subtitles/widgets/subtitle_display.dart';
import 'package:scrolling_subtitles/widgets/subtitle_highlight.dart';
import 'package:scrolling_subtitles/widgets/subtitle_list_view.dart';
import 'package:scrolling_subtitles/widgets/subtitle_painter.dart';
import 'package:subtitle/subtitle.dart';
import 'package:window_manager/window_manager.dart';

import 'extensions.dart';
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
          const SingleActivator(LogicalKeyboardKey.keyC): LoadColorsIntent(),
        },
        actions: {
          PausePlayIntent: CallbackAction(
              onInvoke: (e) => audioActionInvoke(PausePlayIntent)),
          ForwardIntent:
              CallbackAction(onInvoke: (e) => audioActionInvoke(ForwardIntent)),
          RewindIntent:
              CallbackAction(onInvoke: (e) => audioActionInvoke(RewindIntent)),
          FitWindowToCanvasIntent: CallbackAction(onInvoke: (e) => fitWindow()),
          LoadColorsIntent:
              CallbackAction(onInvoke: (e) => loadCharacterColors()),
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
            const VideoSection(),
            Visibility(
              visible: !showJustVideo,
              child: const Expanded(child: OptionsPanel()),
            ),
          ],
        ),
      ),
    );
  }

  Widget displayAudioPlaybackOptions() {
    return Consumer<AudioState>(builder: (context, audio, _) {
      bool audioLoaded = audio.isLoaded;

      return Column(
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
      await windowManager.setSize(const Size(1280, 720));
      setState(() => showJustVideo = false);
    }
  }

  void loadCharacterColors() {
    ColorsState colorsState = Provider.of<ColorsState>(context, listen: false);
    SubtitleState subtitleState =
        Provider.of<SubtitleState>(context, listen: false);
    colorsState.loadColors(subtitleState.characters);
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

class VideoSection extends StatefulWidget {
  const VideoSection({super.key});

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  late ValueNotifier<Subtitle?> subValue = ValueNotifier(null);

  // TODO: Make user select subtitle display position
  int subsPerPage = 7;
  double subPosition = 4;

  /// Denotes the current background sub.
  /// null means that no background sub will be displayed.
  ValueNotifier<Subtitle?> bgSubValue = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    Provider.of<AudioState>(context, listen: false)
        .positionStream
        .listen(checkForBackgroundSub);
  }

  void checkForBackgroundSub(Duration position) {
    List<Subtitle> backgroundSubs =
        Provider.of<SubtitleState>(context, listen: false).backgroundSubs ?? [];
    Duration subtitleDelay =
        Provider.of<OptionsState>(context, listen: false).subtitleDelay;
    // Duration playerPos = state.position ?? Duration.zero;

    Subtitle? cSub = bgSubValue.value;
    if (cSub != null && cSub.start < position && cSub.end > position) return;

    Subtitle? finalSub;
    for (Subtitle s in backgroundSubs) {
      Duration start = s.start - subtitleDelay;
      Duration end = s.end + subtitleDelay;

      if (start < position && position < end) finalSub = s;
    }

    if (cSub != finalSub) bgSubValue.value = finalSub;
  }

  @override
  Widget build(BuildContext context) {
    subsPerPage = 8;
    subPosition = 5.5;

    ImageState imState = context.watch<ImageState>();
    AudioState audioState = context.watch<AudioState>();
    List<Subtitle>? subtitles =
        context.select<SubtitleState, List<Subtitle>?>((s) => s.subtitles);
    Duration subtitleDelay =
        context.select<OptionsState, Duration>((s) => s.subtitleDelay);

    Size imageSize = imState.imageSize;
    double subWidth = imageSize.width * 4 / 5;
    Duration subStartTime = const Duration(days: 999);
    if (subtitles != null && subtitles.isNotEmpty) {
      subStartTime = subtitles.first.start;
      subValue.value ??= subtitles.first;
    }

    return AspectRatio(
      aspectRatio: imageSize.aspectRatio,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          height: imageSize.height,
          width: imageSize.width,
          child: StreamBuilder<Duration>(
            stream: audioState.positionStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return displayImage(imState.image);

              Duration playerPos = snapshot.data!;
              Duration offset = playerPos - subStartTime;

              bool overlay =
                  offset > -subtitleDelay - const Duration(milliseconds: 500);
              bool showSubs = offset > -subtitleDelay;

              return Stack(
                alignment: Alignment.center,
                children: [
                  displayImage(imState.image),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: overlay ? 1.0 : 0.0,
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: showSubtitleHighlight(imageSize.height, subWidth),
                    ),
                  ),
                  Opacity(
                    opacity: showSubs ? 1 : 0,
                    child: SizedBox(
                      width: subWidth,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SubtitleListView(
                          onChange: onSubtitleChange,
                          blurPreview: true,
                          totalDivs: subsPerPage,
                          offset: subPosition.round() -
                              ((subsPerPage + 1) / 2).round() +
                              1,
                        ),
                      ),
                    ),
                  ),
                  showBackgroundSub(imageSize.height, subWidth),
                  displayPositon(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget displayImage(File? image) {
    if (image == null) {
      return const Center(
        child: Icon(
          Icons.add_photo_alternate_rounded,
          size: 300,
          color: Colors.grey,
        ),
      );
    }
    return Image.file(image);
  }

  void onSubtitleChange(int index) {
    Subtitle currentSub =
        Provider.of<SubtitleState>(context, listen: false).subtitles![index];
    subValue.value = currentSub;
  }

  Widget showSubtitleHighlight(double imageHeight, double subWidth) {
    return setPosAndHeight(
      pos: subPosition,
      subsPerPage: subsPerPage,
      child: ValueListenableBuilder<Subtitle?>(
        valueListenable: subValue,
        builder: (context, subtitle, child) {
          double height = imageHeight / subsPerPage;
          double subHeight = SubtitlePainter.getTextDisplayHeight(
            subtitle!.textWithoutSpeaker,
            subWidth - 40,
          );

          double highlightHeight = max(height * 0.8, subHeight + 35);

          return SubtitleHighlight(
            subtitle: subtitle,
            height: highlightHeight,
            maxHeight: height,
          );
        },
      ),
    );
  }

  Widget showBackgroundSub(double imageHeight, double subWidth) {
    return ValueListenableBuilder<Subtitle?>(
      valueListenable: bgSubValue,
      builder: (context, subtitle, child) {
        if (subtitle == null) return Container();

        double height = imageHeight / subsPerPage;
        double subHeight = SubtitlePainter.getTextDisplayHeight(
          subtitle.textWithoutSpeaker,
          subWidth - 40,
        );

        double highlightHeight = max(height * 0.8, subHeight + 35);

        return setPosAndHeight(
          pos: subPosition + 1,
          subsPerPage: subsPerPage,
          child: Transform.scale(
            scale: 0.85,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SubtitleHighlight(
                  subtitle: subtitle,
                  height: highlightHeight,
                  maxHeight: height,
                ),
                FractionallySizedBox(
                  widthFactor: 4 / 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SubtitleDisplay(subtitle, current: true),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Sets the position and height of the subtitle highlight.
  ///
  /// subsPerPage: the number of divisions in the entire page vertically.
  /// pos: position of the highlight or subtitle, based on number of divisions.
  Widget setPosAndHeight(
      {required Widget child, required double pos, required int subsPerPage}) {
    FractionalOffset offset = FractionalOffset(0, pos / (subsPerPage - 1));
    return Align(
      alignment: offset,
      child: FractionallySizedBox(heightFactor: 1 / subsPerPage, child: child),
    );
  }

  Widget displayPositon() {
    AudioState state = Provider.of<AudioState>(context, listen: false);
    return Positioned(
      right: 15,
      top: 15,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.amber.shade200,
          border: Border.all(
            color: Colors.amber,
            width: 2,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: StreamBuilder<Duration>(
          stream: state.durationStream,
          builder: (context, dSnapshot) {
            String duration = dSnapshot.data?.toString().substring(0, 7) ?? "-";
            return StreamBuilder<Duration>(
              stream: Provider.of<AudioState>(context, listen: false)
                  .positionStream,
              builder: (context, pSnapshot) {
                Duration? pos = pSnapshot.data;
                String position = pos?.toString().substring(0, 7) ?? "-";
                return Text(
                  "$position / $duration",
                  style: GoogleFonts.acme(color: Colors.black, fontSize: 18),
                  textAlign: TextAlign.center,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
