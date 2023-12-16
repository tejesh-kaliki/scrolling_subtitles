import 'package:dart_casing/dart_casing.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:scrolling_subtitles/states/audio_state.dart';
import 'package:scrolling_subtitles/states/image_state.dart';
import 'package:scrolling_subtitles/states/options_state.dart';
import 'package:scrolling_subtitles/states/subtitle_state.dart';

class MainOptionsTab extends StatefulWidget {
  const MainOptionsTab({super.key});

  @override
  State<MainOptionsTab> createState() => _MainOptionsTabState();
}

class _MainOptionsTabState extends State<MainOptionsTab> {
  bool loadingSubs = false;

  void seekToPos(String time) {
    RegExp timeRegex = RegExp(r"^(?:(\d+):){0,2}(\d+)$");
    RegExpMatch? match = timeRegex.firstMatch(time);
    if (match == null) return;
    int n = match.groupCount;
    int s = int.parse(match.group(n) ?? "0");
    int m = n >= 2 ? int.parse(match.group(n - 1) ?? "0") : 0;
    int h = n >= 3 ? int.parse(match.group(n - 2) ?? "0") : 0;
    Duration pos = Duration(seconds: s, minutes: m, hours: h);
    context.read<AudioState>()
      ..seekToPos(pos)
      ..pause();
  }

  String displayPath(String path) {
    String fileName = path.split(RegExp(r"[/\\]")).last;
    return "../$fileName";
  }

  void setSubDelay(String delayms) {
    int dms = int.parse(delayms);
    int seconds = (dms / 1000).floor();
    int milliseconds = dms % 1000;
    context.read<OptionsState>().subtitleDelay =
        Duration(seconds: seconds, milliseconds: milliseconds);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ImageState imageState = context.watch<ImageState>();
    AudioState audioState = context.watch<AudioState>();
    SubtitleState subtitleState = context.watch<SubtitleState>();
    OptionsState optionsState = context.watch<OptionsState>();
    String? audioPath = audioState.filePath;
    String? imagePath = imageState.filePath;
    String? subtitlePath = subtitleState.filePath;

    const selectedTextStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView(
        primary: false,
        children: [
          const Gap(10),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            runSpacing: 10,
            children: [
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: imagePath != null ? Colors.green : null,
                    ),
                    onPressed: () => imageState.pickFile(),
                    child: imagePath == null
                        ? const Text("Pick Image")
                        : const Text(
                            "Pick New Image",
                            style: selectedTextStyle,
                          ),
                  ),
                  if (imagePath != null) Text(displayPath(imagePath)),
                ],
              ),
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          subtitlePath != null ? Colors.green : null,
                    ),
                    onPressed: loadingSubs
                        ? null
                        : () async {
                            setState(() => loadingSubs = true);
                            await subtitleState.pickFile();
                            setState(() => loadingSubs = false);
                          },
                    child: loadingSubs
                        ? const Text("Loading Subs")
                        : subtitlePath == null
                            ? const Text("Pick Subtitles")
                            : const Text(
                                "Pick New Subtitles",
                                style: selectedTextStyle,
                              ),
                  ),
                  if (subtitlePath != null) Text(displayPath(subtitlePath)),
                ],
              ),
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: audioPath != null ? Colors.green : null,
                    ),
                    onPressed: () => audioState.pickFile(),
                    child: audioPath == null
                        ? const Text("Pick Audio")
                        : const Text(
                            "Pick New Audio",
                            style: selectedTextStyle,
                          ),
                  ),
                  if (audioPath != null) Text(displayPath(audioPath)),
                ],
              ),
            ],
          ),
          const Gap(10),
          const Divider(),
          if (audioPath != null) ...[
            Row(
              children: [
                const SizedBox(
                  width: 150,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text("Seek Audio:"),
                  ),
                ),
                const Gap(10),
                SizedBox(
                  width: 150,
                  child: TextField(
                    onSubmitted: seekToPos,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      hintText: "Enter time",
                    ),
                  ),
                ),
              ],
            ),
            const Gap(10),
          ],
          Row(
            children: [
              const SizedBox(
                width: 150,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text("Subtitle Delay:"),
                ),
              ),
              const Gap(10),
              SizedBox(
                width: 150,
                child: TextField(
                  onSubmitted: setSubDelay,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    hintText: "500",
                    suffixText: "ms",
                  ),
                ),
              ),
            ],
          ),
          const Gap(10),
          const Divider(),
          ...displayFontOptions(optionsState),
        ],
      ),
    );
  }

  List<Widget> displayFontOptions(OptionsState state) {
    return [
      Row(
        children: [
          const SizedBox(
            width: 150,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text("Font Family:"),
            ),
          ),
          const Gap(10),
          DropdownMenu(
            initialSelection: state.fontFamily,
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            dropdownMenuEntries: SubtitleFontFamily.values
                .map(
                  (e) => DropdownMenuEntry(
                    value: e,
                    label: Casing.titleCase(e.name),
                  ),
                )
                .toList(),
            onSelected: (value) =>
                state.fontFamily = value ?? SubtitleFontFamily.poppins,
          ),
        ],
      ),
      const Gap(10),
      Row(
        children: [
          const SizedBox(
            width: 150,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text("Font Size:"),
            ),
          ),
          const Gap(10),
          SizedBox(
            width: 150,
            child: TextField(
              onSubmitted: (value) {
                double fontSize = double.parse(value);
                state.fontSize = fontSize;
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
                hintText: state.fontSize.toString(),
              ),
            ),
          ),
        ],
      ),
      const Gap(10),
      Row(
        children: [
          const SizedBox(
            width: 150,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text("Line Height:"),
            ),
          ),
          const Gap(10),
          SizedBox(
            width: 150,
            child: TextField(
              onSubmitted: (value) {
                double lineHeight = double.parse(value);
                state.lineHeight = lineHeight;
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
                hintText: state.lineHeight.toString(),
              ),
            ),
          ),
        ],
      ),
      const Gap(10),
      Row(
        children: [
          const SizedBox(
            width: 150,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text("Border Width:"),
            ),
          ),
          const Gap(10),
          SizedBox(
            width: 150,
            child: TextField(
              onSubmitted: (value) {
                double width = double.parse(value);
                state.borderWidth = width;
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
                hintText: state.borderWidth.toString(),
              ),
            ),
          ),
        ],
      ),
    ];
  }
}
