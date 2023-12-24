// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:visual_subs/states/audio_state.dart';
import 'package:visual_subs/widgets/video_section/video_section.dart';

class MobileVideoPage extends StatefulWidget {
  const MobileVideoPage({super.key});

  @override
  State<MobileVideoPage> createState() => _MobileVideoPageState();
}

class _MobileVideoPageState extends State<MobileVideoPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    Provider.of<AudioState>(context, listen: false).pause();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MediaQuery.of(context).orientation == Orientation.portrait
            ? Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Expanded(child: VideoSection()),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Consumer<AudioState>(builder: _audioOptionsBuilder),
                  ),
                ],
              )
            : Row(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Expanded(child: VideoSection()),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Consumer<AudioState>(builder: _audioOptionsBuilder),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _audioOptionsBuilder(
      BuildContext context, AudioState audio, Widget? _) {
    bool audioLoaded = audio.isLoaded;
    List<Widget> options = [
      IconButton(
        onPressed: audioLoaded ? () => audio.seekToPos(Duration.zero) : null,
        icon: const Icon(Icons.fast_rewind_rounded),
      ),
      IconButton(
        onPressed: audioLoaded ? audio.rewind10s : null,
        icon: const Icon(Icons.replay_10_rounded),
      ),
      StreamBuilder(
        stream: audio.playingStream,
        builder: (context, snapshot) {
          if (!audioLoaded || !snapshot.hasData) {
            return const IconButton(
              onPressed: null,
              icon: Icon(Icons.play_arrow_rounded),
            );
          }
          return IconButton(
            onPressed: audio.togglePlayPause,
            icon: snapshot.data!
                ? const Icon(Icons.pause_rounded)
                : const Icon(Icons.play_arrow_rounded),
          );
        },
      ),
      IconButton(
        onPressed: audioLoaded ? audio.forward10s : null,
        icon: const Icon(Icons.forward_10_rounded),
      ),
      IconButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => Container()));
        },
        icon: const Icon(Icons.settings),
      ),
    ];

    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: options,
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: options,
      );
    }
  }
}
