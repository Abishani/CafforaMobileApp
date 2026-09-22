import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/auth/auth_scope.dart';
import '../../../home/presentation/widgets/home_components.dart';
import '../widgets/admin_components.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: HomeHeader(actionLabel: 'Admin', showActionLabel: true),
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
                'Good morning, ${AuthScope.maybeOf(context)?.displayName ?? 'Alex'}',
                style: TextStyle(
                  fontSize: 24,
                  height: 30 / 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -.6,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Here is today\'s café snapshot.',
                style: TextStyle(
                  color: AppColors.body,
                  fontSize: 13,
                  height: 18 / 13,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const AdminMetricCard(
                    label: 'Today\'s revenue',
                    value: '\$2,840',
                    change: '+12.4%',
                    icon: Icons.attach_money,
                  ),
                  const SizedBox(width: 12),
                  const AdminMetricCard(
                    label: 'Orders',
                    value: '128',
                    change: '+8.2%',
                    icon: Icons.receipt_long_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const AdminMetricCard(
                    label: 'Avg. order',
                    value: '\$22.18',
                    change: '+3.1%',
                    icon: Icons.trending_up,
                  ),
                  const SizedBox(width: 12),
                  const AdminMetricCard(
                    label: 'Customers',
                    value: '864',
                    change: '+6.7%',
                    icon: Icons.people_outline,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AdminSectionCard(
                title: 'Revenue overview',
                action: 'This week',
                child: const AdminBarChart(),
              ),
              const SizedBox(height: 16),
              AdminSectionCard(
                title: 'Recent orders',
                action: 'View all',
                onAction: () =>
                    Navigator.of(context).pushReplacementNamed('/admin'),
                child: const Column(
                  children: [
                    AdminOrderRow(
                      order: '#4892',
                      customer: 'Alex Morgan',
                      amount: '\$14.99',
                      status: 'Preparing',
                      statusColor: AppColors.accentDark,
                    ),
                    Divider(height: 1, color: AppColors.border),
                    AdminOrderRow(
                      order: '#4891',
                      customer: 'Jamie Lee',
                      amount: '\$28.50',
                      status: 'Ready',
                      statusColor: Color(0xFF4C8A65),
                    ),
                    Divider(height: 1, color: AppColors.border),
                    AdminOrderRow(
                      order: '#4890',
                      customer: 'Sam Rivera',
                      amount: '\$9.75',
                      status: 'Completed',
                      statusColor: AppColors.body,
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
                        onTap: () =>
                            Navigator.of(context).pushReplacementNamed('/menu'),
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
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.softSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.accentDark),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
