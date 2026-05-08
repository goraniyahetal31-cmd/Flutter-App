import '../models/blog_message.dart';

/// Persistence API used by the UI (SQLite on IO; in-memory on web).
abstract class MessageRepository {
  Future<void> open();
  Future<void> close();

  Future<List<BlogMessage>> listAll();
  Future<List<BlogMessage>> search(String query);
  Future<BlogMessage?> getById(int id);
  Future<int> insert(BlogMessage message);
  Future<void> update(BlogMessage message);
  Future<void> delete(int id);
  Future<void> deleteMany(List<int> ids);
}
