import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/cart_data.dart';

class CartTopBar extends StatelessWidget {
  const CartTopBar({super.key, required this.onBack, required this.onTable});

  final VoidCallback onBack;
  final VoidCallback onTable;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onBack,
          icon: Icon(Icons.chevron_left, size: 22, color: palette.ink),
          style: IconButton.styleFrom(
            backgroundColor: palette.surface,
            fixedSize: const Size(40, 40),
            side: BorderSide(color: palette.border),
            padding: EdgeInsets.zero,
          ),
          tooltip: 'Go back',
        ),
        Column(
          children: [
            Text(
              'Your Bag',
              style: TextStyle(
                color: palette.ink,
                fontSize: 18,
                height: 24 / 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '2 items',
              style: TextStyle(
                color: palette.body,
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
          icon: Icon(
            Icons.table_restaurant_outlined,
            size: 18,
            color: palette.body,
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
    final palette = context.appColors;
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(99),
        border: Border.fromBorderSide(
          BorderSide(color: palette.border),
        ),
        boxShadow: [BoxShadow(color: palette.cardShadow, blurRadius: 2)],
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
    final palette = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? palette.accentDark : Colors.transparent,
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
                color: selected ? Colors.white : palette.body,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : palette.body,
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
    final palette = context.appColors;
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.fromBorderSide(
          BorderSide(color: palette.border),
        ),
        boxShadow: [BoxShadow(color: palette.cardShadow, blurRadius: 2)],
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: palette.border),
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
    final palette = context.appColors;
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
                      style: TextStyle(
                        color: palette.ink,
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .14,
                      ),
                    ),
                  ),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: palette.ink,
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
                style: TextStyle(
                  color: palette.body,
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
                    color: palette.muted,
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
    final palette = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: palette.softSurface,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onDecrease,
            icon: Icon(Icons.remove, size: 14, color: palette.ink),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            tooltip: 'Decrease quantity',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity',
              style: TextStyle(
                color: palette.ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: onIncrease,
            icon: Icon(Icons.add, size: 14, color: palette.ink),
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
    final palette = context.appColors;
    final gratuity = tip == 18 ? '\$2.13 (18%)' : '+\$0.00';
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.fromBorderSide(
          BorderSide(color: palette.border),
        ),
        boxShadow: [BoxShadow(color: palette.cardShadow, blurRadius: 2)],
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
              Text(
                'BARISTA GRATUITY',
                style: TextStyle(
                  color: palette.body,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: .55,
                ),
              ),
              Text(
                gratuity,
                style: TextStyle(
                  color: palette.accentDark,
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: palette.border),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 18,
                      height: 24 / 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'All taxes & tip included',
                    style: TextStyle(
                      color: palette.body,
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
                  color: palette.accentDark,
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
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: accent ? palette.accentDark : palette.body,
            fontSize: 14,
            height: 20 / 14,
            fontWeight: accent ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: accent ? palette.accentDark : palette.ink,
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
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
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: selected ? palette.accentDark : palette.softSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          value == 0 ? 'None' : '$value%',
          style: TextStyle(
            color: selected ? Colors.white : palette.body,
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class PlaceOrderButton extends StatelessWidget {
  const PlaceOrderButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: palette.accentDark,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        shadowColor: palette.accent.withValues(alpha: .25),
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
}
