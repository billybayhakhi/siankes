import 'package:flutter_test/flutter_test.dart';
import 'package:siankes/main.dart';

void main() {
  testWidgets('Siankes app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SiankesApp());
    expect(find.text('SIANKES'), findsWidgets);
  });
}