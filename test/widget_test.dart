import 'package:flutter_test/flutter_test.dart';
import 'package:tokokita/main.dart';

void main() {
  testWidgets('ProdukPage displays list of products', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('List Data Produk'), findsOneWidget);
    expect(find.text('Kulkas'), findsOneWidget);
    expect(find.text('Playstation'), findsOneWidget);
    expect(find.text('Radio'), findsOneWidget);
  });
}
