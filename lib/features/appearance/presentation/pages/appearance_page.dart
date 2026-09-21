import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_components.dart';
import '../widgets/appearance_components.dart';

class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  String _selectedTheme = 'Light';

  void _selectNavigation(int index) {
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed('/profile'),
                    icon: const Icon(Icons.chevron_left, size: 24),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.softSurface,
                      fixedSize: const Size(40, 40),
                      side: const BorderSide(color: Color(0xFFF0D4CC)),
                      padding: EdgeInsets.zero,
                    ),
                    tooltip: 'Back to Profile',
                  ),
                  const Spacer(),
                  const Text(
                    'Appearance',
                    style: TextStyle(
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
                    background: const Color(0xFFFCEDEA),
                    panel: const Color(0x99FFFFFF),
                    line: const Color(0x6689726B),
                    icon: Icons.devices_other_outlined,
                    selected: _selectedTheme == 'System',
                    onTap: () => setState(() => _selectedTheme = 'System'),
                  ),
                  const SizedBox(width: 12),
                  ThemePreviewCard(
                    label: 'Light',
                    background: const Color(0xFFFFF5F2),
                    panel: Colors.white,
                    line: const Color(0x5989726B),
                    icon: Icons.wb_sunny_outlined,
                    selected: _selectedTheme == 'Light',
                    onTap: () => setState(() => _selectedTheme = 'Light'),
                  ),
                  const SizedBox(width: 12),
                  ThemePreviewCard(
                    label: 'Dark',
                    background: const Color(0xFF1F1B18),
                    panel: const Color(0xFF342B26),
                    line: const Color(0xFF55423D),
                    icon: Icons.dark_mode_outlined,
                    selected: _selectedTheme == 'Dark',
                    onTap: () => setState(() => _selectedTheme = 'Dark'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'THEME PREFERENCE',
                  style: TextStyle(
                    color: AppColors.body,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: const Border.fromBorderSide(
                    BorderSide(color: Color(0xFFF0D4CC)),
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0D000000), blurRadius: 2),
                  ],
                ),
                child: Column(
                  children: [
                    ThemePreferenceOption(
                      icon: Icons.devices_other_outlined,
                      title: 'System Default',
                      subtitle: 'Match device OS appearance',
                      selected: _selectedTheme == 'System',
                      onTap: () => setState(() => _selectedTheme = 'System'),
                    ),
                    const Divider(
                      height: 1,
                      indent: 64,
                      color: Color(0xFFF0D4CC),
                    ),
                    ThemePreferenceOption(
                      icon: Icons.wb_sunny_outlined,
                      title: 'Light',
                      subtitle: 'Warm cream & linen aesthetic',
                      selected: _selectedTheme == 'Light',
                      onTap: () => setState(() => _selectedTheme = 'Light'),
                    ),
                    const Divider(
                      height: 1,
                      indent: 64,
                      color: Color(0xFFF0D4CC),
                    ),
                    ThemePreferenceOption(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark',
                      subtitle: 'Rich roasted espresso palette',
                      selected: _selectedTheme == 'Dark',
                      onTap: () => setState(() => _selectedTheme = 'Dark'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 14, color: AppColors.body),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Automatic switching will follow your system display schedule.',
                        style: TextStyle(
                          color: AppColors.body,
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
        selectedIndex: 4,
        onSelected: _selectNavigation,
        cartCount: 2,
      ),
    );
  }
}
