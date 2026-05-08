import 'package:image_picker/image_picker.dart';

Future<String?> persistPickedImage(XFile file) async {
  return file.path.isNotEmpty ? file.path : null;
}
