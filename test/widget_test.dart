// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:caffora_mobile_app/main.dart';

void main() {
  testWidgets('renders the Caffora home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CafforaApp());

    expect(find.text('Good morning, Alex'), findsOneWidget);
    expect(find.text('Popular Drinks'), findsOneWidget);
    expect(find.text('Bakery & Treats'), findsOneWidget);
  });

  testWidgets('navigates to the Caffora menu screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CafforaApp());

    await tester.tap(find.text('Menu').last);
    await tester.pumpAndSettle();

    expect(find.text('Table 04'), findsOneWidget);
    expect(find.text('Artisan Flat White'), findsOneWidget);
    expect(find.text('View Cart  →'), findsOneWidget);
  });
}
