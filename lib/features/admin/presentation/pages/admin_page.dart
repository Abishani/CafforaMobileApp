import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/auth/auth_scope.dart';
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

  @override
  void initState() {
    super.initState();
    MenuData.productsNotifier.addListener(_onMenuChanged);
  }

  @override
  void dispose() {
    MenuData.productsNotifier.removeListener(_onMenuChanged);
    super.dispose();
  }

  void _onMenuChanged() => setState(() {});

  void _selectNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/');
      case 1:
        Navigator.of(context).pushReplacementNamed('/menu');
      case 2:
        Navigator.of(context).pushReplacementNamed('/orders');
      case 3:
        Navigator.of(context).pushReplacementNamed('/profile');
    }
  }

  Future<void> _openAddFoodItem() async {
    await Navigator.of(context).push<MenuProduct>(
      MaterialPageRoute(builder: (_) => const AddFoodItemPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final displayName = AuthScope.maybeOf(context)?.displayName ?? 'Alex';

    return Scaffold(
      backgroundColor: palette.background,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: HomeHeader(actionLabel: 'Admin', showActionLabel: false),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            18,
            AppSpacing.page,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const Row(
                children: [
                  AdminMetricCard(
                    label: 'Today\'s revenue',
                    value: '\$2,840',
                    change: '+12.4%',
                    icon: Icons.attach_money,
                  ),
                  SizedBox(width: 12),
                  AdminMetricCard(
                    label: 'Orders',
                    value: '128',
                    change: '+8.2%',
                    icon: Icons.receipt_long_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  AdminMetricCard(
                    label: 'Avg. order',
                    value: '\$22.18',
                    change: '+3.1%',
                    icon: Icons.trending_up,
                  ),
                  SizedBox(width: 12),
                  AdminMetricCard(
                    label: 'Customers',
                    value: '864',
                    change: '+6.7%',
                    icon: Icons.people_outline,
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
                    Navigator.of(context).pushReplacementNamed('/admin'),
                child: Column(
                  children: [
                    AdminOrderRow(
                      order: '#4892',
                      customer: 'Alex Morgan',
                      amount: '\$14.99',
                      status: 'Preparing',
                      statusColor: palette.accentDark,
                    ),
                    Divider(height: 1, color: palette.border),
                    const AdminOrderRow(
                      order: '#4891',
                      customer: 'Jamie Lee',
                      amount: '\$28.50',
                      status: 'Ready',
                      statusColor: Color(0xFF4C8A65),
                    ),
                    Divider(height: 1, color: palette.border),
                    AdminOrderRow(
                      order: '#4890',
                      customer: 'Sam Rivera',
                      amount: '\$9.75',
                      status: 'Completed',
                      statusColor: palette.body,
                    ),
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.local_offer_outlined,
                        label: 'Create offer',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ── Manage Menu section ──────────────────────────
              AdminSectionCard(
                title: 'Manage Menu',
                action: 'Add Item',
                onAction: _openAddFoodItem,
                child: Column(
                  children: [
                    ...MenuData.products.asMap().entries.map((entry) {
                      final i = entry.key;
                      final p = entry.value;
                      return Column(
                        children: [
                          if (i > 0)
                            Divider(height: 1, color: palette.border),
                          AdminMenuItemRow(
                            product: p,
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 10),
                    // Add food item button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _openAddFoodItem,
                        icon: Icon(
                          Icons.add_circle_outline,
                          size: 18,
                          color: palette.accentDark,
                        ),
                        label: Text(
                          'Add More Food Options',
                          style: TextStyle(
                            color: palette.accentDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: BorderSide(
                            color: palette.accentDark,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        selectedIndex: 0,
        onSelected: (index) => _selectNavigation(context, index),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
        decoration: BoxDecoration(
          color: palette.softSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: palette.accentDark),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.ink,
                fontSize: 10,
                height: 14 / 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
