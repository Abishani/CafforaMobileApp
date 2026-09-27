import 'package:flutter/material.dart';

import '../../../../core/auth/auth_scope.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_components.dart';
import '../../data/cart_controller.dart';
import '../pages/table_qr_scan_page.dart';
import '../widgets/cart_components.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartController _cart = CartController.instance;

  @override
  void initState() {
    super.initState();
    _cart.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cart.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  void _selectNavigation(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed('/');
    } else if (index == 1) {
      Navigator.of(context).pushReplacementNamed('/menu');
    } else if (index == 3) {
      Navigator.of(context).pushReplacementNamed('/orders');
    } else if (index == 4) {
      Navigator.of(context).pushReplacementNamed('/profile');
    }
  }

  Future<void> _scanTableQr() async {
    final result = await Navigator.of(context).push<QrScanResult>(
      MaterialPageRoute(
        builder: (_) => const TableQrScanPage(mode: QrScanMode.table),
      ),
    );
    if (result is TableScanResult) {
      final codeToResolve = result.rawCode ?? result.tableNumber;
      await _cart.resolveTableFromCode(codeToResolve);
      _cart.setTable(_cart.tableId, result.tableNumber);
    }
  }

  Future<void> _handlePlaceOrder() async {
    final auth = AuthScope.maybeOf(context);
    if (auth?.isGuest ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to place an order.'),
          duration: Duration(milliseconds: 1500),
        ),
      );
      Navigator.of(context).pushNamed('/login');
      return;
    }

    try {
      final order = await _cart.placeOrder();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order #${order.orderNumber} placed successfully!'),
          backgroundColor: AppColors.accentDark,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pushReplacementNamed('/orders');
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to place order. Check network connection.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final items = _cart.items;
    final quantities = items.map((i) => i.quantity).toList();
    final itemCount = _cart.itemCount;

    return Scaffold(
      backgroundColor: palette.background,
      extendBody: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: HomeHeader(showActionLabel: false),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            8,
            AppSpacing.page,
            130,
          ),
          child: Column(
            children: [
              CartTopBar(
                onBack: () =>
                    Navigator.of(context).pushReplacementNamed('/menu'),
                onTable: _scanTableQr,
                tableNumber: _cart.tableNumber,
              ),
              const SizedBox(height: 8),
              ServiceModeToggle(
                isDineIn: _cart.isDineIn,
                tableNumber: _cart.tableNumber,
                onChanged: (value) => _cart.setDineIn(value),
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: palette.border),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 54, color: palette.muted),
                      const SizedBox(height: 16),
                      Text(
                        'Your bag is empty',
                        style: TextStyle(
                          color: palette.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Explore our handcrafted coffee and fresh pastries.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: palette.body, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/menu'),
                        style: FilledButton.styleFrom(
                          backgroundColor: palette.accentDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Browse Menu'),
                      ),
                    ],
                  ),
                )
              else ...[
                CartItemsCard(
                  items: items,
                  quantities: quantities,
                  onDecrease: (index) => _cart.changeQuantity(index, -1),
                  onIncrease: (index) => _cart.changeQuantity(index, 1),
                  onRemove: (index) => _cart.removeItem(index),
                ),
                const SizedBox(height: 16),
                PaymentMethodSelectorCard(
                  selectedMethod: _cart.paymentMethod,
                  onChanged: (val) => _cart.setPaymentMethod(val),
                ),
                const SizedBox(height: 16),
                OrderSummaryCard(
                  tip: _cart.tipPercentage,
                  subtotal: _cart.subtotal,
                  tax: _cart.tax,
                  total: _cart.total,
                  onTipChanged: (value) => _cart.setTipPercentage(value),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: PlaceOrderButton(
                    tableNumber: _cart.tableNumber,
                    total: _cart.total,
                    isLoading: _cart.isSubmitting,
                    isDineIn: _cart.isDineIn,
                    onPressed: _handlePlaceOrder,
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        selectedIndex: 2,
        onSelected: _selectNavigation,
        cartCount: itemCount,
      ),
    );
  }
}
