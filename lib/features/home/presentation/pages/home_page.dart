import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/auth_scope.dart';
import '../../../cart/data/cart_controller.dart';
import '../../../cart/presentation/pages/table_qr_scan_page.dart';
import '../../../menu/data/menu_data.dart';
import '../../data/home_data.dart';
import '../../../profile/data/contact_invite_service.dart';
import '../widgets/home_components.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavigationIndex = 0;
  String _searchQuery = '';
  String _selectedHomeCategory = 'All';

  static const _homeCategories = ['All', 'Drinks', 'Bakery'];

  @override
  void initState() {
    super.initState();
    CartController.instance.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CartController.instance.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleScanTableQr() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final result = await nav.push<QrScanResult>(
      MaterialPageRoute(
        builder: (_) => const TableQrScanPage(mode: QrScanMode.table),
      ),
    );
    if (result is TableScanResult && mounted) {
      final codeToResolve = result.rawCode ?? result.tableNumber;
      await CartController.instance.resolveTableFromCode(codeToResolve);
      CartController.instance.setTable(CartController.instance.tableId, result.tableNumber);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.table_restaurant, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Table #${result.tableNumber} checked in! Browse menu to order.'),
              ),
            ],
          ),
          backgroundColor: AppColors.accentDark,
          duration: const Duration(seconds: 2),
        ),
      );
      nav.pushReplacementNamed('/menu');
    }
  }

  Future<void> _handleInviteFriend() async {
    await ContactInviteService.instance.openInviteHub(context);
  }

  void _addToCart(HomeProduct product) {
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

    CartController.instance.addItem(MenuProduct(
      name: product.name,
      description: product.description,
      price: product.price,
      image: product.image,
      category: 'Coffee',
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  void _showOrderMessage() {
    Navigator.of(context).pushReplacementNamed('/menu');
  }

  Future<void> _showHomeFilters() async {
    final selectedCategory = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Filter menu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            for (final category in _homeCategories)
              ListTile(
                title: Text(category),
                trailing: _selectedHomeCategory == category
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(context, category),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (selectedCategory != null && mounted) {
      setState(() => _selectedHomeCategory = selectedCategory);
    }
  }

  List<HomeProduct> _matchingProducts(
    List<HomeProduct> products, {
    required String categoryKeyword,
  }) {
    final query = _searchQuery.toLowerCase();
    return products.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          categoryKeyword
              .split(' ')
              .any((keyword) => keyword.startsWith(query));
    }).toList();
  }

  void _selectNavigation(int index) {
    final role = AuthScope.maybeOf(context)?.role ?? UserRole.registered;
    if (role == UserRole.guest) {
      if (index == 1) {
        Navigator.of(context).pushReplacementNamed('/menu');
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
    final role = AuthScope.maybeOf(context)?.role ?? UserRole.registered;
    final isGuest = role == UserRole.guest;
    final isRegisteredUser = role == UserRole.registered;
    final drinks = _selectedHomeCategory == 'Bakery'
      ? <HomeProduct>[]
      : _matchingProducts(HomeData.drinks, categoryKeyword: 'coffee drinks espresso');
    final bakery = _selectedHomeCategory == 'Drinks'
      ? <HomeProduct>[]
      : _matchingProducts(HomeData.bakery, categoryKeyword: 'bakery pastries');

    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;
    final horizontalPadding = isTablet ? 36.0 : AppSpacing.page;

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
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            8,
            horizontalPadding,
            120,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeSearchBar(
                    onChanged: (query) => setState(() => _searchQuery = query.trim()),
                    onFilterTap: _showHomeFilters,
                  ),
                  const SizedBox(height: 16),
                  if (isRegisteredUser) ...[
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _handleScanTableQr,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: palette.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: palette.border),
                                boxShadow: [
                                  BoxShadow(
                                    color: palette.cardShadow,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: palette.accentDark.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.qr_code_scanner,
                                      color: palette.accentDark,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Scan Table QR',
                                          style: TextStyle(
                                            color: palette.ink,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          'Dine-in order',
                                          style: TextStyle(
                                            color: palette.body,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _handleInviteFriend,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: palette.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: palette.border),
                                boxShadow: [
                                  BoxShadow(
                                    color: palette.cardShadow,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4C8A65).withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_add_alt_1,
                                      color: Color(0xFF4C8A65),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Invite a Friend',
                                          style: TextStyle(
                                            color: palette.ink,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          'Get 20% off',
                                          style: TextStyle(
                                            color: palette.body,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (!isGuest) ...[
                    PickupBanner(onOrder: _showOrderMessage),
                    const SizedBox(height: AppSpacing.section),
                  ],
                  if (drinks.isNotEmpty)
                    HomeSection(
                        title: 'Popular Drinks',
                        subtitle: 'Signature brews curated daily',
                        products: drinks,
                        onAdd: _addToCart,
                      ),
                  if (drinks.isNotEmpty && bakery.isNotEmpty)
                    const SizedBox(height: AppSpacing.section),
                  if (bakery.isNotEmpty)
                    HomeSection(
                        title: 'Bakery & Treats',
                        subtitle: 'Baked fresh in-house every morning',
                        products: bakery,
                        onAdd: _addToCart,
                      ),
                  if (drinks.isEmpty && bakery.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'No matching items found',
                          style: TextStyle(color: palette.body),
                        ),
                      ),
                    ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        selectedIndex: _selectedNavigationIndex,
        onSelected: _selectNavigation,
        cartCount: CartController.instance.itemCount,
      ),
    );
  }
}
