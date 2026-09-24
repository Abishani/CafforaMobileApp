import 'package:flutter/material.dart';

import '../../../../core/auth/auth_scope.dart';
import '../../../../core/models/dashboard_models.dart';
import '../../../../core/models/order_models.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_components.dart';
import '../../../menu/data/menu_data.dart';
import '../widgets/admin_components.dart';
import 'add_food_item_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  DashboardResponse? _dashboard;
  List<OrderResponse> _recentOrders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    MenuData.productsNotifier.addListener(_onMenuChanged);
    _loadDashboardData();
  }

  @override
  void dispose() {
    MenuData.productsNotifier.removeListener(_onMenuChanged);
    super.dispose();
  }

  void _onMenuChanged() => setState(() {});

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final dashFuture = ApiClient.instance.get('/api/admin/dashboard', requiresAuth: true);
      final ordersFuture = ApiClient.instance.get('/api/orders', requiresAuth: true);

      final results = await Future.wait([dashFuture, ordersFuture]);

      if (results[0] is Map<String, dynamic>) {
        _dashboard = DashboardResponse.fromJson(results[0] as Map<String, dynamic>);
      }

      if (results[1] is List) {
        _recentOrders = (results[1] as List)
            .take(4)
            .map((i) => OrderResponse.fromJson(i as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _selectNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/menu');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/orders');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/profile');
        break;
    }
  }

  Future<void> _openAddFoodItem() async {
    await Navigator.of(context).push<MenuProduct>(
      MaterialPageRoute(builder: (_) => const AddFoodItemPage()),
    );
    _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final displayName = AuthScope.maybeOf(context)?.displayName ?? 'Admin';

    final grossSales = _dashboard != null
        ? '\$${_dashboard!.todaysGrossSales.toStringAsFixed(2)}'
        : '\$0.00';
    final activeCount = _dashboard?.activeOrderCount.toString() ?? '0';
    final pendingCount = _dashboard?.pendingCount.toString() ?? '0';
    final avgPrep = _dashboard != null && _dashboard!.avgPrepMinutes > 0
        ? '${_dashboard!.avgPrepMinutes.toStringAsFixed(1)}m'
        : '6.5m';

    return Scaffold(
      backgroundColor: palette.background,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: HomeHeader(actionLabel: 'Admin', showActionLabel: false),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: palette.accentDark,
          onRefresh: _loadDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              18,
              AppSpacing.page,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(color: palette.accentDark, minHeight: 2),
                  ),
                Text(
                  'Good morning, $displayName',
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 24,
                    height: 30 / 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Here is today\'s café snapshot.',
                  style: TextStyle(
                    color: palette.body,
                    fontSize: 13,
                    height: 18 / 13,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    AdminMetricCard(
                      label: 'Today\'s sales',
                      value: grossSales,
                      change: '+12.4%',
                      icon: Icons.attach_money,
                    ),
                    const SizedBox(width: 12),
                    AdminMetricCard(
                      label: 'Active orders',
                      value: activeCount,
                      change: 'In kitchen',
                      icon: Icons.receipt_long_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    AdminMetricCard(
                      label: 'Pending tickets',
                      value: pendingCount,
                      change: 'Awaiting prep',
                      icon: Icons.hourglass_top_outlined,
                    ),
                    const SizedBox(width: 12),
                    AdminMetricCard(
                      label: 'Avg prep time',
                      value: avgPrep,
                      change: 'Standard ~7m',
                      icon: Icons.timer_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const AdminSectionCard(
                  title: 'Revenue overview',
                  action: 'This week',
                  child: AdminBarChart(),
                ),
                const SizedBox(height: 16),
                AdminSectionCard(
                  title: 'Recent orders',
                  action: 'View all',
                  onAction: () =>
                      Navigator.of(context).pushReplacementNamed('/orders'),
                  child: Column(
                    children: [
                      if (_recentOrders.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'No recent orders today',
                            style: TextStyle(color: palette.body, fontSize: 13),
                          ),
                        )
                      else
                        for (var i = 0; i < _recentOrders.length; i++) ...[
                          AdminOrderRow(
                            order: _recentOrders[i].orderNumber.isNotEmpty
                                ? _recentOrders[i].orderNumber
                                : '#${_recentOrders[i].id}',
                            customer: _recentOrders[i].customerName ?? 'Customer',
                            amount: '\$${_recentOrders[i].total.toStringAsFixed(2)}',
                            status: _recentOrders[i].displayStatus,
                            statusColor: _recentOrders[i].displayStatus == 'Ready'
                                ? const Color(0xFF4C8A65)
                                : palette.accentDark,
                          ),
                          if (i < _recentOrders.length - 1)
                            Divider(height: 1, color: palette.border),
                        ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AdminSectionCard(
                  title: 'Quick actions',
                  action: '',
                  child: Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.add_box_outlined,
                          label: 'Add menu item',
                          onTap: _openAddFoodItem,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.restaurant_menu_outlined,
                          label: 'Manage orders',
                          onTap: () => Navigator.of(context)
                              .pushReplacementNamed('/orders'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        selectedIndex: 3,
        onSelected: (i) => _selectNavigation(context, i),
        cartCount: 0,
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: palette.softSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: palette.accentDark, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
