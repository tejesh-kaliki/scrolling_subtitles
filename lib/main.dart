import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:blur/blur.dart';
import 'package:bordered_text/bordered_text.dart';
import 'package:dart_casing/dart_casing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:provider/provider.dart';
import 'package:subtitle/subtitle.dart';
import 'package:dart_vlc/dart_vlc.dart';

import 'extensions.dart';
import 'options.dart';
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          displayAudioPlaybackOptions(),
          const VideoSection(),
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

  void checkForBackgroundSub(PositionState state) {
    List<Subtitle> backgroundSubs =
        Provider.of<SubtitleState>(context, listen: false).backgroundSubs ?? [];
    Duration subtitleDelay =
        Provider.of<OptionsState>(context, listen: false).subtitleDelay;
    Duration playerPos = state.position ?? Duration.zero;

    Subtitle? cSub = bgSubValue.value;
    if (cSub != null && cSub.start < playerPos && cSub.end > playerPos) return;

    Subtitle? finalSub;
    for (Subtitle s in backgroundSubs) {
      Duration start = s.start - subtitleDelay;
      Duration end = s.end + subtitleDelay;

      if (start < playerPos && playerPos < end) finalSub = s;
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
          child: StreamBuilder<PositionState>(
            stream: audioState.positionStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return displayImage(imState.image);

              Duration playerPos = snapshot.data!.position ?? Duration.zero;
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
                      child: showSubtitleHighlight(imageSize),
                    ),
                  ),
                  // showPastSubtitleHighlight(imageSize),
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

  Widget showSubtitleHighlight(Size imageSize) {
    return setPosAndHeight(
      pos: subPosition,
      subsPerPage: subsPerPage,
      child: ValueListenableBuilder<Subtitle?>(
        valueListenable: subValue,
        builder: (context, subtitle, child) {
          double height = imageSize.height / subsPerPage;

          return SubtitleHighlight(
            subtitle: subtitle,
            height: height * 0.8,
            maxHeight: height,
          );
        },
      ),
    );
  }

  Widget showPastSubtitleHighlight(Size imageSize) {
    double offsetFromTop =
        subPosition.remainder(1) * imageSize.height / subsPerPage;
    double width = imageSize.width * 4 / 5;
    double height = imageSize.height * subPosition.floor() / subsPerPage;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: offsetFromTop + 8),
        child: Blur(
          blur: 6,
          blurColor: Colors.white,
          colorOpacity: 0.2,
          borderRadius: BorderRadius.circular(15),
          overlay: Container(
            decoration: BoxDecoration(
              // color: Colors.white30,
              border: Border.all(color: Colors.white70, width: 3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: SizedBox(
            width: width,
            height: height - 22,
          ),
        ),
      ),
    );
  }

  Widget showBackgroundSub(Size imageSize) {
    return ValueListenableBuilder<Subtitle?>(
      valueListenable: bgSubValue,
      builder: (context, subtitle, child) {
        if (subtitle == null) return Container();

        double height = imageSize.height / subsPerPage;

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
                  height: height * 0.8,
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
  const SubtitleHighlight({
    super.key,
    required this.subtitle,
    this.height = 80.0,
    this.maxHeight = double.infinity,
  });

  final Subtitle? subtitle;
  final double height;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    ColorsState colorsState = context.watch<ColorsState>();
    List<String> characters = subtitle?.characters ?? [];
    List<Color> colors = characters.map((e) => colorsState.of(e)).toList();
    if (colors.isEmpty) colors.add(Colors.white);

    BoxDecoration borderDecoration, fillDecoration;
    LinearGradient gradient;
    if (colors.length == 1) {
      gradient = LinearGradient(colors: [colors.first, colors.first]);
      fillDecoration = BoxDecoration(color: colors.first.withOpacity(0.3));
    } else {
      gradient = LinearGradient(colors: colors);
      fillDecoration = BoxDecoration(gradient: gradient.scale(0.3));
    }
    borderDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: GradientBoxBorder(gradient: gradient, width: 3),
    );

    return Row(
      children: [
        Flexible(fit: FlexFit.tight, child: SubtitlePointer(colors: colors)),
        Flexible(
          flex: 8,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Blur(
                borderRadius: BorderRadius.circular(20),
                blur: 10,
                colorOpacity: 0,
                blurColor: Colors.white,
                overlay: Container(
                  decoration: borderDecoration,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: fillDecoration,
                  ),
                ),
                child: Container(height: min(height, maxHeight)),
              ),
              Transform.translate(
                offset: Offset(10, -height / 2),
                child: CharacterName(subtitle: subtitle),
              ),
            ],
          ),
        ),
        Flexible(child: Container()),
      ],
    );
  }
}

