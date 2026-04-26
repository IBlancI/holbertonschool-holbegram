import "dart:typed_data";

import "package:image_picker/image_picker.dart";

Future<Uint8List?> pickImage(ImageSource source) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: source);
  if (picked == null) return null;
  return picked.readAsBytes();
}
