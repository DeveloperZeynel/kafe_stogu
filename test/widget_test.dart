import 'package:flutter_test/flutter_test.dart';

import 'package:kafe_stogu/main.dart';

void main() {
  testWidgets(
    'Login ekranı açılıyor',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const KafeStoguApp(),
      );

      expect(
        find.text('KAFE STOĞU'),
        findsOneWidget,
      );

      expect(
        find.text('GİRİŞ YAP'),
        findsOneWidget,
      );
    },
  );
}