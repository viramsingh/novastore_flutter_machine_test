import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_round_test/main.dart';

void main() {
  testWidgets('NovaStoreApp smoke test builds properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: NovaStoreApp(),
      ),
    );
    expect(find.byType(NovaStoreApp), findsOneWidget);
  });
}
