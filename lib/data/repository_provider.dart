import 'message_repository.dart';
import 'sqlite_message_repository.dart'
    if (dart.library.html) 'memory_message_repository.dart';

Future<MessageRepository> openRepository() => openRepositoryImpl();
