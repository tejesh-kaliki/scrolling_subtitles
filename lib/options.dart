import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewer_state.dart';

class OptionsPanel extends StatefulWidget {
  const OptionsPanel({
    super.key,
    this.onSubtitleChanged,
    this.onAudioChanged,
    required this.seekToPos,
  });

  final Future<void> Function(String subPath)? onSubtitleChanged;
  final Future<void> Function(String audioPath)? onAudioChanged;
  final void Function(Duration pos) seekToPos;

  @override
  State<OptionsPanel> createState() => _OptionsPanelState();
}

class _OptionsPanelState extends State<OptionsPanel> {
  String? subtitlePath;
  String? audioPath;
  bool loadingSubs = false;
  final TextEditingController _controller = TextEditingController();

  void pickImageFile(ImageState state) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;

    String? path = result.files.single.path;
    if (path != null) state.setImageFile(path);
  }

  void pickSubtitleFile() async {
    setState(() => loadingSubs = true);
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ["vtt"]);
    if (result == null) {
      setState(() => loadingSubs = false);
      return;
    }

    subtitlePath = result.files.single.path;
    if (widget.onSubtitleChanged != null && subtitlePath != null) {
      await widget.onSubtitleChanged!(subtitlePath!);
    }
    setState(() => loadingSubs = false);
  }

  void pickAudioFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null) return;

    setState(() => audioPath = result.files.single.path);
    if (widget.onAudioChanged != null && audioPath != null) {
      await widget.onAudioChanged!(audioPath!);
    }
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
    widget.seekToPos(pos);
  }

  String displayPath(String path) {
    String fileName = path.split(RegExp(r"[/\\]")).last;
    return "../$fileName";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Consumer<ImageState>(builder: (context, state, _) {
        return ListView(
          children: [
            Column(
              children: [
                Text(state.image == null
                    ? "Select an Image:"
                    : "Selected Image: ${displayPath(state.image!.path)}"),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () => pickImageFile(state),
                    child: Text(state.image == null
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
                    : "Selected subtitle file: ${displayPath(subtitlePath!)}"),
                loadingSubs
                    ? const Text("Loading subs... Please wait")
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: pickSubtitleFile,
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
                    : "Selected audio file: ${displayPath(audioPath!)}"),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: pickAudioFile,
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
                          border: OutlineInputBorder(), hintText: "Enter time"),
                    ),
                  ),
                ],
              ),
              const Divider(),
            ],
          ],
        );
      }),
    );
  }
}
