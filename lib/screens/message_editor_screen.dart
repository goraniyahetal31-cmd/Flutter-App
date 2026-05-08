import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/message_repository.dart';
import '../models/blog_message.dart';
import '../utils/image_storage.dart';

class MessageEditorScreen extends StatefulWidget {
  const MessageEditorScreen({
    super.key,
    required this.repository,
    this.existing,
  });

  final MessageRepository repository;
  final BlogMessage? existing;

  @override
  State<MessageEditorScreen> createState() => _MessageEditorScreenState();
}

class _MessageEditorScreenState extends State<MessageEditorScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String? _imagePath;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleCtrl.text = e.title;
      _bodyCtrl.text = e.body;
      _imagePath = e.imagePath;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file == null || !mounted) return;
    final stored = await persistPickedImage(file);
    if (!mounted) return;
    setState(() => _imagePath = stored);
  }

  void _removeImage() => setState(() => _imagePath = null);

  Future<void> _save() async {
    if (_saving) return;
    final rawBody = _bodyCtrl.text;
    final title = _titleCtrl.text.trim();
    if (rawBody.trim().isEmpty &&
        (_imagePath == null || _imagePath!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add some text or an image')),
      );
      return;
    }

    setState(() => _saving = true);
    final now = DateTime.now();

    try {
      if (_isEdit) {
        final e = widget.existing!;
        final updated = e.copyWith(
          title: title,
          body: rawBody,
          imagePath: _imagePath,
          clearImage: _imagePath == null || _imagePath!.isEmpty,
          updatedAt: now,
        );
        await widget.repository.update(updated);
      } else {
        await widget.repository.insert(
          BlogMessage(
            title: title,
            body: rawBody,
            imagePath: _imagePath,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _preview() {
    final path = _imagePath;
    if (path == null || path.isEmpty) return const SizedBox.shrink();
    if (kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(path),
      );
    }
    final file = File(path);
    if (!file.existsSync()) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(file, height: 220, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit message' : 'New message'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bodyCtrl,
            decoration: const InputDecoration(
              labelText: 'Message',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
            minLines: 6,
            maxLines: 14,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.tonalIcon(
                onPressed: () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery'),
              ),
              const SizedBox(width: 12),
              FilledButton.tonalIcon(
                onPressed: () => _pick(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Camera'),
              ),
              if (_imagePath != null && _imagePath!.isNotEmpty) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _removeImage,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove image',
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _preview(),
        ],
      ),
    );
  }
}
