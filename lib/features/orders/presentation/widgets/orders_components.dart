import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/orders_data.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
      decoration: BoxDecoration(
        color: palette.chipSurface,
        borderRadius: BorderRadius.circular(99),
        border: Border.fromBorderSide(
          BorderSide(color: palette.border),
        ),
        boxShadow: [BoxShadow(color: palette.cardShadow, blurRadius: 2)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined, size: 16, color: palette.body),
          const SizedBox(width: 4),
          Text(
            'Offline mode • Cached receipt ready',
            style: TextStyle(
              color: palette.ink,
              fontSize: 11,
              height: 14 / 11,
              fontWeight: FontWeight.w500,
              letterSpacing: .275,
            ),
          ),
        ],
      ),
    );
  }
}

class OrdersTabs extends StatelessWidget {
  const OrdersTabs({
    super.key,
    required this.showActive,
    required this.onChanged,
  });

  final bool showActive;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: palette.softSurface,
        borderRadius: BorderRadius.circular(99),
        border: Border.fromBorderSide(
          BorderSide(color: palette.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _OrderTab(
              label: 'Active',
              selected: showActive,
              onTap: () => onChanged(true),
              trailing: const Icon(Icons.circle, size: 6, color: Colors.white),
            ),
          ),
          Expanded(
            child: _OrderTab(
              label: 'Past Orders',
              selected: !showActive,
              onTap: () => onChanged(false),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: palette.chipSurface,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '6',
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTab extends StatelessWidget {
  const _OrderTab({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? palette.accentDark : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
          boxShadow: selected
              ? [BoxShadow(color: palette.cardShadow, blurRadius: 2)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : palette.body,
                fontSize: 12,
                height: 16 / 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: .24,
              ),
            ),
            const SizedBox(width: 6),
            trailing,
          ],
        ),
      ),
    );
  }
}

class ActiveOrderCard extends StatelessWidget {
  const ActiveOrderCard({super.key, required this.order, required this.onQr});

  final OrderPreview order;
  final VoidCallback onQr;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
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
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: palette.accentDark,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Ready in ~4 mins',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.ink,
                          fontSize: 16,
                          height: 22 / 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: palette.chipSurface,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 7, color: palette.accentDark),
                    const SizedBox(width: 5),
                    Text(
                      'Total Paid: \$14.99',
                      style: TextStyle(
                        color: palette.accentDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Order #4892 • Dine-In • Table 04',
            style: TextStyle(
              color: palette.body,
              fontSize: 12,
              height: 16 / 12,
            ),
          ),
          const SizedBox(height: 16),
          const ProgressTracker(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: palette.softSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.fromBorderSide(
                BorderSide(color: palette.border),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    order.image,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.ink,
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              order.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.body,
                                fontSize: 12,
                                height: 16 / 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Total Paid:\n${order.total}',
                            style: TextStyle(
                              color: palette.accentDark,
                              fontSize: 12,
                              height: 16 / 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onQr,
              icon: Icon(
                Icons.qr_code_2,
                size: 16,
                color: palette.accentDark,
              ),
              label: Text(
                'Show Pickup QR',
                style: TextStyle(
                  color: palette.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: palette.chipSurface,
                side: BorderSide(color: palette.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressTracker extends StatelessWidget {
  const ProgressTracker({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    const labels = ['Confirmed', 'Ready in ~4 mins', 'Ready', 'Picked Up'];
    const icons = [
      Icons.check,
      Icons.coffee,
      Icons.notifications_none,
      Icons.done_all,
    ];
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: palette.softSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.fromBorderSide(
          BorderSide(color: palette.border),
        ),
      ),
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++)
            Expanded(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: index < 2
                        ? palette.accentDark
                        : palette.chipSurface,
                    child: Icon(
                      icons[index],
                      size: 15,
                      color: index < 2 ? Colors.white : palette.body,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: index == 1 ? palette.accentDark : palette.body,
                      fontSize: 11,
                      height: 14 / 11,
                      fontWeight: index == 1
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
