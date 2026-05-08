import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String?> persistPickedImage(XFile file) async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(docs.path, 'message_images'));
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  final unique =
      '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
  final destPath = p.join(dir.path, unique);
  await File(file.path).copy(destPath);
  return destPath;
}
