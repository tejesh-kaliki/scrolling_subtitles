import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:dart_casing/dart_casing.dart';

import 'state_management.dart';

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
    return Container(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
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
  final TextEditingController _controller = TextEditingController();

  void pickImageFile(ImageState state) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;

    String? path = result.files.single.path;
    if (path == null) return;
    state.setImageFile(path);
  }

  void pickSubtitleFile(SubtitleState state) async {
    setState(() => loadingSubs = true);
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ["vtt"]);
    if (result == null) {
      setState(() => loadingSubs = false);
      return;
    }

    String? path = result.files.single.path;
    if (path != null) {
      await state.parseSubs(path);
    }

    setState(() => loadingSubs = false);
  }

  void pickAudioFile(AudioState state) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null) return;

    String? path = result.files.single.path;
    if (path != null) state.loadAudio(path);
  }

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
        children: [
          Column(
            children: [
              Text(imagePath == null
                  ? "Select an Image:"
                  : "Selected Image: ${displayPath(imagePath)}"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () => pickImageFile(imageState),
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
                        onPressed: () => pickSubtitleFile(subtitleState),
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
                  onPressed: () => pickAudioFile(context.read<AudioState>()),
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
                    controller: _controller,
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
    List<String> characters =
        context.select<SubtitleState, List<String>>((s) => s.characters);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () => colorsState.loadColors(characters),
            child: const Text("Load Default Colors"),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: characters.length,
            itemBuilder: (context, i) {
              Color color = colorsState.of(characters[i]);

              String name = Casing.titleCase(characters[i]);

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
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      ColorsState colorsState = context.watch<ColorsState>();
                      Color cColor = colorsState.of(characters[i]);

                      return AlertDialog(
                        titlePadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        contentPadding: const EdgeInsets.all(0),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              colorsState.setCharacterColor(
                                  name.toLowerCase(), cColor);
                              Navigator.of(context).pop();
                            },
                            child: const Text("Confirm"),
                          )
                        ],
                        title: Center(child: Text("Pick a Color for $name")),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: ColorPicker(
                                pickerColor: cColor,
                                onColorChanged: (c) =>
                                    setState(() => cColor = c),
                                enableAlpha: false,
                              ),
                            ),
                            ColorPickerInput(
                              cColor,
                              (c) => setState(() => cColor = c),
                              enableAlpha: false,
                              disable: false,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
