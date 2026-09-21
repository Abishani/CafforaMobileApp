// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
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

  testWidgets('navigates to the Caffora cart screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CafforaApp());

    await tester.tap(find.text('Menu').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.shopping_bag_outlined).last);
    await tester.pumpAndSettle();

    expect(find.text('Your Bag'), findsOneWidget);
    expect(find.text('Artisan Flat White'), findsOneWidget);
    expect(find.text('Place Order • \$14.99'), findsOneWidget);
  });

  testWidgets('view cart summary opens the Caffora cart screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CafforaApp());

    await tester.tap(find.text('Menu').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Cart  →'));
    await tester.pumpAndSettle();

    expect(find.text('Your Bag'), findsOneWidget);
    expect(find.text('Estimated Tax'), findsOneWidget);
  });

  testWidgets('place order opens the Caffora orders screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CafforaApp());

    await tester.tap(find.text('Menu').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.shopping_bag_outlined).last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Place Order • \$14.99'));
    await tester.tap(find.text('Place Order • \$14.99'));
    await tester.pumpAndSettle();

    expect(find.text('My Orders'), findsOneWidget);
    expect(find.text('Ready in ~4 mins'), findsWidgets);
  });

  testWidgets('orders tab opens the Caffora orders screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CafforaApp());

    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();

    expect(find.text('My Orders'), findsOneWidget);
    expect(find.text('Offline mode • Cached receipt ready'), findsOneWidget);
  });
}
