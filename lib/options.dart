import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class OptionsPanel extends StatefulWidget {
  const OptionsPanel({
    super.key,
    this.onImageChanged,
    this.onSubtitleChanged,
    this.onAudioChanged,
    required this.seekToPos,
  });

  final Future<void> Function(String filepath)? onImageChanged;
  final Future<void> Function(String subPath)? onSubtitleChanged;
  final Future<void> Function(String audioPath)? onAudioChanged;
  final void Function(Duration pos) seekToPos;

  @override
  State<OptionsPanel> createState() => _OptionsPanelState();
}

class _OptionsPanelState extends State<OptionsPanel> {
  String? imagePath;
  String? subtitlePath;
  String? audioPath;
  bool loadingSubs = false;
  final TextEditingController _controller = TextEditingController();

  void pickImageFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;

    setState(() => imagePath = result.files.single.path);
    if (widget.onImageChanged != null && imagePath != null) {
      widget.onImageChanged!(imagePath!);
    }
  }

  void pickSubtitleFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ["vtt"]);
    if (result == null) return;

    setState(() {
      subtitlePath = result.files.single.path;
      loadingSubs = true;
    });
    if (widget.onSubtitleChanged != null && subtitlePath != null) {
      await widget.onSubtitleChanged!(subtitlePath!);
    }
    setState(() => loadingSubs = false);
  }

  void pickAudioFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.media);
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
      child: ListView(
        children: [
          Column(
            children: [
              Text(imagePath == null
                  ? "Select an Image:"
                  : "Selected Image: ${displayPath(imagePath!)}"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: pickImageFile,
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
                  : "Selected subtitle file: ${displayPath(subtitlePath!)}"),
              if (!loadingSubs)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: pickSubtitleFile,
                    child: Text(subtitlePath == null
                        ? "Choose the subtitle file"
                        : "Choose another subtitle file"),
                  ),
                ),
              if (loadingSubs) const Text("Loading subs... Please wait"),
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
      ),
    );
  }
}
