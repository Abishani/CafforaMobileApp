import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_components.dart';
import '../../data/menu_data.dart';
import '../widgets/menu_components.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _selectedCategory = 'All';
  int _cartCount = 2;

  void _addToCart(MenuProduct product) {
    setState(() => _cartCount++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  void _selectNavigation(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed('/');
    } else if (index == 2) {
      Navigator.of(context).pushReplacementNamed('/cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: HomeHeader(actionLabel: 'Menu'),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            16,
            AppSpacing.page,
            96,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MenuTitleRow(),
              const SizedBox(height: 8),
              const MenuSearchField(),
              const SizedBox(height: 16),
              MenuCategoryChips(
                selected: _selectedCategory,
                onSelected: (category) =>
                    setState(() => _selectedCategory = category),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  for (
                    var index = 0;
                    index < MenuData.products.length;
                    index++
                  ) ...[
                    MenuProductCard(
                      product: MenuData.products[index],
                      onAdd: () => _addToCart(MenuData.products[index]),
                    ),
                    if (index < MenuData.products.length - 1)
                      const SizedBox(height: 16),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CartSummaryBar(
            itemCount: _cartCount,
            total: '\$11.45',
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed('/cart'),
          ),
          const SizedBox(height: 8),
          HomeBottomNavigation(
            selectedIndex: 1,
            onSelected: _selectNavigation,
            cartCount: _cartCount,
          ),
        ],
      ),
    );
  }
}
