import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:dart_casing/dart_casing.dart';
import 'package:scrolling_subtitles/states/audio_state.dart';
import 'package:scrolling_subtitles/states/image_state.dart';
import 'package:scrolling_subtitles/states/options_state.dart';
import 'package:scrolling_subtitles/states/subtitle_state.dart';
import 'package:scrolling_subtitles/states/colors_state.dart';

class OptionsPanel extends StatefulWidget {
  const OptionsPanel({super.key});

  @override
  State<OptionsPanel> createState() => _OptionsPanelState();
}

class _OptionsPanelState extends State<OptionsPanel>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  Widget displayTab(String text) {
    Color textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Container(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _controller,
          tabs: [displayTab("Basic"), displayTab("Colors")],
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: const [MainOptionsTab(), ColorOptionsTab()],
          ),
        ),
      ],
    );
  }
}

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
    String? audioPath = audioState.filePath;
    String? imagePath = imageState.filePath;
    String? subtitlePath = subtitleState.filePath;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView(
        primary: false,
        children: [
          Column(
            children: [
              Text(imagePath == null
                  ? "Select an Image:"
                  : "Selected Image: ${displayPath(imagePath)}"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () => imageState.pickFile(),
                  child: Text(imagePath == null
                      ? "Choose an Image"
                      : "Choose another Image"),
                ),
              ),
            ],
          ),
          const Divider(),
          Column(
            children: [
              Text(subtitlePath == null
                  ? "Select subtitle file:"
                  : "Selected subtitle file: ${displayPath(subtitlePath)}"),
              loadingSubs
                  ? const Text("Loading subs... Please wait")
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        onPressed: () async {
                          setState(() => loadingSubs = true);
                          await subtitleState.pickFile();
                          setState(() => loadingSubs = false);
                        },
                        child: Text(subtitlePath == null
                            ? "Choose the subtitle file"
                            : "Choose another subtitle file"),
                      ),
                    ),
            ],
          ),
          const Divider(),
          Column(
            children: [
              Text(audioPath == null
                  ? "Select audio file:"
                  : "Selected audio file: ${displayPath(audioPath)}"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () => audioState.pickFile(),
                  child: Text(audioPath == null
                      ? "Choose the audio file"
                      : "Choose another audio file"),
                ),
              ),
            ],
          ),
          const Divider(),
          if (audioPath != null) ...[
            Row(
              children: [
                const Text("Seek Audio to Duration:"),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onSubmitted: seekToPos,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter time",
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
          ],
          Row(
            children: [
              const Text("Subtitle Delay (in ms):"),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  onSubmitted: setSubDelay,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "500",
                    suffixText: "ms",
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class ColorOptionsTab extends StatefulWidget {
  const ColorOptionsTab({super.key});

  @override
  State<ColorOptionsTab> createState() => _ColorOptionsTabState();
}

class _ColorOptionsTabState extends State<ColorOptionsTab> {
  @override
  Widget build(BuildContext context) {
    ColorsState colorsState = context.watch<ColorsState>();
    Set<String> characters =
        context.select<SubtitleState, Set<String>>((s) => s.characters);
    List<String> characterList = characters.toList();

    return Column(
      children: [
        TextButton(
          onPressed: () => colorsState.loadColors(characters),
          child: const Text("Load Colors"),
        ),
        const Gap(5.0),
        TextButton(
          onPressed: () => colorsState.clearColors(),
          child: const Text("Clear Colors"),
        ),
        const Gap(5.0),
        TextButton(
          onPressed: () async => await colorsState.saveToFile(),
          child: const Text("Save to file"),
        ),
        const Gap(5.0),
        TextButton(
          onPressed: () async => await colorsState.pickFile(characters),
          child: const Text("Load from file"),
        ),
        const Gap(5.0),
        Expanded(
          child: ListView.builder(
            itemCount: characters.length,
            itemBuilder: (context, i) {
              Color color = colorsState.of(characterList[i]);

              String name = Casing.titleCase(characterList[i]);

              return ListTile(
                title: Text(name),
                leading: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                ),
                onTap: () async {
                  Color newColor = await colorPickerDialog(color);
                  colorsState.setCharacterColor(characterList[i], newColor);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<Color> colorPickerDialog(Color color) async {
    Color dialogPickerColor = color;
    await ColorPicker(
      color: color,
      onColorChanged: (Color c) => dialogPickerColor = c,
      heading: Text(
        'Select color',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subheading: Text(
        'Select color shade',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      wheelSubheading: Text(
        'Selected color and its shades',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      colorCodeReadOnly: false,
      materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorCodeTextStyle: Theme.of(context).textTheme.bodyMedium,
      colorCodePrefixStyle: Theme.of(context).textTheme.bodySmall,
      selectedPickerTypeColor: Theme.of(context).colorScheme.primary,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        parseShortHexCode: true,
        pasteButton: true,
        copyButton: true,
        copyFormat: ColorPickerCopyFormat.hexRRGGBB,
      ),
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: false,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
    ).showPickerDialog(
      context,
      actionsPadding: const EdgeInsets.all(16),
    );
    return dialogPickerColor;
  }
}
