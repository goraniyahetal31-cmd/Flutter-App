import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../models/blog_message.dart';

/// Shares text and optional image via the platform sheet (email, social apps, etc.).
Future<void> shareBlogMessage(BlogMessage message) async {
  final text =
      '${message.title}\n\n${message.body}'.trim().replaceAll(RegExp(r'\n{3,}'), '\n\n');
  final path = message.imagePath;

  if (!kIsWeb &&
      path != null &&
      path.isNotEmpty &&
      await File(path).exists()) {
    await SharePlus.instance.share(
      ShareParams(
        text: text.isEmpty ? null : text,
        files: [XFile(path)],
      ),
    );
    return;
  }

  await SharePlus.instance.share(
    ShareParams(text: text.isEmpty ? '(empty message)' : text),
  );
}
