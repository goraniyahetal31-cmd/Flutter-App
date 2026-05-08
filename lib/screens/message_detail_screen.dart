import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/message_repository.dart';
import '../models/blog_message.dart';
import '../utils/message_share.dart';
import 'message_editor_screen.dart';

class MessageDetailScreen extends StatefulWidget {
  const MessageDetailScreen({
    super.key,
    required this.repository,
    required this.messageId,
  });

  final MessageRepository repository;
  final int messageId;

  @override
  State<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  BlogMessage? _message;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await widget.repository.getById(widget.messageId);
    if (!mounted) return;
    setState(() {
      _message = m;
      _loading = false;
    });
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete message'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await widget.repository.delete(widget.messageId);
      if (mounted) Navigator.pop(context);
    }
  }

  Widget _imageWidget(String path) {
    if (kIsWeb) {
      return Image.network(path, fit: BoxFit.contain);
    }
    final file = File(path);
    if (!file.existsSync()) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Image file missing on disk'),
      );
    }
    return Image.file(file, fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Message')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final m = _message;
    if (m == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Message')),
        body: const Center(child: Text('Message not found')),
      );
    }

    final fmt = DateFormat.yMMMMEEEEd().add_jm();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => shareBlogMessage(m),
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => MessageEditorScreen(
                    repository: widget.repository,
                    existing: m,
                  ),
                ),
              );
              await _load();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmDelete,
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              m.title.trim().isEmpty ? 'Untitled' : m.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Updated ${fmt.format(m.updatedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 32),
            SelectableText(
              m.body.isEmpty ? '(No text)' : m.body,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (m.imagePath != null && m.imagePath!.isNotEmpty) ...[
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _imageWidget(m.imagePath!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
