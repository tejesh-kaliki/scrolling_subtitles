import 'package:flutter/material.dart';

class OptionsState extends ChangeNotifier {
  Duration _subDelay = const Duration(milliseconds: 500);

  Duration get subtitleDelay => _subDelay;
  set subtitleDelay(Duration delay) {
    _subDelay = delay;
    notifyListeners();
  }
}
