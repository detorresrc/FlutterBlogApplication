import 'dart:io';

import 'package:image_picker/image_picker.dart';

Future<File?> pickImage() async {
  try {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) return File(file.path);

    return null;
  } catch (e) {
    return null;
  }
}
