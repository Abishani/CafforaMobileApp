import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_components.dart';
import '../../data/cart_data.dart';
import '../widgets/cart_components.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<CartItem> _items = List<CartItem>.of(CartData.items);
  final List<int> _quantities = [1, 1];
  bool _isDineIn = true;
  int _tip = 18;

  void _changeQuantity(int index, int delta) {
    setState(() {
      _quantities[index] = (_quantities[index] + delta).clamp(1, 9);
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _quantities.removeAt(index);
    });
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

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final itemCount = _quantities.fold<int>(
      0,
      (sum, quantity) => sum + quantity,
    );
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
            112,
          ),
          child: Column(
            children: [
              CartTopBar(
                onBack: () =>
                    Navigator.of(context).pushReplacementNamed('/menu'),
                onTable: () {},
              ),
              const SizedBox(height: 8),
              ServiceModeToggle(
                isDineIn: _isDineIn,
                onChanged: (value) => setState(() => _isDineIn = value),
              ),
              const SizedBox(height: 16),
              CartItemsCard(
                items: _items,
                quantities: _quantities,
                onDecrease: (index) => _changeQuantity(index, -1),
                onIncrease: (index) => _changeQuantity(index, 1),
                onRemove: _removeItem,
              ),
              const SizedBox(height: 16),
              OrderSummaryCard(
                tip: _tip,
                onTipChanged: (value) => setState(() => _tip = value),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PlaceOrderButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed('/orders'),
                ),
              ),
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
