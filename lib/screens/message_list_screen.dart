import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/message_repository.dart';
import '../models/blog_message.dart';
import 'message_detail_screen.dart';
import 'message_editor_screen.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key, required this.repository});

  final MessageRepository repository;

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  final _searchCtrl = TextEditingController();
  List<BlogMessage> _messages = [];
  bool _loading = true;
  bool _selectionMode = false;
  final Set<int> _selected = {};
  bool _searchFirstOnly = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final q = _searchCtrl.text;
    final list = q.trim().isEmpty
        ? await widget.repository.listAll()
        : await widget.repository.search(q);
    if (!mounted) return;
    setState(() {
      _messages = list;
      _loading = false;
      _selected.removeWhere((id) => !_messages.any((m) => m.id == id));
    });
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete selected'),
        content: Text(
          'Delete ${_selected.length} message${_selected.length == 1 ? '' : 's'}?',
        ),
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
    if (ok != true || !mounted) return;
    await widget.repository.deleteMany(_selected.toList());
    setState(() {
      _selected.clear();
      _selectionMode = false;
    });
    await _reload();
  }

  Future<void> _openFirstMatch() async {
    await _reload();
    if (!mounted) return;
    if (_messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No matching messages')),
      );
      return;
    }
    final first = _messages.first;
    final id = first.id;
    if (id == null) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => MessageDetailScreen(
          repository: widget.repository,
          messageId: id,
        ),
      ),
    );
    await _reload();
  }

  String _subtitle(BlogMessage m) {
    final fmt = DateFormat.yMMMd().add_jm();
    return fmt.format(m.updatedAt);
  }

  @override
  Widget build(BuildContext context) {
    final visible =
        _searchFirstOnly && _messages.isNotEmpty ? [_messages.first] : _messages;

    return Scaffold(
      appBar: AppBar(
        title: _selectionMode
            ? Text('${_selected.length} selected')
            : const Text('Viny'),
        actions: [
          if (!_selectionMode) ...[
            IconButton(
              tooltip: 'Search first match only',
              onPressed: () {
                setState(() => _searchFirstOnly = !_searchFirstOnly);
              },
              icon: Icon(
                _searchFirstOnly ? Icons.looks_one : Icons.looks_one_outlined,
              ),
            ),
            IconButton(
              tooltip: 'Open first search result',
              onPressed: _openFirstMatch,
              icon: const Icon(Icons.open_in_new),
            ),
            IconButton(
              tooltip: 'Select messages',
              onPressed: () => setState(() {
                _selectionMode = true;
                _selected.clear();
              }),
              icon: const Icon(Icons.checklist),
            ),
          ] else ...[
            IconButton(
              tooltip: 'Delete selected',
              onPressed: _selected.isEmpty ? null : _deleteSelected,
              icon: const Icon(Icons.delete_sweep),
            ),
            IconButton(
              tooltip: 'Cancel selection',
              onPressed: () => setState(() {
                _selectionMode = false;
                _selected.clear();
              }),
              icon: const Icon(Icons.close),
            ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search title or body…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                          _reload();
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                filled: true,
              ),
              onChanged: (_) {
                setState(() {});
                _reload();
              },
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : visible.isEmpty
              ? Center(
                  child: Text(
                    _searchCtrl.text.trim().isEmpty
                        ? 'No messages yet.\nTap + to create one.'
                        : 'No matches for your search.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : ListView.builder(
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final m = visible[index];
                    final id = m.id!;
                    final selected = _selected.contains(id);
                    return ListTile(
                      selected: selected,
                      leading: _selectionMode
                          ? Checkbox(
                              value: selected,
                              onChanged: (_) => _toggleSelection(id),
                            )
                          : const Icon(Icons.article_outlined),
                      title: Text(
                        m.title.trim().isEmpty ? '(no title)' : m.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        m.body.trim().isEmpty
                            ? _subtitle(m)
                            : '${m.body.replaceAll('\n', ' ')}\n${_subtitle(m)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: m.imagePath != null && m.imagePath!.isNotEmpty
                          ? const Icon(Icons.image)
                          : null,
                      onLongPress: () {
                        setState(() {
                          _selectionMode = true;
                          _toggleSelection(id);
                        });
                      },
                      onTap: () async {
                        if (_selectionMode) {
                          _toggleSelection(id);
                          return;
                        }
                        await Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => MessageDetailScreen(
                              repository: widget.repository,
                              messageId: id,
                            ),
                          ),
                        );
                        await _reload();
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => MessageEditorScreen(
                repository: widget.repository,
              ),
            ),
          );
          await _reload();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
