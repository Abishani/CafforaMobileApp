import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/orders_data.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2DA),
        borderRadius: BorderRadius.circular(99),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0x4DDCC1B8)),
        ),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2)],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined, size: 16, color: Color(0xFF56423C)),
          SizedBox(width: 4),
          Text(
            'Offline mode • Cached receipt ready',
            style: TextStyle(
              color: Color(0xFF56423C),
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
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.softSurface,
        borderRadius: BorderRadius.circular(99),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0x4DDCC1B8)),
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
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2DA),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '6',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentDark : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
          boxShadow: selected
              ? const [BoxShadow(color: Color(0x0D000000), blurRadius: 2)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF56423C),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0x4DDCC1B8)),
        ),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: AppColors.accentDark,
                    size: 18,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Ready in ~4 mins',
                    style: TextStyle(
                      fontSize: 18,
                      height: 24 / 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2DA),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: AppColors.accentDark),
                    SizedBox(width: 6),
                    Text(
                      'Total Paid: \$14.99',
                      style: TextStyle(
                        color: AppColors.accentDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Order #4892 • Dine-In • Table 04',
            style: TextStyle(
              color: Color(0xFF56423C),
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
              color: AppColors.softSurface,
              borderRadius: BorderRadius.circular(20),
              border: const Border.fromBorderSide(
                BorderSide(color: Color(0x33DCC1B8)),
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
                        style: const TextStyle(
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
                              style: const TextStyle(
                                color: Color(0xFF56423C),
                                fontSize: 12,
                                height: 16 / 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Total Paid:\n${order.total}',
                            style: const TextStyle(
                              color: AppColors.accentDark,
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
              icon: const Icon(
                Icons.qr_code_2,
                size: 16,
                color: AppColors.accentDark,
              ),
              label: const Text(
                'Show Pickup QR',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFFEE2DA),
                side: const BorderSide(color: Color(0x4DDCC1B8)),
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
        color: AppColors.softSurface,
        borderRadius: BorderRadius.circular(20),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0x33DCC1B8)),
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
                        ? AppColors.accentDark
                        : const Color(0xFFFEE2DA),
                    child: Icon(
                      icons[index],
                      size: 15,
                      color: index < 2 ? Colors.white : AppColors.body,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: index == 1 ? AppColors.accentDark : AppColors.ink,
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
