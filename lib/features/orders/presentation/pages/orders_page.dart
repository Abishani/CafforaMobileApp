import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_components.dart';
import '../../data/orders_data.dart';
import '../widgets/orders_components.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  bool _showActive = true;

  void _selectNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/');
      case 1:
        Navigator.of(context).pushReplacementNamed('/menu');
      case 2:
        Navigator.of(context).pushReplacementNamed('/cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: HomeHeader(actionLabel: 'Orders'),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            4,
            AppSpacing.page,
            96,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: OfflineBanner()),
              const SizedBox(height: 16),
              const Text(
                'My Orders',
                style: TextStyle(
                  fontSize: 22,
                  height: 28 / 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -.55,
                ),
              ),
              const SizedBox(height: 16),
              OrdersTabs(
                showActive: _showActive,
                onChanged: (value) => setState(() => _showActive = value),
              ),
              const SizedBox(height: 16),
              if (_showActive)
                ActiveOrderCard(
                  order: OrdersData.activeOrder,
                  onQr: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pickup QR is ready'),
                      duration: Duration(milliseconds: 900),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: const Border.fromBorderSide(
                      BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: const Text(
                    'Past orders are available offline.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.body, fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        selectedIndex: 3,
        onSelected: _selectNavigation,
        cartCount: 2,
      ),
    );
  }
}
