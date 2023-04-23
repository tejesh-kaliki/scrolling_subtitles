import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:blur/blur.dart';
import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:subtitle/subtitle.dart';
import 'package:dart_vlc/dart_vlc.dart';

import 'extensions.dart';
import 'options.dart';
import 'utils.dart';

void main() async {
  DartVLC.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrolling Subtitles',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? imageFile;
  Size imageSize = const Size.square(1080);
  List<Subtitle>? subtitles;
  List<Subtitle>? backgroundSubs;
  Player player = Player(id: 69420, commandlineArguments: ["--no-video"]);
  bool audioLoaded = false;
  bool paused = true;

  @override
  void initState() {
    super.initState();
    CharacterColors().loadDefault();
    // loadAllFiles();
  }

  Future<Size> getImageSize(File image) async {
    ui.Image image = await decodeImageFromList(await imageFile!.readAsBytes());
    return Size(image.width / 1.0, image.height / 1.0);
  }

  Future<void> parseSubs(String subPath) async {
    SubtitleProvider subtitleProvider = SubtitleProvider.fromFile(
      File(subPath),
      type: SubtitleType.vtt,
    );
    SubtitleObject subtitleObject = await subtitleProvider.getSubtitle();
    SubtitleParser parser = SubtitleParser(subtitleObject);

    subtitles = List<Subtitle>.empty(growable: true);
    backgroundSubs = List<Subtitle>.empty(growable: true);
    parser.parsing().forEach((element) {
      if (element.isBackgroundSub) {
        backgroundSubs!.add(element);
      } else {
        subtitles!.add(element);
      }
    });

    setState(() {});
  }

  void loadAudio(String audioPath) {
    File audioFile = File(audioPath);
    player.open(Media.file(audioFile), autoStart: false);
    setState(() => audioLoaded = true);
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        displayAudioPlaybackOptions(),
        if (imageFile == null)
          const AspectRatio(
            aspectRatio: 1,
            child: Center(
              child: Icon(
                Icons.add_photo_alternate_rounded,
                size: 300,
                color: Colors.grey,
              ),
            ),
          ),
        if (imageFile != null)
          VideoSection(
            imageFile: imageFile!,
            imageSize: imageSize,
            player: player,
            subtitles: subtitles,
            backgroundSubs: backgroundSubs,
            subStartTime: subtitles?.first.start,
          ),
        Expanded(
          child: OptionsPanel(
            onImageChanged: (String filepath) async {
              imageFile = File(filepath);
              Size size = await getImageSize(imageFile!);
              setState(() => imageSize = size);
            },
            onSubtitleChanged: (subPath) async => await parseSubs(subPath),
            onAudioChanged: (audioPath) async => loadAudio(audioPath),
            seekToPos: seekToPos,
          ),
        ),
      ],
    );
    return Scaffold(body: body);
  }

  Column displayAudioPlaybackOptions() {
    return Column(
      children: [
        IconButton(
          onPressed: audioLoaded ? playOrPauseAudio : null,
          icon: paused
              ? const Icon(Icons.play_arrow_rounded)
              : const Icon(Icons.pause_rounded),
        ),
        IconButton(
          onPressed: audioLoaded ? () => seekToPos(Duration.zero) : null,
          icon: const Icon(Icons.fast_rewind_rounded),
        ),
        IconButton(
          onPressed: audioLoaded ? forwardAudio10s : null,
          icon: const Icon(Icons.forward_10_rounded),
        ),
        IconButton(
          onPressed: audioLoaded ? rewindAudio10s : null,
          icon: const Icon(Icons.replay_10_rounded),
        ),
      ],
    );
  }

  void rewindAudio10s() {
    Duration fpos = (player.position.position ?? Duration.zero) -
        const Duration(seconds: 10);
    seekToPos(fpos);
  }

  void forwardAudio10s() {
    Duration fpos = (player.position.position ?? Duration.zero) +
        const Duration(seconds: 10);
    seekToPos(fpos);
  }

  void seekToPos(Duration pos) {
    Duration total = player.position.duration ?? Duration.zero;
    if (pos < Duration.zero) pos = Duration.zero;
    if (pos > total) pos = total;
    player.seek(pos);
    player.positionController.add(player.position..position = pos);
  }

  void playOrPauseAudio() {
    player.playOrPause();
    setState(() => paused = !paused);
  }
}

