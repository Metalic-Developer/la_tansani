import 'package:flutter_test/flutter_test.dart';
import 'package:la_tansani/app.dart';

void main() {
  testWidgets('Login screen shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const LaTansaniApp());
    expect(find.text('لا تنساني'), findsOneWidget);
  });
}