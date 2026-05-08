import 'package:flutter/material.dart';

import 'data/message_repository.dart';
import 'data/repository_provider.dart';
import 'screens/message_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final MessageRepository repository = await openRepository();
  runApp(VinyApp(repository: repository));
}

class VinyApp extends StatelessWidget {
  const VinyApp({super.key, required this.repository});

  final MessageRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      title: 'E-Commerce Store',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: MessageListScreen(repository: repository),
    );
  }
}