class VideoSection extends StatefulWidget {
  const VideoSection({
    super.key,
    required this.imageFile,
    required this.imageSize,
    required this.player,
    this.subtitles,
    this.backgroundSubs,
    this.subStartTime,
  });

  final File imageFile;
  final Size imageSize;
  final Player player;
  final List<Subtitle>? subtitles;
  final List<Subtitle>? backgroundSubs;
  final Duration? subStartTime;

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  ValueNotifier<String> charValue = ValueNotifier("none");
  CharacterColors charColors = CharacterColors();
  // TODO: Make user select subtitle position
  int subsPerPage = 9;
  double subPosition = 6;
  bool showSubs = false;
  bool overlay = false;

  /// Denotes the index of the current background sub.
  /// -1 means that no background sub will be displayed.
  ValueNotifier<Subtitle?> bgSubValue = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    widget.player.positionStream.listen((e) {
      if (widget.subStartTime == null) return;

      Duration playerPos = e.position ?? Duration.zero;

      toggleSubtitleDisplay(playerPos);

      checkForBackgroundSub(playerPos);
    });
  }

  void toggleSubtitleDisplay(Duration playerPos) {
    Duration subVisibleTime = widget.subStartTime! - const Duration(seconds: 1);
    if (playerPos >= subVisibleTime && !overlay) {
      setState(() => overlay = true);
      Future.delayed(const Duration(milliseconds: 400), () {
        charValue.value = widget.subtitles!.first.character;
        setState(() => showSubs = true);
      });
    } else if (playerPos < subVisibleTime && overlay) {
      setState(() => overlay = showSubs = false);
    }
  }

  void checkForBackgroundSub(Duration playerPos) {
    int bgSub = -1;
    widget.backgroundSubs?.forEach((subtitle) {
      Duration start = subtitle.start - const Duration(milliseconds: 500);
      Duration end = subtitle.end + const Duration(milliseconds: 500);

      if (start < playerPos && playerPos < end) {
        bgSub = widget.backgroundSubs!.indexOf(subtitle);
      }
    });

    Subtitle? newSub = bgSub != -1 ? widget.backgroundSubs![bgSub] : null;
    if (newSub != bgSubValue.value) {
      bgSubValue.value = newSub;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.imageSize.width / widget.imageSize.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.file(widget.imageFile),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: overlay ? 1.0 : 0.0,
            child: Container(
              color: Colors.black.withOpacity(0.6),
              child: showSubtitleHighlight(),
            ),
          ),
          if (showSubs)
            FractionallySizedBox(
              widthFactor: 3 / 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SubtitleListView(
                  onChange: (c) {
                    charValue.value = c;
                  },
                  subtitles: widget.subtitles ?? [],
                  positionStream: widget.player.positionStream,
                  blurPreview: true,
                  totalDivs: subsPerPage,
                  offset:
                      subPosition.round() - ((subsPerPage + 1) / 2).round() + 1,
                ),
              ),
            ),
          if (bgSubValue != -1) showBackgroundSub(),
          displayPositon(),
        ],
      ),
    );
  }

  Widget showSubtitleHighlight() {
    return setPosAndHeight(
      pos: subPosition,
      subsPerPage: subsPerPage,
      child: ValueListenableBuilder<String>(
        valueListenable: charValue,
        builder: (context, character, child) {
          double height = MediaQuery.of(context).size.height;

          return SubtitleHighlight(
            character: character,
            height: min(height, 80),
          );
        },
      ),
    );
  }

  Widget showBackgroundSub() {
    return ValueListenableBuilder<Subtitle?>(
      valueListenable: bgSubValue,
      builder: (context, subtitle, child) {
        if (subtitle == null) return Container();

        double height = MediaQuery.of(context).size.height;
        String character = subtitle.character;

        return setPosAndHeight(
          pos: (subPosition + subsPerPage - 1) / 2,
          subsPerPage: subsPerPage,
          child: Transform.scale(
            scale: 0.7,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SubtitleHighlight(
                  character: character,
                  height: min(height, 80),
                ),
                FractionallySizedBox(
                  widthFactor: 3 / 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SubtitleDisplay(subtitle.parsedData, current: true),
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
        child: StreamBuilder<PositionState>(
          stream: widget.player.positionStream,
          builder: (context, snapshot) {
            PositionState? state = snapshot.data;
            String position = state?.position.toString().substring(0, 7) ?? "-";
            String duration = state?.duration.toString().substring(0, 7) ?? "-";
            return Text(
              "$position / $duration",
              style: GoogleFonts.acme(color: Colors.black),
              textAlign: TextAlign.center,
            );
          },
        ),
      ),
    );
  }
}

class SubtitleHighlight extends StatelessWidget {
  SubtitleHighlight({
    super.key,
    required this.character,
    this.height = 80.0,
  });

  final String character;
  final double height;
  final CharacterColors charColors = CharacterColors();

  @override
  Widget build(BuildContext context) {
    Color color = charColors.of(character);

    return Row(
      children: [
        Flexible(fit: FlexFit.tight, child: SubtitlePointer(color: color)),
        Flexible(
          flex: 6,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Blur(
                borderRadius: BorderRadius.circular(20),
                blur: 10,
                colorOpacity: 0,
                blurColor: color,
                overlay: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color, width: 3),
                    color: color.withOpacity(0.3),
                  ),
                ),
                child: Container(height: 80),
              ),
              Transform.translate(
                offset: Offset(10, -height / 2),
                child: CharacterName(
                  character: character,
                ),
              ),
            ],
          ),
        ),
        Flexible(child: Container()),
      ],
    );
  }
}

