import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlaybackPosition extends StatelessWidget {
  const PlaybackPosition({
    super.key,
    required this.total,
    required this.position,
  });

  final Duration total;
  final Duration position;

  @override
  Widget build(BuildContext context) {
    String totalStr = total.toString().substring(0, 7);
    String positionStr = position.toString().substring(0, 7);

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
      child: Text(
        "$positionStr / $totalStr",
        style: GoogleFonts.acme(color: Colors.black, fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }
}
