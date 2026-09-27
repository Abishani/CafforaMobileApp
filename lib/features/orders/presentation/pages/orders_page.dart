import 'package:flutter/material.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/auth_scope.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_components.dart';
import '../../data/order_repository.dart';
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
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final auth = AuthScope.maybeOf(context);
    // Only load for registered users (admin has its own view)
    if (auth?.isAdmin ?? false) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final repo = OrderRepository(role: auth?.role ?? UserRole.registered);
      final list = await repo.fetchOrders();
      if (mounted) {
        setState(() {
          _orders = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Could not load orders. Pull down to retry.';
        });
      }
    }
  }

  void _selectNavigation(int index) {
    final isAdmin = AuthScope.maybeOf(context)?.isAdmin ?? false;
    if (isAdmin) {
      switch (index) {
        case 0:
          Navigator.of(context).pushReplacementNamed('/');
        case 1:
          Navigator.of(context).pushReplacementNamed('/menu');
        case 2:
          if (_isCustomerView) setState(() => _isCustomerView = false);
        case 3:
          Navigator.of(context).pushReplacementNamed('/profile');
      }
      return;
    }

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/');
      case 1:
        Navigator.of(context).pushReplacementNamed('/menu');
      case 2:
        Navigator.of(context).pushReplacementNamed('/cart');
      case 3:
        break; // Already on orders
      case 4:
        Navigator.of(context).pushReplacementNamed('/profile');
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

    // ── Registered customer order lists ──────────────────────
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
              16,
              AppSpacing.page,
              130,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin "Customer View" back banner
                if (isAdmin && _isCustomerView) ...[
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

                // Error state
                if (_error != null && !_isLoading)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: palette.border),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.cloud_off_outlined,
                            size: 42, color: palette.muted),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: palette.body, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _loadOrders,
                          icon: Icon(Icons.refresh,
                              size: 16, color: palette.accentDark),
                          label: Text('Retry',
                              style: TextStyle(color: palette.accentDark)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: palette.accentDark),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  )

                // Empty state
                else if (!_isLoading && displayedOrders.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 48, horizontal: 24),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: palette.border),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _showActive
                              ? Icons.receipt_long_outlined
                              : Icons.history_outlined,
                          size: 52,
                          color: palette.muted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showActive
                              ? 'No active orders'
                              : 'No past orders yet',
                          style: TextStyle(
                            color: palette.ink,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _showActive
                              ? 'Place your first order from the menu!'
                              : 'Completed orders will appear here.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: palette.body, fontSize: 13),
                        ),
                        if (_showActive) ...[
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () => Navigator.of(context)
                                .pushReplacementNamed('/menu'),
                            icon: const Icon(Icons.coffee_outlined, size: 18),
                            label: const Text('Browse Menu'),
                            style: FilledButton.styleFrom(
                              backgroundColor: palette.accentDark,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )

                // Order list
                else
                  for (final order in displayedOrders) ...[
                    _OrderCard(
                      order: order,
                      showActive: _showActive,
                      onTrack: () => Navigator.of(context)
                          .pushNamed('/order-detail', arguments: order.id),
                      onQr: () => showPickupQrSheet(
                        context,
                        orderId: order.id,
                        orderLabel:
                            '${order.orderNumber ?? 'Order #${order.id}'} • Pickup',
                      ),
                    ),
                  ],
                const SizedBox(height: 36),
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

// ─────────────────────────────────────────────────────────────
// Order card widget
// ─────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.showActive,
    required this.onTrack,
    required this.onQr,
  });

  final OrderListItem order;
  final bool showActive;
  final VoidCallback onTrack;
  final VoidCallback onQr;

  Color _statusColor(BuildContext context, String status) {
    final s = status.toLowerCase();
    if (s == 'completed') return const Color(0xFF16A34A);
    if (s == 'cancelled') return Colors.red.shade600;
    if (s == 'ready') return const Color(0xFF0369A1);
    if (s == 'preparing') return const Color(0xFFB45309);
    return context.appColors.accentDark;
  }

  IconData _statusIcon(String status) {
    final s = status.toLowerCase();
    if (s == 'completed') return Icons.check_circle_outline;
    if (s == 'cancelled') return Icons.cancel_outlined;
    if (s == 'ready') return Icons.done_all;
    if (s == 'preparing') return Icons.local_fire_department_outlined;
    return Icons.hourglass_bottom_outlined;
  }

  String _paymentLabel(String? method) {
    if (method == null) return 'Cash';
    final m = method.toUpperCase();
    if (m.contains('CARD')) return 'Card';
    if (m.contains('WALLET') || m.contains('MOBILE')) return 'Mobile Wallet';
    return 'Cash';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final statusColor = _statusColor(context, order.status);

    return GestureDetector(
      onTap: onTrack,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: palette.border),
          boxShadow: [
            BoxShadow(color: palette.cardShadow, blurRadius: 3, offset: const Offset(0, 1))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: order number + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.receipt_outlined,
                          size: 16, color: palette.accentDark),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          order.orderNumber?.isNotEmpty == true
                              ? order.orderNumber!
                              : 'Order #${order.id}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.ink,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(order.status),
                          size: 11, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        order.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Items count + time + payment
            Row(
              children: [
                Icon(Icons.shopping_bag_outlined,
                    size: 13, color: palette.body),
                const SizedBox(width: 4),
                Text(
                  '${order.itemCount} item${order.itemCount != 1 ? 's' : ''}',
                  style: TextStyle(color: palette.body, fontSize: 12),
                ),
                const SizedBox(width: 12),
                Icon(Icons.access_time_outlined, size: 13, color: palette.body),
                const SizedBox(width: 4),
                Text(
                  '${order.createdAt.day}/${order.createdAt.month}  ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: palette.body, fontSize: 12),
                ),
                const Spacer(),
                if (order.paymentMethod != null) ...[
                  Icon(Icons.payment_outlined, size: 13, color: palette.body),
                  const SizedBox(width: 4),
                  Text(
                    _paymentLabel(order.paymentMethod),
                    style: TextStyle(color: palette.body, fontSize: 12),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),

            // Amount row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount to pay',
                  style: TextStyle(color: palette.body, fontSize: 13),
                ),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Action buttons for active orders only
            if (showActive) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Show QR – only for non-completed active orders
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onQr,
                      icon: const Icon(Icons.qr_code, size: 15),
                      label: const Text('Show QR'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: palette.accentDark,
                        side: BorderSide(color: palette.accentDark),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onTrack,
                      icon: const Icon(Icons.track_changes_outlined, size: 15),
                      label: const Text('Track Order'),
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.accentDark,
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
