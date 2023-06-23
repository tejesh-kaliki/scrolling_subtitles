import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:blur/blur.dart';
import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:subtitle/subtitle.dart';
import 'package:dart_vlc/dart_vlc.dart';

import 'extensions.dart';
import 'options.dart';
import 'utils.dart';
import 'state_management.dart';

void main() async {
  DartVLC.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ImageState()),
        ChangeNotifierProvider(create: (context) => SubtitleState()),
        ChangeNotifierProvider(create: (context) => AudioState()),
      ],
      child: MaterialApp(
        title: 'Scrolling Subtitles',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
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
  @override
  void initState() {
    super.initState();
    CharacterColors().loadDefault();
  }

  // Future<void> parseSubs(String subPath) async {
  //   SubtitleProvider subtitleProvider = SubtitleProvider.fromFile(
  //     File(subPath),
  //     type: SubtitleType.vtt,
  //   );
  //   SubtitleObject subtitleObject = await subtitleProvider.getSubtitle();
  //   SubtitleParser parser = SubtitleParser(subtitleObject);

  //   subtitles = List<Subtitle>.empty(growable: true);
  //   backgroundSubs = List<Subtitle>.empty(growable: true);
  //   parser.parsing().forEach((element) {
  //     if (element.isBackgroundSub) {
  //       backgroundSubs!.add(element);
  //     } else {
  //       subtitles!.add(element);
  //     }
  //   });

  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    File? image = context.select((ImageState s) => s.image);

    return Scaffold(
      body: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          displayAudioPlaybackOptions(),
          image == null
              ? const AspectRatio(
                  aspectRatio: 1,
                  child: Center(
                    child: Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 300,
                      color: Colors.grey,
                    ),
                  ),
                )
              : const VideoSection(),
          const Expanded(child: OptionsPanel()),
        ],
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
}

class VideoSection extends StatefulWidget {
  const VideoSection({
    super.key,
  });

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  late ValueNotifier<String> charValue = ValueNotifier("none");
  CharacterColors charColors = CharacterColors();
  // TODO: Make user select subtitle display position
  int subsPerPage = 9;
  double subPosition = 6;

