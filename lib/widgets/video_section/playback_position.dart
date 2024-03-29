import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scrolling_subtitles/states/audio_state.dart';

class PlaybackPosition extends StatelessWidget {
  const PlaybackPosition({super.key});

  @override
  Widget build(BuildContext context) {
    AudioState state = Provider.of<AudioState>(context, listen: false);
    return Container(
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
      child: StreamBuilder<Duration>(
        stream: state.durationStream,
        builder: (context, dSnapshot) {
          String duration = dSnapshot.data?.toString().substring(0, 7) ?? "-";
          return StreamBuilder<Duration>(
            stream:
                Provider.of<AudioState>(context, listen: false).positionStream,
            builder: (context, pSnapshot) {
              Duration? pos = pSnapshot.data;
              String position = pos?.toString().substring(0, 7) ?? "-";
              return Text(
                "$position / $duration",
                style: GoogleFonts.acme(color: Colors.black, fontSize: 18),
                textAlign: TextAlign.center,
              );
            },
          );
        },
      ),
    );
  }
}
