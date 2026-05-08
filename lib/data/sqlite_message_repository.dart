import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/blog_message.dart';
import 'message_repository.dart';

Future<MessageRepository> openRepositoryImpl() async {
  final repo = SqliteMessageRepository();
  await repo.open();
  return repo;
}

class SqliteMessageRepository implements MessageRepository {
  Database? _db;

  Future<Database> get _database async {
    final db = _db;
    if (db != null) return db;
    throw StateError('Database not opened');
  }

  @override
  Future<void> open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'viny_messages.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL DEFAULT '',
  body TEXT NOT NULL,
  image_path TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)
''');
      },
    );
  }

  @override
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  @override
  Future<List<BlogMessage>> listAll() async {
    final db = await _database;
    final rows = await db.query('messages', orderBy: 'updated_at DESC');
    return rows.map(BlogMessage.fromMap).toList();
  }

  @override
  Future<List<BlogMessage>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return listAll();
    final db = await _database;
    final pattern = '%$q%';
    final rows = await db.query(
      'messages',
      where: 'LOWER(body) LIKE ? OR LOWER(title) LIKE ?',
      whereArgs: [pattern, pattern],
      orderBy: 'updated_at DESC',
    );
    return rows.map(BlogMessage.fromMap).toList();
  }

  @override
  Future<BlogMessage?> getById(int id) async {
    final db = await _database;
    final rows = await db.query('messages', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return BlogMessage.fromMap(rows.first);
  }

  @override
  Future<int> insert(BlogMessage message) async {
    final db = await _database;
    final map = Map<String, Object?>.from(message.toMap())..remove('id');
    return db.insert('messages', map);
  }

  @override
  Future<void> update(BlogMessage message) async {
    final id = message.id;
    if (id == null) throw ArgumentError('update requires id');
    final db = await _database;
    final map = message.toMap()..remove('id');
    await db.update('messages', map, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> delete(int id) async {
    final db = await _database;
    await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteMany(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await _database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawDelete('DELETE FROM messages WHERE id IN ($placeholders)', ids);
  }
}