  /// Denotes the index of the current background sub.
  /// -1 means that no background sub will be displayed.
  ValueNotifier<Subtitle?> bgSubValue = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    Provider.of<AudioState>(context, listen: false)
        .positionStream
        .listen(checkForBackgroundSub);
  }

  void checkForBackgroundSub(PositionState state) {
    List<Subtitle> backgroundSubs =
        Provider.of<SubtitleState>(context, listen: false).backgroundSubs ?? [];
    Duration playerPos = state.position ?? Duration.zero;

    if (bgSubValue.value != null) {
      Duration start = bgSubValue.value!.start;
      Duration end = bgSubValue.value!.end;
      if (start < playerPos && end > playerPos) return;
    }

    int bgSub = -1;
    for (int i = 0; i < backgroundSubs.length; i++) {
      Subtitle subtitle = backgroundSubs[i];
      Duration start = subtitle.start - const Duration(milliseconds: 500);
      Duration end = subtitle.end + const Duration(milliseconds: 500);

      if (start < playerPos && playerPos < end) bgSub = i;
    }

    Subtitle? newSub = bgSub != -1 ? backgroundSubs[bgSub] : null;
    if (newSub != bgSubValue.value) {
      bgSubValue.value = newSub;
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageState imState = context.watch<ImageState>();
    AudioState audioState = context.watch<AudioState>();
    SubtitleState subtitleState = context.watch<SubtitleState>();

    Size imageSize = imState.imageSize;
    double subWidth = imageSize.width * 4 / 5;
    Duration subStartTime =
        subtitleState.subtitles?.first.start ?? Duration.zero;

    return AspectRatio(
      aspectRatio: imageSize.aspectRatio,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          height: imageSize.height,
          width: imageSize.width,
          child: StreamBuilder<PositionState>(
            stream: audioState.positionStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Image.file(imState.image!);

              Duration playerPos = snapshot.data!.position ?? Duration.zero;
              Duration offset = playerPos - subStartTime;

              bool overlay = offset > -const Duration(seconds: 1);
              bool showSubs = offset > -const Duration(milliseconds: 500);

              return Stack(
                alignment: Alignment.center,
                children: [
                  Image.file(imState.image!),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: overlay ? 1.0 : 0.0,
                    child: Container(
                      color: Colors.black.withOpacity(0.6),
                      child: showSubtitleHighlight(imageSize),
                    ),
                  ),
                  if (showSubs)
                    SizedBox(
                      width: subWidth,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SubtitleListView(
                          onChange: onSubtitleChange,
                          blurPreview: true,
                          totalDivs: subsPerPage,
                          width: subWidth,
                          offset: subPosition.round() -
                              ((subsPerPage + 1) / 2).round() +
                              1,
                        ),
                      ),
                    ),
                  showBackgroundSub(imageSize),
                  displayPositon(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void onSubtitleChange(int index) {
    Subtitle currentSub =
        Provider.of<SubtitleState>(context, listen: false).subtitles![index];
    charValue.value = currentSub.character;
  }

  Widget showSubtitleHighlight(Size imageSize) {
    return setPosAndHeight(
      pos: subPosition,
      subsPerPage: subsPerPage,
      child: ValueListenableBuilder<String>(
        valueListenable: charValue,
        builder: (context, character, child) {
          double height = imageSize.height / subsPerPage;

          return SubtitleHighlight(
            character: character,
            height: height * 0.8,
            maxHeight: height,
          );
        },
      ),
    );
  }

  Widget showBackgroundSub(Size imageSize) {
    return ValueListenableBuilder<Subtitle?>(
      valueListenable: bgSubValue,
      builder: (context, subtitle, child) {
        if (subtitle == null) return Container();

        double height = imageSize.height / subsPerPage;
        String character = subtitle.character;

        return setPosAndHeight(
          pos: (subPosition + subsPerPage - 1) / 2,
          subsPerPage: subsPerPage,
          child: Transform.scale(
            scale: 0.85,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SubtitleHighlight(
                  character: character,
                  height: height * 0.8,
                  maxHeight: height,
                ),
                FractionallySizedBox(
                  widthFactor: 4 / 5,
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
          stream:
              Provider.of<AudioState>(context, listen: false).positionStream,
          builder: (context, snapshot) {
            PositionState? state = snapshot.data;
            String position = state?.position.toString().substring(0, 7) ?? "-";
            String duration = state?.duration.toString().substring(0, 7) ?? "-";
            return Text(
              "$position / $duration",
              style: GoogleFonts.acme(color: Colors.black, fontSize: 18),
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
    this.maxHeight = double.infinity,
  });

  final String character;
  final double height;
  final double maxHeight;
  final CharacterColors charColors = CharacterColors();

  @override
  Widget build(BuildContext context) {
    Color color = charColors.of(character);

    return Row(
      children: [
        Flexible(fit: FlexFit.tight, child: SubtitlePointer(color: color)),
        Flexible(
          flex: 8,
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
                child: Container(height: min(height, maxHeight)),
              ),
              Transform.translate(
                offset: Offset(10, -height / 2),
                child: CharacterName(character: character),
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
    this.blurPreview = false,
    this.totalDivs = 7,
    this.offset = 1,
    this.width = double.infinity,
  });

  final void Function(int index) onChange;
  final bool blurPreview;
  final int totalDivs;
  final int offset;
  final double width;

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

  void onPositionChange(PositionState state) {
    List<Subtitle>? subtitles =
        Provider.of<SubtitleState>(context, listen: false).subtitles;
    if (state.position == null || subtitles == null) return;
    int i = csIndex.value;
    Subtitle sub = subtitles[i];
    Duration position = state.position! + const Duration(milliseconds: 500);
    if (position > state.duration!) position = state.duration!;
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
      onPageChanged(i);
      _controller.animateToPage(
        i,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
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
                subtitles[i - offset].parsedData,
                character: subtitles[i - offset].character,
                blur: widget.blurPreview ? i > sub + offset : false,
                current: i == sub + offset,
                width: widget.width,
              );
            },
            childCount: subtitles.length + offset,
          ),
        );
      },
    );
  }
}

class SubtitleDisplay extends StatefulWidget {
  final String text;
  final String char;
  final bool blur;
  final bool current;
  final double width;

  const SubtitleDisplay(
    this.text, {
    super.key,
    String? character,
    this.blur = false,
    this.current = false,
    this.width = double.infinity,
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

    if (color.getLightness() < 0.625) color = color.withLightness(0.625);

    double textScale = 1.0;
    if (widget.text.length > 100) {
      textScale = getTextScale(context);
    }

    Widget child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
            fontSize: 23,
          ),
        ),
        child: BorderedText(
          strokeWidth: 5,
          strokeJoin: StrokeJoin.round,
          strokeColor: Colors.black,
          child: Text(
            widget.text,
            textScaleFactor: textScale,
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

  double getTextScale(BuildContext context) {
    TextStyle textStyle = GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        letterSpacing: 1,
        fontSize: 18,
      ),
    );
    ui.ParagraphConstraints constraints =
        ui.ParagraphConstraints(width: widget.width - 110);

    ui.ParagraphBuilder pb =
        ui.ParagraphBuilder(textStyle.getParagraphStyle(maxLines: 2))
          ..addText(widget.text);
    ui.Paragraph paragraph = pb.build()..layout(constraints);

    return paragraph.didExceedMaxLines ? 0.75 : 1.0;
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
    if (color.getLightness() < 0.625) {
      color = color.withLightness(0.625);
    } else if (color.getLightness() > 0.94) {
      color = color.withLightness(0.94);
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
