import 'package:flutter/material.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/auth_scope.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../home/presentation/widgets/home_components.dart';
import '../widgets/appearance_components.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  void _selectNavigation(BuildContext context, int index) {
    final role = AuthScope.maybeOf(context)?.role ?? UserRole.registered;
    if (role == UserRole.guest) {
      if (index == 0) {
        Navigator.of(context).pushReplacementNamed('/');
      } else if (index == 1) {
        Navigator.of(context).pushReplacementNamed('/menu');
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
        Navigator.of(context).pushReplacementNamed('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeScope = ThemeScope.of(context);
    final selectedTheme = themeScope.themeModeName;
    final isGuest = AuthScope.maybeOf(context)?.isGuest ?? false;
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacementNamed(
                          isGuest ? '/' : '/profile',
                        );
                      }
                    },
                    icon: Icon(Icons.chevron_left, size: 24, color: palette.ink),
                    style: IconButton.styleFrom(
                      backgroundColor: palette.softSurface,
                      fixedSize: const Size(40, 40),
                      side: BorderSide(color: palette.border),
                      padding: EdgeInsets.zero,
                    ),
                    tooltip: isGuest ? 'Back to Home' : 'Back to Profile',
                  ),
                  const Spacer(),
                  Text(
                    'Appearance',
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 18,
                      height: 24 / 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -.45,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  ThemePreviewCard(
                    label: 'System',
                    background: palette.isDark
                        ? const Color(0xFF221A16)
                        : const Color(0xFFFCEDEA),
                    panel: palette.isDark
                        ? const Color(0xFF332720)
                        : const Color(0x99FFFFFF),
                    line: palette.isDark
                        ? const Color(0xFF6B544B)
                        : const Color(0x6689726B),
                    icon: Icons.devices_other_outlined,
                    selected: selectedTheme == 'System',
                    onTap: () => themeScope.setThemeMode(ThemeMode.system),
                  ),
                  const SizedBox(width: 12),
                  ThemePreviewCard(
                    label: 'Light',
                    background: const Color(0xFFFFF5F2),
                    panel: Colors.white,
                    line: const Color(0x5989726B),
                    icon: Icons.wb_sunny_outlined,
                    selected: selectedTheme == 'Light',
                    onTap: () => themeScope.setThemeMode(ThemeMode.light),
                  ),
                  const SizedBox(width: 12),
                  ThemePreviewCard(
                    label: 'Dark',
                    background: const Color(0xFF1F1B18),
                    panel: const Color(0xFF342B26),
                    line: const Color(0xFF55423D),
                    icon: Icons.dark_mode_outlined,
                    selected: selectedTheme == 'Dark',
                    onTap: () => themeScope.setThemeMode(ThemeMode.dark),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'THEME PREFERENCE',
                  style: TextStyle(
                    color: palette.body,
                    fontSize: 10,
                    height: 14 / 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.fromBorderSide(
                    BorderSide(color: palette.border),
                  ),
                  boxShadow: [
                    BoxShadow(color: palette.cardShadow, blurRadius: 4),
                  ],
                ),
                child: Column(
                  children: [
                    ThemePreferenceOption(
                      icon: Icons.devices_other_outlined,
                      title: 'System Default',
                      subtitle: 'Match device OS appearance',
                      selected: selectedTheme == 'System',
                      onTap: () => themeScope.setThemeMode(ThemeMode.system),
                    ),
                    Divider(
                      height: 1,
                      indent: 64,
                      color: palette.border,
                    ),
                    ThemePreferenceOption(
                      icon: Icons.wb_sunny_outlined,
                      title: 'Light',
                      subtitle: 'Warm cream & linen aesthetic',
                      selected: selectedTheme == 'Light',
                      onTap: () => themeScope.setThemeMode(ThemeMode.light),
                    ),
                    Divider(
                      height: 1,
                      indent: 64,
                      color: palette.border,
                    ),
                    ThemePreferenceOption(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark',
                      subtitle: 'Rich roasted espresso palette',
                      selected: selectedTheme == 'Dark',
                      onTap: () => themeScope.setThemeMode(ThemeMode.dark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 14, color: palette.body),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Automatic switching will follow your system display schedule.',
                        style: TextStyle(
                          color: palette.body,
                          fontSize: 12,
                          height: 18 / 12,
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
        selectedIndex: isGuest ? 2 : 4,
        onSelected: (index) => _selectNavigation(context, index),
        cartCount: isGuest ? 0 : 2,
      ),
    );
  }
}
