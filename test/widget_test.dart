import 'package:flutter_test/flutter_test.dart';
import 'package:aire/main.dart';

void main() {
  testWidgets('AireApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AireApp());
    expect(find.byType(AireApp), findsOneWidget);
  });
}
