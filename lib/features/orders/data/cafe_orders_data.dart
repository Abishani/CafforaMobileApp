import 'package:flutter/foundation.dart';

class CafeOrderItem {
  const CafeOrderItem({
    required this.name,
    required this.quantity,
    this.customization,
  });

  final String name;
  final int quantity;
  final String? customization;
}

class CafeOrder {
  CafeOrder({
    required this.id,
    required this.customerName,
    required this.orderType,
    required this.total,
    required this.items,
    required this.status,
    required this.placedAt,
  });

  final String id;
  final String customerName;
  final String orderType;
  final double total;
  final List<CafeOrderItem> items;
  String status; // 'Pending', 'Preparing', 'Ready', 'Completed'
  final DateTime placedAt;
}

abstract final class CafeOrdersData {
  static final ValueNotifier<List<CafeOrder>> ordersNotifier =
      ValueNotifier<List<CafeOrder>>([
    CafeOrder(
      id: '110',
      customerName: 'Sarah K.',
      orderType: 'Dine-in',
      total: 5.50,
      items: const [
        CafeOrderItem(
          name: 'Cascara Sparkling Tonic',
          quantity: 1,
          customization: 'Highball',
        ),
      ],
      status: 'Pending',
      placedAt: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    CafeOrder(
      id: '108',
      customerName: 'John M.',
      orderType: 'Takeaway',
      total: 14.50,
      items: const [
        CafeOrderItem(
          name: 'Iced Americano',
          quantity: 2,
          customization: 'Oat milk',
        ),
        CafeOrderItem(
          name: 'Butter Croissant',
          quantity: 1,
          customization: 'Warmed',
        ),
      ],
      status: 'Preparing',
      placedAt: DateTime.now().subtract(const Duration(minutes: 6)),
    ),
    CafeOrder(
      id: '109',
      customerName: 'Alex R.',
      orderType: 'Table 04',
      total: 14.99,
      items: const [
        CafeOrderItem(
          name: 'Flat White',
          quantity: 1,
          customization: 'Oat Milk',
        ),
        CafeOrderItem(
          name: 'Cardamom Brioche Bun',
          quantity: 1,
          customization: 'Warm',
        ),
      ],
      status: 'Preparing',
      placedAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    CafeOrder(
      id: '107',
      customerName: 'Jamie L.',
      orderType: 'Takeaway',
      total: 8.25,
      items: const [
        CafeOrderItem(
          name: 'Caramel Macchiato',
          quantity: 1,
          customization: 'Extra Hot',
        ),
      ],
      status: 'Ready',
      placedAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
  ]);

  static void updateOrderStatus(String orderId, String newStatus) {
    final list = ordersNotifier.value;
    for (final order in list) {
      if (order.id == orderId) {
        order.status = newStatus;
        break;
      }
    }
    ordersNotifier.value = List.from(list);
  }
}
