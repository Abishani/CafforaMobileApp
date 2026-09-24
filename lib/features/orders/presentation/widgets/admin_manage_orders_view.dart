import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../menu/data/menu_data.dart';
import '../../data/cafe_orders_data.dart';

class AdminManageOrdersView extends StatefulWidget {
  const AdminManageOrdersView({
    super.key,
    required this.onSwitchToCustomerView,
  });

  final VoidCallback onSwitchToCustomerView;

  @override
  State<AdminManageOrdersView> createState() => _AdminManageOrdersViewState();
}

class _AdminManageOrdersViewState extends State<AdminManageOrdersView> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    CafeOrdersData.ordersNotifier.addListener(_onOrdersChanged);
    CafeOrdersData.loadOrdersQueue();
  }

  @override
  void dispose() {
    CafeOrdersData.ordersNotifier.removeListener(_onOrdersChanged);
    super.dispose();
  }

  void _onOrdersChanged() {
    if (mounted) setState(() {});
  }

  void _updateStatus(CafeOrder order, String newStatus) {
    CafeOrdersData.updateOrderStatus(order.id, newStatus);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order #${order.id} marked as $newStatus'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  void _advanceOrder(CafeOrder order) {
    switch (order.status) {
      case 'Pending':
        _updateStatus(order, 'Preparing');
        break;
      case 'Preparing':
        _updateStatus(order, 'Ready');
        break;
      case 'Ready':
        _updateStatus(order, 'Completed');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final allOrders = CafeOrdersData.ordersNotifier.value;
    final activeOrdersCount =
        allOrders.where((o) => o.status != 'Completed').length;

    final filteredOrders = allOrders.where((o) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Active') return o.status != 'Completed';
      return o.status.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Title & Top Badges ────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cafe\nManager',
              style: TextStyle(
                color: palette.ink,
                fontSize: 30,
                height: 34 / 30,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.8,
              ),
            ),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: palette.isDark
                        ? const Color(0xFF2B211B)
                        : const Color(0xFFF7E6DE),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: palette.isDark
                          ? palette.border
                          : const Color(0xFFE8D0C5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Floor Live',
                        style: TextStyle(
                          color: palette.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: widget.onSwitchToCustomerView,
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: palette.isDark
                          ? const Color(0xFF2B211B)
                          : const Color(0xFFF7E6DE),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: palette.isDark
                            ? palette.border
                            : const Color(0xFFE8D0C5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.storefront_outlined,
                          size: 15,
                          color: palette.accentDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Customer View',
                          style: TextStyle(
                            color: palette.ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),

        // ── Active Orders Summary Banner ────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: palette.isDark
                ? const Color(0xFF221A16)
                : const Color(0xFFFFF6F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            children: [
              Icon(Icons.bolt, color: palette.accentDark, size: 18),
              const SizedBox(width: 8),
              Text(
                '$activeOrdersCount Active Orders • Avg 4m prep',
                style: TextStyle(
                  color: palette.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                tooltip: 'Filter orders',
                initialValue: _selectedFilter,
                onSelected: (val) => setState(() => _selectedFilter = val),
                icon: Icon(Icons.tune, color: palette.accentDark, size: 18),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'All', child: Text('All Orders')),
                  PopupMenuItem(value: 'Active', child: Text('Active Only')),
                  PopupMenuItem(value: 'Pending', child: Text('Pending Only')),
                  PopupMenuItem(
                      value: 'Preparing', child: Text('Preparing Only')),
                  PopupMenuItem(value: 'Ready', child: Text('Ready Only')),
                  PopupMenuItem(
                      value: 'Completed', child: Text('Completed Only')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Two Stat Cards ──────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: palette.isDark
                      ? const Color(0xFF221A16)
                      : const Color(0xFFFFF6F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: palette.accentDark,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Live Orders',
                          style: TextStyle(
                            color: palette.body,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$activeOrdersCount',
                      style: TextStyle(
                        color: palette.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: palette.isDark
                      ? const Color(0xFF221A16)
                      : const Color(0xFFFFF6F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: palette.accentDark,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Menu Items',
                          style: TextStyle(
                            color: palette.body,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${MenuData.products.length}',
                      style: TextStyle(
                        color: palette.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // ── Order Cards List ────────────────────────────────────
        if (filteredOrders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              children: [
                Icon(Icons.done_all, size: 40, color: palette.muted),
                const SizedBox(height: 8),
                Text(
                  'No orders under $_selectedFilter',
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          for (final order in filteredOrders) ...[
            _buildOrderCard(order, palette),
            const SizedBox(height: 14),
          ],
      ],
    );
  }

  Widget _buildOrderCard(CafeOrder order, dynamic palette) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.isDark
            ? const Color(0xFF221A16)
            : const Color(0xFFFFF6F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: palette.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: #110 | Dine-in | Sarah K. | $5.50
          Row(
            children: [
              Text(
                '#${order.id}',
                style: TextStyle(
                  color: palette.accentDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: palette.isDark
                      ? const Color(0xFF2B211B)
                      : const Color(0xFFF4DDD2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.orderType,
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.customerName,
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
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
          const SizedBox(height: 12),

          // Items list
          for (final item in order.items) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text(
                    '${item.quantity}x ',
                    style: TextStyle(
                      color: palette.accentDark,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        color: palette.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (item.customization != null)
                    Text(
                      item.customization!,
                      style: TextStyle(
                        color: palette.muted,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Status & Action button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status with popup dropdown
              PopupMenuButton<String>(
                tooltip: 'Change status',
                onSelected: (val) => _updateStatus(order, val),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'Pending',
                    child: Text('🕒 Pending (Not Started)'),
                  ),
                  PopupMenuItem(
                    value: 'Preparing',
                    child: Text('🔥 Preparing (In Progress)'),
                  ),
                  PopupMenuItem(
                    value: 'Ready',
                    child: Text('🔔 Ready for Pickup'),
                  ),
                  PopupMenuItem(
                    value: 'Completed',
                    child: Text('✓ Completed'),
                  ),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatusIcon(order.status),
                    const SizedBox(width: 6),
                    Text(
                      _formatStatusText(order),
                      style: TextStyle(
                        color: _statusColor(order.status, palette),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: palette.muted,
                    ),
                  ],
                ),
              ),

              // Action button
              _buildActionButton(order, palette),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return const Icon(Icons.access_time, size: 14, color: Color(0xFFD97706));
      case 'Preparing':
        return const Icon(Icons.local_fire_department,
            size: 14, color: Color(0xFFC85A32));
      case 'Ready':
        return const Icon(Icons.notifications_active_outlined,
            size: 14, color: Color(0xFF16A34A));
      case 'Completed':
      default:
        return const Icon(Icons.check_circle_outline,
            size: 14, color: Color(0xFF6B7280));
    }
  }

  Color _statusColor(String status, dynamic palette) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFD97706);
      case 'Preparing':
        return palette.accentDark;
      case 'Ready':
        return const Color(0xFF16A34A);
      case 'Completed':
      default:
        return palette.muted;
    }
  }

  String _formatStatusText(CafeOrder order) {
    final elapsedMin = DateTime.now().difference(order.placedAt).inMinutes;
    switch (order.status) {
      case 'Pending':
        return 'Pending (${elapsedMin}m ago)';
      case 'Preparing':
        return 'Preparing (${elapsedMin}m elapsed)';
      case 'Ready':
        return 'Ready for Pickup';
      case 'Completed':
      default:
        return 'Completed';
    }
  }

  Widget _buildActionButton(CafeOrder order, dynamic palette) {
    switch (order.status) {
      case 'Pending':
        return FilledButton(
          onPressed: () => _advanceOrder(order),
          style: FilledButton.styleFrom(
            backgroundColor: palette.accentDark,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Start Order',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        );
      case 'Preparing':
        return FilledButton(
          onPressed: () => _advanceOrder(order),
          style: FilledButton.styleFrom(
            backgroundColor: palette.isDark
                ? const Color(0xFF3B2B23)
                : const Color(0xFFEBD8CE),
            foregroundColor: palette.accentDark,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Mark as Ready',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        );
      case 'Ready':
        return FilledButton(
          onPressed: () => _advanceOrder(order),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFDCFCE7),
            foregroundColor: const Color(0xFF15803D),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Complete',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        );
      case 'Completed':
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: palette.softSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Done',
            style: TextStyle(
              color: palette.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
    }
  }
}
