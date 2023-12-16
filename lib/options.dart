import 'package:flutter/material.dart';
import 'widgets/options_tab/color_options_tab.dart';
import 'widgets/options_tab/main_options_tab.dart';

class OptionsPanel extends StatefulWidget {
  const OptionsPanel({super.key});

  @override
  State<OptionsPanel> createState() => _OptionsPanelState();
}

class _OptionsPanelState extends State<OptionsPanel>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  bool optionsExpanded = true;

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
    if (optionsExpanded) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xff202020),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 5,
              spreadRadius: 5,
            )
          ],
        ),
        margin: const EdgeInsets.all(10),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () =>
                      setState(() => optionsExpanded = !optionsExpanded),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
                Expanded(
                  child: TabBar(
                    controller: _controller,
                    tabs: [displayTab("Basic"), displayTab("Colors")],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TabBarView(
                  controller: _controller,
                  children: const [MainOptionsTab(), ColorOptionsTab()],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return IconButton(
        onPressed: () => setState(() => optionsExpanded = !optionsExpanded),
        icon: const Icon(Icons.chevron_left_rounded),
      );
    }
  }
}
