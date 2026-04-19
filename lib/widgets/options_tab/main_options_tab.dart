import 'package:dart_casing/dart_casing.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:scrolling_subtitles/data/config_options.dart';
import 'package:scrolling_subtitles/data/subtitle_state.dart';
import 'package:scrolling_subtitles/providers/options_provider.dart';
import 'package:scrolling_subtitles/providers/subtitle_provider.dart';
import 'package:scrolling_subtitles/states/audio_state.dart';
import 'package:scrolling_subtitles/states/image_state.dart';

class MainOptionsTab extends ConsumerStatefulWidget {
  const MainOptionsTab({super.key});

  @override
  ConsumerState<MainOptionsTab> createState() => _MainOptionsTabState();
}

class _MainOptionsTabState extends ConsumerState<MainOptionsTab> {
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
    ConfigOptions options = ref.read(optionsProvider);
    ref.read(optionsProvider.notifier).setOptions(options.copyWith(
          subDelay: Duration(milliseconds: dms),
        ));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ImageState imageState = context.watch<ImageState>();
    AudioState audioState = context.watch<AudioState>();
    SubtitleState subtitleState = ref.watch(subtitleProvider);
    ConfigOptions options = ref.watch(optionsProvider);
    String? audioPath = audioState.filePath;
    String? imagePath = imageState.filePath;

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
                      backgroundColor: subtitleState.subtitleFile != null
                          ? Colors.green
                          : null,
                    ),
                    onPressed: loadingSubs
                        ? null
                        : () async {
                            setState(() => loadingSubs = true);
                            await ref
                                .read(subtitleProvider.notifier)
                                .pickFile();
                            setState(() => loadingSubs = false);
                          },
                    child: loadingSubs
                        ? const Text("Loading Subs")
                        : subtitleState.subtitleFile == null
                            ? const Text("Pick Subtitles")
                            : const Text(
                                "Pick New Subtitles",
                                style: selectedTextStyle,
                              ),
                  ),
                  if (subtitleState.subtitleFile != null)
                    Text(displayPath(subtitleState.subtitleFile!.path)),
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
          ...displayFontOptions(options),
        ],
      ),
    );
  }

  void updateOptions(ConfigOptions options) {
    ref.read(optionsProvider.notifier).setOptions(options);
  }

  List<Widget> displayFontOptions(ConfigOptions options) {
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
            initialSelection: options.fontFamily,
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
            onSelected: (value) => updateOptions(options.copyWith(
              fontFamily: value ?? SubtitleFontFamily.poppins,
            )),
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
                updateOptions(options.copyWith(fontSize: fontSize));
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
                hintText: options.fontSize.toString(),
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
                updateOptions(options.copyWith(lineHeight: lineHeight));
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
                hintText: options.lineHeight.toString(),
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
              child: Text("Text Border:"),
            ),
          ),
          const Gap(10),
          SizedBox(
            width: 150,
            child: TextField(
              onSubmitted: (value) {
                double width = double.parse(value);
                updateOptions(options.copyWith(textBorder: width));
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
                hintText: options.textBorder.toString(),
              ),
            ),
          ),
        ],
      ),
    ];
  }
}
