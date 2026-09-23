import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/auth/auth_scope.dart';
import '../../../home/presentation/widgets/home_components.dart';
import '../widgets/profile_components.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _selectNavigation(BuildContext context, int index) {
    final isGuest = AuthScope.of(context).isGuest;
    if (isGuest) {
      switch (index) {
        case 0:
          Navigator.of(context).pushReplacementNamed('/');
        case 1:
          Navigator.of(context).pushReplacementNamed('/menu');
        case 2:
          Navigator.of(context).pushReplacementNamed('/appearance');
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
        Navigator.of(context).pushReplacementNamed('/orders');
      case 4:
        break;
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await AuthScope.of(context).signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final isAdmin = auth.isAdmin;
    final isGuest = auth.isGuest;
    final palette = context.appColors;

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
            136,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  color: palette.ink,
                  fontSize: 28,
                  height: 36 / 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -.7,
                ),
              ),
              const SizedBox(height: 16),
              const ProfileIdentityCard(),
              const SizedBox(height: 24),
              Text(
                isAdmin ? 'Admin tools' : 'Your Caffora',
                style: TextStyle(
                  color: palette.ink,
                  fontSize: 18,
                  height: 24 / 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ProfileSection(
                children: [
                  if (isAdmin) ...[
                    ProfileActionTile(
                      icon: Icons.dashboard_outlined,
                      title: 'Admin dashboard',
                      subtitle: 'View café performance and activity',
                      onTap: () =>
                          Navigator.of(context).pushReplacementNamed('/admin'),
                    ),
                    const ProfileDivider(),
                    ProfileActionTile(
                      icon: Icons.menu_book_outlined,
                      title: 'Manage menu',
                      subtitle: 'Add or update food and drinks',
                      onTap: () =>
                          Navigator.of(context).pushReplacementNamed('/menu'),
                    ),
                    const ProfileDivider(),
                    ProfileActionTile(
                      icon: Icons.receipt_long_outlined,
                      title: 'Manage orders',
                      subtitle: 'Review and update order status',
                      onTap: () =>
                          Navigator.of(context).pushReplacementNamed('/orders'),
                    ),
                  ] else ...[
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
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Preferences',
                style: TextStyle(
                  color: palette.ink,
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
              Text(
                'Support',
                style: TextStyle(
                  color: palette.ink,
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
                  if (isGuest)
                    ProfileActionTile(
                      icon: Icons.login,
                      title: 'Sign in',
                      subtitle: 'Sign in to your Caffora account',
                      onTap: () =>
                          Navigator.of(context).pushReplacementNamed('/login'),
                    )
                  else
                    ProfileActionTile(
                      icon: Icons.logout,
                      title: 'Sign out',
                      subtitle: 'Sign out of this account',
                      onTap: () => _signOut(context),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        selectedIndex: isGuest ? -1 : 4,
        onSelected: (index) => _selectNavigation(context, index),
        cartCount: isGuest ? 0 : 2,
      ),
    );
  }
}
