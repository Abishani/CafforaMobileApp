import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/menu/presentation/pages/menu_page.dart';
import 'features/cart/presentation/pages/cart_page.dart';

void main() {
  runApp(const CafforaApp());
}

class CafforaApp extends StatelessWidget {
  const CafforaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caffora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routes: {
        '/': (_) => const HomePage(),
        '/menu': (_) => const MenuPage(),
        '/cart': (_) => const CartPage(),
      },
      initialRoute: '/',
    );
  }
}
