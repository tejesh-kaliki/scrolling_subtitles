import 'package:dart_casing/dart_casing.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:scrolling_subtitles/states/colors_state.dart';
import 'package:scrolling_subtitles/states/subtitle_state.dart';

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
    List<String> characterList = characters.toList(growable: false)..sort();

    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: Column(
        children: [
          const Gap(10),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            runSpacing: 10,
            children: [
              ElevatedButton(
                onPressed: () => colorsState.loadColors(characters),
                child: const Text("Load"),
              ),
              ElevatedButton(
                onPressed: () => colorsState.clearColors(),
                child: const Text("Clear"),
              ),
              ElevatedButton(
                onPressed: () async =>
                    await colorsState.saveToFile(characterList),
                child: const Text("Save to file"),
              ),
              ElevatedButton(
                onPressed: () async => await colorsState.pickFile(characters),
                child: const Text("Load from file"),
              ),
            ],
          ),
          const Gap(10),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
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
          const Gap(20),
        ],
      ),
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
