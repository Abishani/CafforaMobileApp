import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: const Border.fromBorderSide(
            BorderSide(color: AppColors.border),
          ),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.softSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.accentDark),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.body,
                fontSize: 11,
                height: 14 / 11,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                height: 28 / 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              change,
              style: const TextStyle(
                color: AppColors.accentDark,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.border),
        ),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  height: 22 / 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: action.isEmpty ? null : onAction,
                child: Text(
                  action,
                  style: const TextStyle(
                    color: AppColors.accentDark,
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  customer,
                  style: const TextStyle(color: AppColors.body, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
                        ? AppColors.accentDark
                        : const Color(0xFFF8CFC2),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                  style: const TextStyle(color: AppColors.body, fontSize: 10),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
