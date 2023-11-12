import 'dart:io';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageState extends ChangeNotifier {
  File? _imageFile;
  Size _imageSize = const Size.square(1080);

  String? get filePath => _imageFile?.path;
  File? get image => _imageFile;
  Size get imageSize => _imageSize;

  ImageState() {
    loadPreviousState();
  }

  Future<void> setImageFile(String imagePath) async {
    File file = File(imagePath);
    if (!await file.exists()) return;

    ui.Image image = await decodeImageFromList(await file.readAsBytes());
    _imageFile = file;
    _imageSize = Size(image.width / 1.0, image.height / 1.0);
    notifyListeners();
  }

  Future<void> pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;

    String? path = result.files.single.path;
    if (path == null) return;

    setImageFile(path);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("imagePath", path);
  }

  Future<void> loadPreviousState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? path = prefs.getString("imagePath");
    if (path != null) setImageFile(path);
  }
}
