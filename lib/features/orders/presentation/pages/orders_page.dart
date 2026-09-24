import 'package:flutter/material.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/auth_scope.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_components.dart';
import '../../data/order_repository.dart';
import '../../data/orders_data.dart';
import '../widgets/admin_manage_orders_view.dart';
import '../widgets/orders_components.dart';
import '../widgets/pickup_qr_sheet.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  bool _showActive = true;
  bool _isCustomerView = false;
  List<OrderListItem> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final auth = AuthScope.maybeOf(context);
    final repo = OrderRepository(role: auth?.role ?? UserRole.registered);
    final list = await repo.fetchOrders();
    if (mounted) {
      setState(() {
        _orders = list;
        _isLoading = false;
      });
    }
  }

  void _selectNavigation(int index) {
    final isAdmin = AuthScope.maybeOf(context)?.isAdmin ?? false;
    if (isAdmin) {
      switch (index) {
        case 0:
          Navigator.of(context).pushReplacementNamed('/');
          break;
        case 1:
          Navigator.of(context).pushReplacementNamed('/menu');
          break;
        case 2:
          if (_isCustomerView) {
            setState(() => _isCustomerView = false);
          }
          break;
        case 3:
          Navigator.of(context).pushReplacementNamed('/profile');
          break;
      }
      return;
    }

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/menu');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/cart');
        break;
      case 3:
        break;
      case 4:
        Navigator.of(context).pushReplacementNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final isAdmin = AuthScope.maybeOf(context)?.isAdmin ?? false;

    // ── Admin: Cafe Manager View ──────────────────────────────
    if (isAdmin && !_isCustomerView) {
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
              16,
              AppSpacing.page,
              96,
            ),
            child: AdminManageOrdersView(
              onSwitchToCustomerView: () =>
                  setState(() => _isCustomerView = true),
            ),
          ),
        ),
        bottomNavigationBar: HomeBottomNavigation(
          selectedIndex: 2,
          onSelected: _selectNavigation,
          cartCount: 0,
        ),
      );
    }

    // ── Customer View ────
    final activeOrders = _orders
        .where((o) =>
            o.status.toLowerCase() != 'completed' &&
            o.status.toLowerCase() != 'cancelled')
        .toList();

    final pastOrders = _orders
        .where((o) =>
            o.status.toLowerCase() == 'completed' ||
            o.status.toLowerCase() == 'cancelled')
        .toList();

    final displayedOrders = _showActive ? activeOrders : pastOrders;

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
          onRefresh: _loadOrders,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              4,
              AppSpacing.page,
              96,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAdmin && _isCustomerView) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: palette.isDark
                          ? const Color(0xFF2B211B)
                          : const Color(0xFFF7E6DE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: palette.accentDark),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.visibility_outlined,
                                size: 16, color: palette.accentDark),
                            const SizedBox(width: 8),
                            Text(
                              'Customer View Preview',
                              style: TextStyle(
                                color: palette.ink,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () =>
                              setState(() => _isCustomerView = false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Back to Cafe Manager →',
                            style: TextStyle(
                              color: palette.accentDark,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Center(child: OfflineBanner()),
                const SizedBox(height: 16),
                Text(
                  'My Orders',
                  style: TextStyle(
                    color: palette.ink,
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
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(
                      color: palette.accentDark,
                      minHeight: 2,
                    ),
                  ),
                const SizedBox(height: 16),
                if (_showActive) ...[
                  ActiveOrderCard(
                    order: OrdersData.activeOrder,
                    onQr: () => showPickupQrSheet(
                      context,
                      orderId: OrdersData.activeOrder.orderId,
                      orderLabel:
                          'Order #${OrdersData.activeOrder.orderId} • Dine-In',
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.fromBorderSide(
                        BorderSide(color: palette.border),
                      ),
                    ),
                    child: Text(
                      'Past orders are available offline.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: palette.body, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                  for (final order in displayedOrders) ...[
                    GestureDetector(
                      onTap: () => Navigator.of(context)
                          .pushNamed('/order-detail', arguments: order.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: palette.border),
                          boxShadow: [
                            BoxShadow(color: palette.cardShadow, blurRadius: 2)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.receipt_outlined,
                                      size: 16,
                                      color: palette.accentDark,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      order.orderNumber != null &&
                                              order.orderNumber!.isNotEmpty
                                          ? order.orderNumber!
                                          : 'Order #${order.id}',
                                      style: TextStyle(
                                        color: palette.ink,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: palette.chipSurface,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    order.status,
                                    style: TextStyle(
                                      color: palette.accentDark,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${order.itemCount} items • ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                      color: palette.body, fontSize: 13),
                                ),
                                Text(
                                  '\$${order.total.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: palette.ink,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (_showActive) ...[
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => showPickupQrSheet(
                                      context,
                                      orderId: order.id,
                                      orderLabel:
                                          '${order.orderNumber ?? 'Order #${order.id}'} • Pickup',
                                    ),
                                    icon: const Icon(Icons.qr_code, size: 16),
                                    label: const Text('Show QR'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: palette.accentDark,
                                      side: BorderSide(
                                          color: palette.accentDark),
                                      visualDensity: VisualDensity.compact,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton(
                                    onPressed: () => Navigator.of(context)
                                        .pushNamed('/order-detail',
                                            arguments: order.id),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: palette.accentDark,
                                      foregroundColor: Colors.white,
                                      visualDensity: VisualDensity.compact,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Track Order'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        selectedIndex: isAdmin ? 2 : 3,
        onSelected: _selectNavigation,
        cartCount: 0,
      ),
    );
  }
}
