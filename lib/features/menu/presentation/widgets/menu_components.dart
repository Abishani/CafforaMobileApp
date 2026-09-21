import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/menu_data.dart';

class MenuTitleRow extends StatelessWidget {
  const MenuTitleRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Menu',
          style: TextStyle(
            fontSize: 32,
            height: 40 / 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -.8,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2DA),
            borderRadius: BorderRadius.circular(99),
            border: const Border.fromBorderSide(
              BorderSide(color: AppColors.border),
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x0D000000), blurRadius: 2),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.table_restaurant,
                size: 15,
                color: AppColors.accentDark,
              ),
              SizedBox(width: 4),
              Text(
                'Table 04',
                style: TextStyle(
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
  const MenuSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: AppColors.ink, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search coffee, tea, pastries...',
        hintStyle: const TextStyle(color: Color(0xFFA38B85), fontSize: 14),
        prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.body),
        filled: true,
        fillColor: AppColors.softSurface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6B7280)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6B7280)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent),
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
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const categories = ['All', 'Coffee', 'Tea', 'Pastries', 'Brunch'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final category in categories) ...[
            ChoiceChip(
              label: Text(category),
              selected: category == selected,
              onSelected: (_) => onSelected(category),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              labelStyle: TextStyle(
                color: category == selected
                    ? Colors.white
                    : const Color(0xFF7A625A),
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w600,
              ),
              selectedColor: AppColors.accent,
              backgroundColor: const Color(0xFFFFE9E3),
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
    return Container(
      constraints: const BoxConstraints(minHeight: 102),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0x4DDCC1B8)),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2B1810),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              product.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
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
                  style: const TextStyle(
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
                  style: const TextStyle(
                    color: Color(0xFF7A625A),
                    fontSize: 12,
                    height: 16 / 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.price,
                  style: const TextStyle(
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
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 22),
            color: AppColors.ink,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFEE2DA),
              fixedSize: const Size(44, 44),
              padding: EdgeInsets.zero,
            ),
            tooltip: 'Add ${product.name} to cart',
          ),
        ],
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
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(99),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332B1810),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent,
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
            child: const Text(
              'View Cart  →',
              style: TextStyle(
                color: Color(0xFFFFC5B2),
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
