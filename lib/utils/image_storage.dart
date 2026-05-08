import 'package:image_picker/image_picker.dart';

import 'image_storage_io.dart' if (dart.library.html) 'image_storage_web.dart'
    as impl;

Future<String?> persistPickedImage(XFile file) => impl.persistPickedImage(file);
