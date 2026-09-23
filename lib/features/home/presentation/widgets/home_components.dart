import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/auth_scope.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../data/home_data.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.actionLabel = 'Account',
    this.showNotifications = false,
    this.showActionLabel = true,
  });

  final String actionLabel;
  final bool showNotifications;
  final bool showActionLabel;

  @override
  Widget build(BuildContext context) {
    final isGuest = AuthScope.maybeOf(context)?.isGuest ?? false;
    final palette = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: palette.isDark ? const Color(0xE6171210) : const Color(0xD9FFF8F6),
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Row(
              children: [
                Image.asset(AppAssets.logo, width: 32, height: 32),
                const SizedBox(width: 8),
                Text(
                  'Caffora',
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (isGuest) ...[
                  IconButton(
                    onPressed: () {
                      final themeScope = ThemeScope.maybeOf(context);
                      if (themeScope != null) {
                        themeScope.setThemeMode(
                          palette.isDark ? ThemeMode.light : ThemeMode.dark,
                        );
                      }
                    },
                    icon: Icon(
                      palette.isDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      size: 20,
                      color: palette.accentDark,
                    ),
                    tooltip: palette.isDark
                        ? 'Switch to light mode'
                        : 'Switch to dark mode',
                  ),
                  IconButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed('/login'),
                    icon: Icon(
                      Icons.login_outlined,
                      size: 20,
                      color: palette.accentDark,
                    ),
                    tooltip: 'Login to place an order',
                  ),
                ]
                else if (showNotifications)
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: Icon(
                        Icons.notifications_none_outlined,
                        size: 20,
                        color: palette.accent,
                      ),
                    ),
                  )
                else if (showActionLabel)
                  Text(
                    actionLabel,
                    style: TextStyle(
                      color: palette.body,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (!isGuest) ...[
                  const SizedBox(width: 16),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: palette.accentDark.withValues(alpha: .2),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipOval(child: Image.asset(AppAssets.profile)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return TextField(
      style: TextStyle(color: palette.ink, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search coffee or bakery...',
        hintStyle: TextStyle(color: palette.muted, fontSize: 14),
        prefixIcon: Icon(Icons.search, size: 18, color: palette.body),
        suffixIcon: IconButton(
          onPressed: () {},
          icon: Icon(Icons.tune, size: 16, color: palette.body),
          tooltip: 'Filter menu',
        ),
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.accent),
        ),
      ),
    );
  }
}

class PickupBanner extends StatelessWidget {
  const PickupBanner({super.key, required this.onOrder});

  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: palette.softSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.fromBorderSide(
          BorderSide(color: palette.border),
        ),
        boxShadow: [BoxShadow(color: palette.cardShadow, blurRadius: 4)],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            bottom: -25,
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: palette.chipSurface,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(18)),
              ),
              child: Icon(
                Icons.local_cafe,
                size: 42,
                color: palette.isDark ? palette.accent : Colors.white,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Pill(label: 'EXPRESS PICKUP'),
              const SizedBox(height: 12),
              Text(
                'Order ahead & pick up in 5 mins',
                style: TextStyle(
                  color: palette.ink,
                  fontSize: 18,
                  height: 24 / 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 290,
                child: Text(
                  'Freshly ground roasts & warm pastries ready upon arrival.',
                  style: TextStyle(
                    color: palette.body,
                    fontSize: 12,
                    height: 16 / 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onOrder,
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: const Text('Order Now'),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeSection extends StatelessWidget {
  const HomeSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.products,
    required this.onAdd,
  });

  final String title;
  final String subtitle;
  final List<HomeProduct> products;
  final ValueChanged<HomeProduct> onAdd;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 16,
                        decoration: BoxDecoration(
                          color: palette.accent,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        title,
                        style: TextStyle(
                          color: palette.ink,
                          fontSize: 18,
                          height: 24 / 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: palette.body,
                      fontSize: 12,
                      height: 16 / 12,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See all',
                style: TextStyle(color: palette.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - AppSpacing.grid) / 2;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < products.length; index++) ...[
                  SizedBox(
                    width: cardWidth,
                    child: ProductCard(product: products[index], onAdd: onAdd),
                  ),
                  if (index < products.length - 1)
                    const SizedBox(width: AppSpacing.grid),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onAdd});

  final HomeProduct product;
  final ValueChanged<HomeProduct> onAdd;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.fromBorderSide(
          BorderSide(color: palette.border),
        ),
        boxShadow: [BoxShadow(color: palette.cardShadow, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 169 / 225.33,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(product.image, fit: BoxFit.cover),
                if (product.rating != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _Pill(label: '★ ${product.rating}'),
                  ),
                if (product.badge != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _Pill(label: product.badge!, filled: true),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.card),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  product.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.body,
                    fontSize: 12,
                    height: 16 / 12,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.price,
                      style: TextStyle(
                        color: palette.accentDark,
                        fontSize: 18,
                        height: 24 / 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (AuthScope.maybeOf(context)?.isGuest ?? false) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Login to place an order.'),
                              duration: Duration(milliseconds: 1200),
                            ),
                          );
                          return;
                        }
                        onAdd(product);
                      },
                      icon: const Icon(Icons.add, size: 18),
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: palette.accent,
                        fixedSize: const Size(32, 32),
                        padding: EdgeInsets.zero,
                      ),
                      tooltip: 'Add ${product.name} to cart',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.filled = false});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? palette.accent : palette.chipSurface,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: filled ? Colors.white : palette.accentDark,
          fontSize: 11,
          height: 14 / 11,
          fontWeight: FontWeight.w600,
          letterSpacing: .33,
        ),
      ),
    );
  }
}

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.cartCount,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    final role = AuthScope.maybeOf(context)?.role ?? UserRole.registered;
    final palette = context.appColors;
    final items = switch (role) {
      UserRole.guest => const [
        (Icons.coffee_outlined, 'Home'),
        (Icons.menu_book_outlined, 'Menu'),
      ],
      UserRole.admin => const [
        (Icons.coffee_outlined, 'Home'),
        (Icons.menu_book_outlined, 'Manage Menu'),
        (Icons.receipt_long_outlined, 'Manage Orders'),
        (Icons.account_balance_wallet_outlined, 'Profile'),
      ],
      UserRole.registered => const [
        (Icons.coffee_outlined, 'Home'),
        (Icons.menu_book_outlined, 'Menu'),
        (Icons.shopping_bag_outlined, 'Cart'),
        (Icons.receipt_long_outlined, 'Orders'),
        (Icons.account_balance_wallet_outlined, 'Account'),
      ],
    };
    return Container(
      decoration: BoxDecoration(
        color: palette.isDark ? const Color(0xF2171210) : const Color(0xE6FFF8F6),
        border: Border(top: BorderSide(color: palette.border)),
        boxShadow: [
          BoxShadow(
            color: palette.isDark ? const Color(0x33000000) : const Color(0x0F2B1810),
            blurRadius: 12,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var index = 0; index < items.length; index++)
                Expanded(
                  child: InkWell(
                    onTap: () => onSelected(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              items[index].$1,
                              size: 20,
                              color: index == selectedIndex
                                  ? palette.accent
                                  : palette.muted,
                            ),
                            if (role == UserRole.registered &&
                                index == 2 &&
                                cartCount > 0)
                              Positioned(
                                right: -9,
                                top: -7,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: palette.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$cartCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[index].$2,
                          style: TextStyle(
                            color: index == selectedIndex
                                ? palette.accent
                                : palette.muted,
                            fontSize: 11,
                            height: 14 / 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
