import 'package:flutter/material.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/auth_scope.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../cart/data/cart_controller.dart';
import '../../../home/presentation/widgets/home_components.dart';
import '../../data/menu_data.dart';
import '../widgets/menu_components.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    MenuData.productsNotifier.addListener(_onMenuUpdated);
    CartController.instance.addListener(_onCartUpdated);
    _loadMenu();
  }

  @override
  void dispose() {
    MenuData.productsNotifier.removeListener(_onMenuUpdated);
    CartController.instance.removeListener(_onCartUpdated);
    _searchController.dispose();
    super.dispose();
  }

  void _onMenuUpdated() {
    if (mounted) setState(() {});
  }

  void _onCartUpdated() {
    if (mounted) setState(() {});
  }

  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);
    await Future.wait([
      MenuData.loadCategories(),
      MenuData.loadProducts(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _addToCart(MenuProduct product) {
    final auth = AuthScope.maybeOf(context);
    if (auth?.isGuest ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to add items to your cart.'),
          duration: Duration(milliseconds: 1500),
        ),
      );
      Navigator.of(context).pushNamed('/login');
      return;
    }

    CartController.instance.addItem(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  void _selectNavigation(int index) {
    final role = AuthScope.maybeOf(context)?.role ?? UserRole.registered;
    if (role == UserRole.guest) {
      if (index == 0) {
        Navigator.of(context).pushReplacementNamed('/');
      }
      return;
    }
    if (role == UserRole.admin) {
      switch (index) {
        case 0:
          Navigator.of(context).pushReplacementNamed('/');
        case 2:
          Navigator.of(context).pushReplacementNamed('/orders');
        case 3:
          Navigator.of(context).pushReplacementNamed('/profile');
      }
      return;
    }
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/cart');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/orders');
        break;
      case 4:
        Navigator.of(context).pushReplacementNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final role = AuthScope.maybeOf(context)?.role ?? UserRole.registered;
    final cart = CartController.instance;

    // Build category list
    final categoryNames = <String>['All'];
    for (final c in MenuData.categories) {
      if (!categoryNames.contains(c.name)) {
        categoryNames.add(c.name);
      }
    }
    if (categoryNames.length <= 1) {
      categoryNames.addAll(['Beverages', 'Snacks', 'Meals', 'Desserts']);
    }

    // Filter products
    final allProducts = MenuData.products;
    final filtered = allProducts.where((p) {
      final matchesCategory = _selectedCategory == 'All' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase() ||
          (_selectedCategory == 'Coffee' && p.category.toLowerCase().contains('beverage'));
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: palette.background,
      extendBody: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: HomeHeader(showActionLabel: false),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: palette.accentDark,
          onRefresh: _loadMenu,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                MenuSearchField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
                const SizedBox(height: 16),
                MenuCategoryChips(
                  selected: _selectedCategory,
                  categories: categoryNames,
                  onSelected: (category) =>
                      setState(() => _selectedCategory = category),
                ),
                const SizedBox(height: 16),
                if (_isLoading && filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: palette.accentDark),
                    ),
                  )
                else if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No menu items found in this category.',
                        style: TextStyle(color: palette.muted, fontSize: 14),
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (var index = 0; index < filtered.length; index++) ...[
                        MenuProductCard(
                          product: filtered[index],
                          onAdd: () => _addToCart(filtered[index]),
                        ),
                        if (index < filtered.length - 1)
                          const SizedBox(height: 16),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (role == UserRole.registered) ...[
            CartSummaryBar(
              itemCount: cart.itemCount > 0 ? cart.itemCount : 2,
              total: cart.itemCount > 0
                  ? '\$${cart.total.toStringAsFixed(2)}'
                  : '\$11.45',
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/cart'),
            ),
            const SizedBox(height: 8),
          ],
          HomeBottomNavigation(
            selectedIndex: 1,
            onSelected: _selectNavigation,
            cartCount: cart.itemCount,
          ),
        ],
      ),
    );
  }
}
