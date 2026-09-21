import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_components.dart';
import '../widgets/profile_components.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _selectNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/');
      case 1:
        Navigator.of(context).pushReplacementNamed('/menu');
      case 2:
        Navigator.of(context).pushReplacementNamed('/cart');
      case 3:
        Navigator.of(context).pushReplacementNamed('/orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            136,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 28,
                  height: 36 / 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -.7,
                ),
              ),
              const SizedBox(height: 16),
              const ProfileIdentityCard(),
              const SizedBox(height: 24),
              const Text(
                'Your Caffora',
                style: TextStyle(
                  fontSize: 18,
                  height: 24 / 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ProfileSection(
                children: [
                  const ProfileActionTile(
                    icon: Icons.person_outline,
                    title: 'Personal information',
                    subtitle: 'Update your name and contact details',
                  ),
                  const ProfileDivider(),
                  const ProfileActionTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Order history',
                    subtitle: 'View your past orders',
                  ),
                  const ProfileDivider(),
                  const ProfileActionTile(
                    icon: Icons.location_on_outlined,
                    title: 'Saved places',
                    subtitle: 'Manage your favorite locations',
                  ),
                  const ProfileDivider(),
                  const ProfileActionTile(
                    icon: Icons.favorite_border,
                    title: 'Favorites',
                    subtitle: 'Your saved drinks and treats',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 18,
                  height: 24 / 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ProfileSection(
                children: [
                  const ProfileActionTile(
                    icon: Icons.notifications_none_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage order updates and offers',
                  ),
                  const ProfileDivider(),
                  const ProfileActionTile(
                    icon: Icons.credit_card_outlined,
                    title: 'Payment methods',
                    subtitle: 'Manage your saved cards',
                  ),
                  const ProfileDivider(),
                  ProfileActionTile(
                    icon: Icons.palette_outlined,
                    title: 'Appearance',
                    subtitle: 'Customize your app experience',
                    onTap: () =>
                        Navigator.of(context)
                            .pushReplacementNamed('/appearance'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Support',
                style: TextStyle(
                  fontSize: 18,
                  height: 24 / 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ProfileSection(
                children: [
                  const ProfileActionTile(
                    icon: Icons.help_outline,
                    title: 'Help & support',
                    subtitle: 'Get answers or contact Caffora',
                  ),
                  const ProfileDivider(),
                  const ProfileActionTile(
                    icon: Icons.description_outlined,
                    title: 'Terms & privacy',
                    subtitle: 'Review our policies',
                  ),
                  const ProfileDivider(),
                  ProfileActionTile(
                    icon: Icons.logout,
                    title: 'Sign out',
                    subtitle: 'Sign out of this account',
                    onTap: () =>
                        Navigator.of(context).pushReplacementNamed('/login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        selectedIndex: 4,
        onSelected: (index) => _selectNavigation(context, index),
        cartCount: 2,
      ),
    );
  }
}
