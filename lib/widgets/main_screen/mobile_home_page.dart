// Flutter imports:
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:visual_subs/states/audio_state.dart';
import 'package:visual_subs/states/image_state.dart';
import 'package:visual_subs/states/subtitle_state.dart';
import 'package:visual_subs/widgets/main_screen/mobile_video_page.dart';

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({super.key});

  @override
  State<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage> {
  bool loadingSubs = false;

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

    const selectedTextStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Visual Subs")),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const Gap(15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: subtitlePath != null ? Colors.green : null,
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
            const Gap(15),
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
            const Gap(20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: _launchVideoPlayer,
              child: const Text("Start Video", style: selectedTextStyle),
            ),
          ],
        ),
      ),
    );
  }

  void _launchVideoPlayer() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const MobileVideoPage()));
  }
}
