import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/menu/presentation/pages/menu_page.dart';
import 'features/cart/presentation/pages/cart_page.dart';
import 'features/orders/presentation/pages/orders_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/appearance/presentation/pages/appearance_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/admin/presentation/pages/admin_page.dart';

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
        '/orders': (_) => const OrdersPage(),
        '/profile': (_) => const ProfilePage(),
        '/appearance': (_) => const AppearancePage(),
        '/login': (_) => const LoginPage(),
        '/admin': (_) => const AdminPage(),
      },
      initialRoute: '/',
    );
  }
}
