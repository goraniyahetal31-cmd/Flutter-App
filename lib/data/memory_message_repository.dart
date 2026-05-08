import '../models/blog_message.dart';
import 'message_repository.dart';

/// Browser fallback: same behaviours without SQLite (coursework targets device DB).
Future<MessageRepository> openRepositoryImpl() async {
  final repo = MemoryMessageRepository();
  await repo.open();
  return repo;
}

class MemoryMessageRepository implements MessageRepository {
  final List<BlogMessage> _rows = [];
  int _nextId = 1;

  @override
  Future<void> open() async {}

  @override
  Future<void> close() async {}

  @override
  Future<List<BlogMessage>> listAll() async =>
      List.unmodifiable(_sorted());

  @override
  Future<List<BlogMessage>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return listAll();
    return _sorted()
        .where((m) {
          return m.body.toLowerCase().contains(q) ||
              m.title.toLowerCase().contains(q);
        })
        .toList();
  }

  @override
  Future<BlogMessage?> getById(int id) async {
    try {
      return _rows.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> insert(BlogMessage message) async {
    final id = _nextId++;
    _rows.add(
      BlogMessage(
        id: id,
        title: message.title,
        body: message.body,
        imagePath: message.imagePath,
        createdAt: message.createdAt,
        updatedAt: message.updatedAt,
      ),
    );
    return id;
  }

  @override
  Future<void> update(BlogMessage message) async {
    final id = message.id;
    if (id == null) throw ArgumentError('update requires id');
    final i = _rows.indexWhere((m) => m.id == id);
    if (i < 0) return;
    _rows[i] = message;
  }

  @override
  Future<void> delete(int id) async {
    _rows.removeWhere((m) => m.id == id);
  }

  @override
  Future<void> deleteMany(List<int> ids) async {
    final set = ids.toSet();
    _rows.removeWhere((m) => m.id != null && set.contains(m.id));
  }

  List<BlogMessage> _sorted() {
    final copy = [..._rows];
    copy.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return copy;
  }
}
