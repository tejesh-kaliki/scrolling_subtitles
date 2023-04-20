import 'package:flutter/material.dart';

class CharacterColors {
  static final CharacterColors _instance = CharacterColors._internal();

  factory CharacterColors() => _instance;

  CharacterColors._internal() {
    colorMap = {};
  }

  late Map<String, Color> colorMap;

  void loadDefault() {
    colorMap.addAll({
      "rozemyne": Colors.blue.shade800,
      "myne": Colors.blue.shade800,
      "urano": Colors.blue.shade800,
      "benno": Colors.yellow,
      "lutz": Colors.orange,
      "gutenbergs": const Color(0xff6BAED6),
      "ferdinand": Colors.cyanAccent,
      "sylvester": Colors.deepPurple,
      "stenluke": Colors.teal,
      "wilfried": Colors.amber.shade300,
      "cornelius": Colors.lime,
      "charlotte": Colors.indigo.shade400,
      "karstedt": Colors.orange,
      "bonifatius": const Color(0xff996515),
      "florencia": Colors.limeAccent.shade400,
      "elvira": Colors.greenAccent.shade400,
      "fran": Colors.grey,
      "damuel": Colors.yellow.shade200,
      "tuuli": Colors.lightGreenAccent,
      "georgine": Colors.purple,
      "angelica": const Color(0xff6BAED6),
      "lamprecht": const Color(0xffFCAE91),
      "bezewanst": const Color(0xffFB6A4A),
      "bindewald": const Color.fromARGB(255, 255, 201, 176),
      "gunther": Colors.green.shade600,
      "effa": Colors.green.shade200,
      "rihyarda": const Color(0xffBDD7E7),
      "veronica": const Color(0xffFCAE91),
      "black-clad man": Colors.grey.shade800,
    });
  }

  Color of(String character) {
    if (character.contains("+")) {
      List<String> chars = character.split("+");
      for (String char in chars) {
        char = char.trim();
        if (colorMap.containsKey(char)) return colorMap[char]!;
      }
    }
    return colorMap[character] ?? Colors.white;
  }
}