class CharacterName extends StatelessWidget {
  const CharacterName({
    super.key,
    required this.subtitle,
  });

  final Subtitle? subtitle;

  @override
  Widget build(BuildContext context) {
    if (subtitle == null || subtitle!.speaker == "none") return Container();
    String speaker = subtitle!.speaker;

    ColorsState colorsState = context.watch<ColorsState>();
    List<Color> colors =
        subtitle!.characters.map((c) => colorsState.of(c)).toList();

    LinearGradient gradient;
    double luminance;
    if (colors.length == 1) {
      gradient = LinearGradient(colors: [colors[0], colors[0]]);
      luminance = colors.first.computeLuminance();
    } else {
      gradient = LinearGradient(colors: colors);
      luminance = colors
          .reduce((a, b) => Color.lerp(a, b, 0.5) ?? Colors.white)
          .computeLuminance();
    }
    BoxDecoration decoration = BoxDecoration(
      gradient: gradient,
      border: Border.all(
        color: Colors.white70,
        width: 2,
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
      borderRadius: BorderRadius.circular(100),
    );

    Color textColor = luminance < 0.3 ? Colors.white : Colors.black;
    return AnimatedContainer(
      key: const ValueKey<String>("Character Name"),
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: decoration,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: GoogleFonts.acme(color: textColor, fontSize: 22),
        child: Text(
          Casing.titleCase(speaker),
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

  void onPositionChange(PositionState state) {
    List<Subtitle>? subtitles =
        Provider.of<SubtitleState>(context, listen: false).subtitles;
    Duration subDelay =
        Provider.of<OptionsState>(context, listen: false).subtitleDelay;
    if (state.position == null || subtitles == null) return;
    int i = csIndex.value;
    Subtitle sub = subtitles[i];
    Duration position = state.position! + subDelay;
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

class SubtitleDisplay extends StatelessWidget {
  final Subtitle subtitle;
  final bool blur;
  final bool current;

  const SubtitleDisplay(
    this.subtitle, {
    super.key,
    this.blur = false,
    this.current = false,
  });

  @override
  Widget build(BuildContext context) {
    ColorsState colorsState = context.watch<ColorsState>();
    double width =
        context.select<ImageState, Size>((s) => s.imageSize).width * 4 / 5;
    String text = subtitle.parsedData;
    List<Color> colors;
    if (blur || current) {
      colors = [];
    } else {
      colors = subtitle.characters
          .map((c) => colorsState.of(c).clampLightness(0.65, 1.0))
          .toList();
    }
    if (colors.isEmpty) colors = [Colors.white];

    TextStyle style = GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        letterSpacing: 1,
        fontSize: 25,
      ),
    );
    if (colors.length == 1) {
      style = style.copyWith(color: colors.first);
    } else {
      double w = min(text.length / 50, 1) * width;
      style = style.copyWith(
        foreground: Paint()
          ..shader = LinearGradient(colors: colors)
              .createShader(Rect.fromLTWH(0, 0, w, 100)),
      );
    }

    double textScale = text.length <= 100 ? 1.0 : getTextScale(text, width);

    Widget child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: style,
        child: BorderedText(
          strokeWidth: 5,
          strokeJoin: StrokeJoin.round,
          strokeColor: Colors.black.withOpacity(0.75),
          child: Text(
            text,
            textScaleFactor: textScale,
          ),
        ),
      ),
    );

    if (blur && text.isNotEmpty) {
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

  double getTextScale(String text, double width) {
    TextStyle textStyle = GoogleFonts.poppins(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        letterSpacing: 1,
        fontSize: 25,
      ),
    );
    ui.ParagraphConstraints constraints =
        ui.ParagraphConstraints(width: width - 100);

    ui.ParagraphBuilder pb =
        ui.ParagraphBuilder(textStyle.getParagraphStyle(maxLines: 2))
          ..addText(text);
    ui.Paragraph paragraph = pb.build()..layout(constraints);

    if (paragraph.didExceedMaxLines) {
      return 0.9;
    }
    return 1.0;
  }
}

class SubtitlePointer extends StatefulWidget {
  const SubtitlePointer({
    super.key,
    this.colors = const [Colors.white],
  });

  final List<Color> colors;

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
    List<Color> colors =
        widget.colors.map((e) => e.clampLightness(0.625, 0.94)).toList();
    Color color1, color2;
    if (colors.length == 1) {
      color1 = color2 = colors.first;
    } else {
      color1 = colors[0];
      color2 = colors[1];
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
                color: color1,
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
                color: color2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
