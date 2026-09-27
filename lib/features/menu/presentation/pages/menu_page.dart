import 'package:flutter/material.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/auth_scope.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../admin/presentation/pages/add_food_item_page.dart';
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
    MenuData.isOfflineNotifier.addListener(_onMenuUpdated);
    CartController.instance.addListener(_onCartUpdated);
    _loadMenu();
  }

  @override
  void dispose() {
    MenuData.productsNotifier.removeListener(_onMenuUpdated);
    MenuData.isOfflineNotifier.removeListener(_onMenuUpdated);
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

  Future<void> _openAddFoodItem() async {
    final newItem = await Navigator.of(context).push<MenuProduct>(
      MaterialPageRoute(builder: (_) => const AddFoodItemPage()),
    );
    if (newItem != null && mounted) {
      _loadMenu();
    }
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
    final isOffline = MenuData.isOfflineNotifier.value;
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;
    final horizontalPadding = isTablet ? 36.0 : AppSpacing.page;

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
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              120,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MenuTitleRow(onAddItem: _openAddFoodItem),
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
                    if (isOffline) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: palette.isDark
                              ? const Color(0xFF2C221D)
                              : const Color(0xFFFBF2EB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: palette.accentDark.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.wifi_off_rounded, size: 20, color: palette.accentDark),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                filtered.isNotEmpty
                                    ? 'Offline Mode • Showing cached menu items.'
                                    : 'Offline Mode • Live menu unavailable.',
                                style: TextStyle(
                                  color: palette.accentDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _loadMenu,
                              icon: const Icon(Icons.refresh, size: 14),
                              label: const Text('Retry'),
                              style: TextButton.styleFrom(
                                foregroundColor: palette.accentDark,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_isLoading && filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(color: palette.accentDark),
                        ),
                      )
                    else if (filtered.isEmpty && isOffline)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: palette.border),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: palette.accentDark.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.wifi_off_rounded, size: 48, color: palette.accentDark),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'You are currently offline',
                              style: TextStyle(
                                color: palette.ink,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Menu contents cannot be displayed right now without an active connection. Please check your internet connection and try again.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: palette.body, fontSize: 13, height: 1.4),
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: _loadMenu,
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Retry Connection'),
                              style: FilledButton.styleFrom(
                                backgroundColor: palette.accentDark,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
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
                    const SizedBox(height: 36),
                  ],
                ),
              ),
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
