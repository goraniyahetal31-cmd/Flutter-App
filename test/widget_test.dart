import 'package:flutter_test/flutter_test.dart';

import 'package:viny/data/memory_message_repository.dart';
import 'package:viny/main.dart';

void main() {
  testWidgets('Viny shell loads', (WidgetTester tester) async {
    final repo = MemoryMessageRepository();
    await repo.open();
    await tester.pumpWidget(VinyApp(repository: repo));
    await tester.pumpAndSettle();
    expect(find.text('Viny'), findsOneWidget);
  });
}
