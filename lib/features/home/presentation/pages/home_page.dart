import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/auth_scope.dart';
import '../../data/home_data.dart';
import '../widgets/home_components.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavigationIndex = 0;
  int _cartCount = 2;

  void _addToCart(HomeProduct product) {
    setState(() => _cartCount++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  void _showOrderMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pickup ordering is ready to explore'),
        duration: Duration(milliseconds: 900),
      ),
    );
  }

  void _selectNavigation(int index) {
    final role = AuthScope.maybeOf(context)?.role ?? UserRole.registered;
    if (role == UserRole.guest) {
      if (index == 1) {
        Navigator.of(context).pushReplacementNamed('/menu');
      } else if (index == 2) {
        Navigator.of(context).pushReplacementNamed('/appearance');
      }
      return;
    }
    if (role == UserRole.admin) {
      switch (index) {
        case 1:
          Navigator.of(context).pushReplacementNamed('/menu');
        case 2:
          Navigator.of(context).pushReplacementNamed('/orders');
        case 3:
          Navigator.of(context).pushReplacementNamed('/profile');
      }
      return;
    }
    if (index == 1) {
      Navigator.of(context).pushReplacementNamed('/menu');
      return;
    }
    if (index == 2) {
      Navigator.of(context).pushReplacementNamed('/cart');
      return;
    }
    if (index == 3) {
      Navigator.of(context).pushReplacementNamed('/orders');
      return;
    }
    if (index == 4) {
      Navigator.of(context).pushReplacementNamed('/profile');
      return;
    }
    setState(() => _selectedNavigationIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final displayName = AuthScope.maybeOf(context)?.displayName ?? 'Alex';

    return Scaffold(
      backgroundColor: palette.background,
      extendBody: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: HomeHeader(showNotifications: true),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            8,
            AppSpacing.page,
            96,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, $displayName',
                style: TextStyle(
                  color: palette.ink,
                  fontSize: 22,
                  height: 28 / 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.55,
                ),
              ),
              const SizedBox(height: 16),
              const HomeSearchBar(),
              const SizedBox(height: 24),
              PickupBanner(onOrder: _showOrderMessage),
              const SizedBox(height: AppSpacing.section),
              HomeSection(
                title: 'Popular Drinks',
                subtitle: 'Signature brews curated daily',
                products: HomeData.drinks,
                onAdd: _addToCart,
              ),
              const SizedBox(height: AppSpacing.section),
              HomeSection(
                title: 'Bakery & Treats',
                subtitle: 'Baked fresh in-house every morning',
                products: HomeData.bakery,
                onAdd: _addToCart,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        selectedIndex: _selectedNavigationIndex,
        onSelected: _selectNavigation,
        cartCount: _cartCount,
      ),
    );
  }
}
