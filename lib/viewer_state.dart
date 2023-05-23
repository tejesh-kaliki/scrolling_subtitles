import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ImageState extends ChangeNotifier {
  File? _imageFile;
  Size _imageSize = const Size.square(1080);

  File? get image => _imageFile;
  Size get imageSize => _imageSize;

  Future<void> setImageFile(String imagePath) async {
    _imageFile = File(imagePath);
    ui.Image image = await decodeImageFromList(await _imageFile!.readAsBytes());
    _imageSize = Size(image.width / 1.0, image.height / 1.0);
    notifyListeners();
  }
}

class SubtitleState extends ChangeNotifier {}
