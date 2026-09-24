import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/auth_scope.dart';
import '../../data/menu_data.dart';

class MenuTitleRow extends StatelessWidget {
  const MenuTitleRow({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final role = AuthScope.maybeOf(context)?.role ?? UserRole.registered;
    final isGuest = role == UserRole.guest;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Menu',
          style: TextStyle(
            color: palette.ink,
            fontSize: 32,
            height: 40 / 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -.8,
          ),
        ),
        if (!isGuest)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
            decoration: BoxDecoration(
              color: palette.chipSurface,
              borderRadius: BorderRadius.circular(99),
              border: Border.fromBorderSide(
                BorderSide(color: palette.border),
              ),
              boxShadow: [
                BoxShadow(color: palette.cardShadow, blurRadius: 2),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.table_restaurant,
                  size: 15,
                  color: palette.accentDark,
                ),
                const SizedBox(width: 4),
                Text(
                  'Table 04',
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class MenuSearchField extends StatelessWidget {
  const MenuSearchField({
    super.key,
    this.controller,
    this.onChanged,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(color: palette.ink, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search coffee, tea, pastries...',
        hintStyle: TextStyle(color: palette.muted, fontSize: 14),
        prefixIcon: Icon(Icons.search, size: 18, color: palette.body),
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.accent),
        ),
      ),
    );
  }
}

class MenuCategoryChips extends StatelessWidget {
  const MenuCategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
    this.categories = const ['All', 'Beverages', 'Snacks', 'Meals', 'Desserts'],
  });

  final String selected;
  final ValueChanged<String> onSelected;
  final List<String> categories;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final category in categories) ...[
            ChoiceChip(
              label: Text(category),
              selected: category.toLowerCase() == selected.toLowerCase(),
              onSelected: (_) => onSelected(category),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              labelStyle: TextStyle(
                color: category == selected
                    ? Colors.white
                    : palette.body,
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w600,
              ),
              selectedColor: palette.accent,
              backgroundColor: palette.chipSurface,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            if (category != categories.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class MenuProductCard extends StatelessWidget {
  const MenuProductCard({
    super.key,
    required this.product,
    required this.onAdd,
  });

  final MenuProduct product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Container(
      constraints: const BoxConstraints(minHeight: 102),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.fromBorderSide(
          BorderSide(color: palette.border),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildProductImage(product.image, palette),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 18,
                    height: 24 / 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.body,
                    fontSize: 12,
                    height: 16 / 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.price,
                  style: TextStyle(
                    color: palette.accentDark,
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
              onAdd();
            },
            icon: const Icon(Icons.add, size: 22),
            color: palette.ink,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.chipSurface,
              fixedSize: const Size(44, 44),
            ),
            tooltip: 'Add ${product.name} to cart',
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String image, AppPalette palette) {
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return Image.network(
        image,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 80,
          height: 80,
          color: AppColors.chipSurface,
          alignment: Alignment.center,
          child: const Text('☕', style: TextStyle(fontSize: 32)),
        ),
      );
    }
    if (image.startsWith('assets/')) {
      return Image.asset(
        image,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 80,
          height: 80,
          color: AppColors.chipSurface,
          alignment: Alignment.center,
          child: const Text('☕', style: TextStyle(fontSize: 32)),
        ),
      );
    }
    return Container(
      width: 80,
      height: 80,
      color: AppColors.chipSurface,
      alignment: Alignment.center,
      child: Text(
        image.isNotEmpty ? image : '☕',
        style: const TextStyle(fontSize: 34),
      ),
    );
  }
}

class CartSummaryBar extends StatelessWidget {
  const CartSummaryBar({
    super.key,
    required this.itemCount,
    required this.total,
    required this.onPressed,
  });

  final int itemCount;
  final String total;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      decoration: BoxDecoration(
        color: palette.isDark ? const Color(0xFF2B211B) : AppColors.ink,
        borderRadius: BorderRadius.circular(99),
        border: palette.isDark ? Border.all(color: palette.border) : null,
        boxShadow: [
          BoxShadow(
            color: palette.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: palette.accent,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 15,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  '$itemCount items • $total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onPressed,
            child: Text(
              'View Cart  →',
              style: TextStyle(
                color: palette.isDark ? palette.accentDark : const Color(0xFFFFC5B2),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
