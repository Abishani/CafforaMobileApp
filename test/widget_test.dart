// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:caffora_mobile_app/main.dart';
import 'package:caffora_mobile_app/core/auth/auth_controller.dart';

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

  testWidgets('account tab opens the Caffora profile screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CafforaApp());

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Alex Morgan'), findsOneWidget);
    expect(find.text('Order history'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
  });

  testWidgets('profile options remain reachable when scrolled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CafforaApp());
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.text('Support'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('appearance option opens the appearance screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CafforaApp());
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Appearance'));
    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('THEME PREFERENCE'), findsOneWidget);
    expect(find.text('System Default'), findsOneWidget);
    expect(find.text('Warm cream & linen aesthetic'), findsOneWidget);

    // Switch to Dark mode
    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.text('Appearance'))).brightness, Brightness.dark);

    // Switch to Light mode
    await tester.tap(find.text('Light').last);
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.text('Appearance'))).brightness, Brightness.light);
  });

  testWidgets('login route renders the Caffora sign-in screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CafforaApp());
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sign out'));
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.login_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('sign out returns to guest home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CafforaApp());
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sign out'));
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Good morning, Alex'), findsOneWidget);
    expect(find.byIcon(Icons.login_outlined), findsOneWidget);
  });

  testWidgets('guest navigation and cart actions require login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(CafforaApp(authController: AuthController.guest()));

    expect(find.text('Cart'), findsNothing);
    expect(find.text('Orders'), findsNothing);
    expect(find.text('Account'), findsNothing);
    expect(find.byIcon(Icons.login_outlined), findsOneWidget);

    final addButton = find.byIcon(Icons.add).first;
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    expect(find.text('Login to place an order.'), findsOneWidget);
  });

  testWidgets('guest add-to-cart prompts for login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(CafforaApp(authController: AuthController.guest()));
    final addButton = find.byIcon(Icons.add).first;
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Login to place an order.'), findsOneWidget);
  });

  testWidgets('john temporary email opens registered user profile', (
    WidgetTester tester,
  ) async {
    final auth = AuthController.guest();
    await tester.pumpWidget(CafforaApp(authController: auth));
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/login');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'john@gmail.com');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('John'), findsOneWidget);
    expect(find.text('john@gmail.com'), findsOneWidget);
    expect(find.text('Your Caffora'), findsOneWidget);
    expect(find.text('Order history'), findsOneWidget);
  });

  testWidgets('abi temporary email opens admin tools', (
    WidgetTester tester,
  ) async {
    final auth = AuthController.guest();
    await tester.pumpWidget(CafforaApp(authController: auth));
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/login');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'abi@gmail.com');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Revenue overview'), findsOneWidget);
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushReplacementNamed('/profile');
    await tester.pumpAndSettle();
    expect(find.text('Abi'), findsOneWidget);
    expect(find.text('abi@gmail.com'), findsOneWidget);
    expect(find.text('Admin tools'), findsOneWidget);
    expect(find.text('Manage menu'), findsOneWidget);
    expect(find.text('Manage orders'), findsOneWidget);
  });

  testWidgets('guest user can toggle color mode from header', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(CafforaApp(authController: AuthController.guest()));

    expect(Theme.of(tester.element(find.text('Good morning, Alex'))).brightness, Brightness.light);

    // Tap quick theme toggle in header
    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pumpAndSettle();

    expect(Theme.of(tester.element(find.text('Good morning, Alex'))).brightness, Brightness.dark);

    // Tap to toggle back to light
    await tester.tap(find.byIcon(Icons.light_mode_outlined));
    await tester.pumpAndSettle();

    expect(Theme.of(tester.element(find.text('Good morning, Alex'))).brightness, Brightness.light);
  });

  testWidgets('guest user can open Appearance and switch theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(CafforaApp(authController: AuthController.guest()));

    // Tap Appearance in guest bottom nav
    await tester.tap(find.text('Appearance').last);
    await tester.pumpAndSettle();

    expect(find.text('THEME PREFERENCE'), findsOneWidget);

    // Select Dark
    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.text('Appearance').first)).brightness, Brightness.dark);

    // Select Light
    await tester.tap(find.text('Light').last);
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.text('Appearance').first)).brightness, Brightness.light);

    // Guest back button returns to Home
    await tester.tap(find.byTooltip('Back to Home'));
    await tester.pumpAndSettle();
    expect(find.text('Good morning, Alex'), findsOneWidget);
  });

  testWidgets('sign in asks for name and displays entered name and email on profile', (
    WidgetTester tester,
  ) async {
    final auth = AuthController.guest();
    await tester.pumpWidget(CafforaApp(authController: auth));
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/login');
    await tester.pumpAndSettle();

    // Enter Name
    await tester.enterText(
      find.widgetWithText(TextField, 'Enter your name'),
      'Sarah Connor',
    );
    // Enter Email
    await tester.enterText(
      find.widgetWithText(TextField, 'you@example.com'),
      'sarah@gmail.com',
    );
    // Enter Password
    await tester.enterText(
      find.widgetWithText(TextField, 'Enter your password'),
      'secret123',
    );

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Sarah Connor'), findsOneWidget);
    expect(find.text('sarah@gmail.com'), findsOneWidget);
    // Ensure Morgan is not appended and dummy email is not used
    expect(find.text('Sarah Connor Morgan'), findsNothing);
    expect(find.text('sarah.morgan@example.com'), findsNothing);
  });

  testWidgets('profile displays guest name and email for guest user', (
    WidgetTester tester,
  ) async {
    final auth = AuthController.guest();
    await tester.pumpWidget(CafforaApp(authController: auth));
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/profile');
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('guest@caffora.com'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('profile displays registered default name and email', (
    WidgetTester tester,
  ) async {
    final auth = AuthController.registered();
    await tester.pumpWidget(CafforaApp(authController: auth));
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/profile');
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Alex Morgan'), findsOneWidget);
    expect(find.text('alex.morgan@example.com'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('profile displays admin name and email', (
    WidgetTester tester,
  ) async {
    final auth = AuthController.admin();
    await tester.pumpWidget(CafforaApp(authController: auth));
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/profile');
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Abi'), findsOneWidget);
    expect(find.text('abi@gmail.com'), findsOneWidget);
    expect(find.text('Admin tools'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });
}
