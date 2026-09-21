import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/cart_data.dart';

class CartTopBar extends StatelessWidget {
  const CartTopBar({super.key, required this.onBack, required this.onTable});

  final VoidCallback onBack;
  final VoidCallback onTable;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.chevron_left, size: 22),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            fixedSize: const Size(40, 40),
            side: const BorderSide(color: Color(0x80F2DFD9)),
            padding: EdgeInsets.zero,
          ),
          tooltip: 'Go back',
        ),
        const Column(
          children: [
            Text(
              'Your Bag',
              style: TextStyle(
                fontSize: 18,
                height: 24 / 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '2 items',
              style: TextStyle(
                color: Color(0xFF78655E),
                fontSize: 11,
                height: 14 / 11,
                fontWeight: FontWeight.w500,
                letterSpacing: .33,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: onTable,
          icon: const Icon(
            Icons.table_restaurant_outlined,
            size: 18,
            color: AppColors.body,
          ),
          tooltip: 'Table 04',
        ),
      ],
    );
  }
}

class ServiceModeToggle extends StatelessWidget {
  const ServiceModeToggle({
    super.key,
    required this.isDineIn,
    required this.onChanged,
  });

  final bool isDineIn;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0x99F2DFD9)),
        ),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: _ModeButton(
              label: 'Dine-in (Table 04)',
              icon: Icons.restaurant,
              selected: isDineIn,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _ModeButton(
              label: 'Takeaway',
              icon: Icons.shopping_bag_outlined,
              selected: !isDineIn,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentDark : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? Colors.white : AppColors.body,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.body,
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartItemsCard extends StatelessWidget {
  const CartItemsCard({
    super.key,
    required this.items,
    required this.quantities,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final List<CartItem> items;
  final List<int> quantities;
  final ValueChanged<int> onDecrease;
  final ValueChanged<int> onIncrease;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0x66F2DFD9)),
        ),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2)],
      ),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _CartItemRow(
              item: items[index],
              quantity: quantities[index],
              onDecrease: () => onDecrease(index),
              onIncrease: () => onIncrease(index),
              onRemove: () => onRemove(index),
            ),
            if (index < items.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: Color(0xB3F2DFD9)),
              ),
          ],
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({
    required this.item,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final CartItem item;
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            item.image,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .14,
                      ),
                    ),
                  ),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                item.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF78655E),
                  fontSize: 12,
                  height: 16 / 12,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Stepper(
                    quantity: quantity,
                    onDecrease: onDecrease,
                    onIncrease: onIncrease,
                  ),
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline, size: 17),
                    color: const Color(0xFF9B8179),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    tooltip: 'Remove ${item.name}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softSurface,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onDecrease,
            icon: const Icon(Icons.remove, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            tooltip: 'Decrease quantity',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: onIncrease,
            icon: const Icon(Icons.add, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            tooltip: 'Increase quantity',
          ),
        ],
      ),
    );
  }
}

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.tip,
    required this.onTipChanged,
  });

  final int tip;
  final ValueChanged<int> onTipChanged;

  @override
  Widget build(BuildContext context) {
    final gratuity = tip == 18 ? '\$2.13 (18%)' : '+\$0.00';
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0x66F2DFD9)),
        ),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SummaryRow(label: 'Subtotal', value: '\$13.85'),
          const SizedBox(height: 8),
          const _SummaryRow(
            label: '🏷 PASTRYBEANS',
            value: '-\$2.00',
            accent: true,
          ),
          const SizedBox(height: 8),
          const _SummaryRow(label: 'Estimated Tax', value: '\$1.01'),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BARISTA GRATUITY',
                style: TextStyle(
                  color: Color(0xFF78655E),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: .55,
                ),
              ),
              Text(
                gratuity,
                style: const TextStyle(
                  color: AppColors.accentDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (final value in [10, 15, 18, 0])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _TipButton(
                      value: value,
                      selected: tip == value,
                      onTap: () => onTipChanged(value),
                    ),
                  ),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Color(0xB3F2DFD9)),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 18,
                      height: 24 / 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'All taxes & tip included',
                    style: TextStyle(
                      color: Color(0xFF78655E),
                      fontSize: 11,
                      height: 14 / 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '\$14.99',
                style: TextStyle(
                  color: AppColors.accentDark,
                  fontSize: 28,
                  height: 36 / 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -.7,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.accent = false,
  });

  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          color: accent ? AppColors.accentDark : const Color(0xFF78655E),
          fontSize: 14,
          height: 20 / 14,
          fontWeight: accent ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: accent ? AppColors.accentDark : AppColors.ink,
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _TipButton extends StatelessWidget {
  const _TipButton({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.accentDark : AppColors.softSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value == 0 ? 'None' : '$value%',
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF78655E),
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

class PlaceOrderButton extends StatelessWidget {
  const PlaceOrderButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.accentDark,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      shadowColor: AppColors.accent.withValues(alpha: .25),
    ),
    child: const Column(
      children: [
        Text(
          'Place Order • \$14.99',
          style: TextStyle(
            fontSize: 18,
            height: 24 / 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Table 04 • Ready in ~6–8 minutes',
          style: TextStyle(
            fontSize: 11,
            height: 14 / 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
