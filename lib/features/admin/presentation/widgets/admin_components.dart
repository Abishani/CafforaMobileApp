import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../menu/data/menu_data.dart';

class AdminMetricCard extends StatelessWidget {
  const AdminMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.change,
    required this.icon,
  });

  final String label;
  final String value;
  final String change;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.fromBorderSide(
            BorderSide(color: palette.border),
          ),
          boxShadow: [BoxShadow(color: palette.cardShadow, blurRadius: 2)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.softSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: palette.accentDark),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: palette.body,
                fontSize: 11,
                height: 14 / 11,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                color: palette.ink,
                fontSize: 22,
                height: 28 / 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              change,
              style: TextStyle(
                color: palette.accentDark,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminSectionCard extends StatelessWidget {
  const AdminSectionCard({
    super.key,
    required this.title,
    required this.action,
    required this.child,
    this.onAction,
  });

  final String title;
  final String action;
  final Widget child;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.fromBorderSide(
          BorderSide(color: palette.border),
        ),
        boxShadow: [BoxShadow(color: palette.cardShadow, blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: palette.ink,
                  fontSize: 16,
                  height: 22 / 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: action.isEmpty ? null : onAction,
                child: Text(
                  action,
                  style: TextStyle(
                    color: palette.accentDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class AdminOrderRow extends StatelessWidget {
  const AdminOrderRow({
    super.key,
    required this.order,
    required this.customer,
    required this.amount,
    required this.status,
    required this.statusColor,
  });

  final String order;
  final String customer;
  final String amount;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order,
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  customer,
                  style: TextStyle(color: palette.body, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: palette.ink,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminBarChart extends StatelessWidget {
  const AdminBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    const values = [0.42, 0.62, 0.52, 0.78, 0.67, 0.92, 0.72];
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var index = 0; index < values.length; index++)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 22,
                  height: 112 * values[index],
                  decoration: BoxDecoration(
                    color: index == 5
                        ? palette.accentDark
                        : (palette.isDark
                            ? const Color(0xFF3B2B24)
                            : const Color(0xFFF8CFC2)),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                  style: TextStyle(color: palette.body, fontSize: 10),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class AdminMenuItemRow extends StatelessWidget {
  const AdminMenuItemRow({super.key, required this.product});

  final MenuProduct product;

  bool get _isEmoji => product.image.length <= 2 && product.isCustom;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Thumbnail / emoji icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: palette.softSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: _isEmoji
                ? Text(product.image, style: const TextStyle(fontSize: 24))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      product.image,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.fastfood_outlined,
                        size: 22,
                        color: palette.accentDark,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (product.isCustom) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: palette.accent.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          'New',
                          style: TextStyle(
                            color: palette.accentDark,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  product.category,
                  style: TextStyle(
                    color: palette.body,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            product.price,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: palette.ink,
            ),
          ),
        ],
      ),
    );
  }
}