class CharacterName extends StatefulWidget {
  const CharacterName({
    super.key,
    required this.character,
  });

  final String character;

  @override
  State<CharacterName> createState() => _CharacterNameState();
}

class _CharacterNameState extends State<CharacterName> {
  CharacterColors charColor = CharacterColors();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.character == "none") return Container();

    Color color = charColor.of(widget.character);
    return AnimatedContainer(
      key: const ValueKey<String>("Character Name"),
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.white70,
          width: 2,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: GoogleFonts.acme(
            color:
                color.computeLuminance() < 0.3 ? Colors.white : Colors.black),
        child: Text(
          widget.character.toUpperCase(),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class SubtitleListView extends StatefulWidget {
  const SubtitleListView({
    super.key,
    required this.onChange,
    required this.subtitles,
    required this.positionStream,
    this.blurPreview = false,
    this.totalDivs = 7,
    this.offset = 1,
  });

  final void Function(String character) onChange;
  final List<Subtitle> subtitles;
  final Stream<PositionState> positionStream;
  final bool blurPreview;
  final int totalDivs;
  final int offset;

  @override
  State<SubtitleListView> createState() => _SubtitleListViewState();
}

class _SubtitleListViewState extends State<SubtitleListView> {
  int currentSub = 0;

  late PageController _controller;
  late int offset;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 1 / widget.totalDivs);
    widget.positionStream.listen(onPositionChange);
    offset = widget.offset;
  }

  void onPositionChange(PositionState state) {
    if (state.position == null) return;
    int i = currentSub;
    Subtitle sub = widget.subtitles[i];
    Duration position = state.position! + const Duration(milliseconds: 500);
    if (position > state.duration!) position = state.duration!;
    if (position > sub.start && position <= sub.end) return;

    if (position > sub.end) {
      do {
        i++;
      } while (
          i < widget.subtitles.length && widget.subtitles[i].start < position);
      i--;
    } else if (position < sub.start) {
      do {
        i--;
      } while (i >= 0 && widget.subtitles[i].end > position);
      i++;
    }
    if (currentSub != i) {
      onPageChanged(i);
      _controller.animateToPage(
        i,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void onPageChanged(int page) {
    setState(() => currentSub = page);
    if (page < widget.subtitles.length) {
      widget.onChange(widget.subtitles[page].character);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.custom(
      controller: _controller,
      scrollDirection: Axis.vertical,
      onPageChanged: onPageChanged,
      childrenDelegate: SliverChildBuilderDelegate(
        (context, i) {
          return i < offset
              ? Container()
              : SubtitleDisplay(
                  widget.subtitles[i - offset].parsedData,
                  character: widget.subtitles[i - offset].character,
                  blur: widget.blurPreview ? i > currentSub + offset : false,
                  current: i == currentSub + offset,
                );
        },
        childCount: widget.subtitles.length + offset,
      ),
    );
  }
}

class SubtitleDisplay extends StatefulWidget {
  final String text;
  final String char;
  final bool blur;
  final bool current;

  const SubtitleDisplay(
    this.text, {
    super.key,
    String? character,
    this.blur = false,
    this.current = false,
  }) : char = character ?? "none";

  @override
  State<SubtitleDisplay> createState() => _SubtitleDisplayState();
}

class _SubtitleDisplayState extends State<SubtitleDisplay> {
  CharacterColors charColor = CharacterColors();

  @override
  Widget build(BuildContext context) {
    Color color = widget.blur || widget.current
        ? Colors.white
        : charColor.of(widget.char);

    Widget child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
            fontSize: 18,
          ),
        ),
        child: BorderedText(
          strokeWidth: 4,
          strokeJoin: StrokeJoin.round,
          strokeColor: Colors.black,
          child: Text(
            widget.text,
            textAlign: TextAlign.left,
            textWidthBasis: TextWidthBasis.parent,
          ),
        ),
      ),
    );

    if (widget.blur && widget.text.isNotEmpty) {
      child = Blur(
        blurColor: Colors.white,
        blur: 5,
        colorOpacity: 0,
        child: child,
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}

class SubtitlePointer extends StatefulWidget {
  const SubtitlePointer({
    super.key,
    this.color = Colors.white,
  });

  final Color color;

  @override
  State<SubtitlePointer> createState() => _SubtitlePointerState();
}

class _SubtitlePointerState extends State<SubtitlePointer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )
      ..forward()
      ..addListener(() {
        if (_controller.isDismissed) {
          _controller.forward();
        } else if (_controller.isCompleted) {
          _controller.reverse();
        }
      });
    _animation1 = Tween<double>(begin: 0, end: pi).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color color = widget.color;
    HSLColor hslColor = HSLColor.fromColor(color);
    if (hslColor.lightness < 0.625) {
      color = hslColor.withLightness(0.625).toColor();
    } else if (hslColor.lightness > 0.94) {
      color = hslColor.withLightness(0.94).toColor();
    }
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Positioned(
          right: 15,
          child: Transform.translate(
            offset: Offset(sin(_animation1.value) * 10, 0),
            child: Transform.rotate(
              angle: -1 / 2,
              child: Icon(
                CupertinoIcons.triangle,
                color: color,
              ),
            ),
          ),
        ),
        Positioned(
          right: 30,
          child: Transform.translate(
            offset: Offset(sin(_animation1.value) * 15, 0),
            child: Transform.rotate(
              angle: -1 / 2,
              child: Icon(
                CupertinoIcons.triangle_fill,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
