import 'package:flutter/foundation.dart';

import '../../../core/models/order_models.dart';
import '../../../core/network/api_client.dart';

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
    this.orderNumber,
  });

  final String id;
  final String customerName;
  final String orderType;
  final double total;
  final List<CafeOrderItem> items;
  String status; // 'Pending', 'Preparing', 'Ready', 'Completed'
  final DateTime placedAt;
  final String? orderNumber;

  factory CafeOrder.fromResponse(OrderResponse res) {
    String type = 'Takeaway';
    if (res.pickupType.toUpperCase() == 'TABLE') {
      type = res.tableNumber != null && res.tableNumber!.isNotEmpty
          ? 'Table ${res.tableNumber}'
          : 'Dine-in';
    }

    return CafeOrder(
      id: res.id.toString(),
      orderNumber: res.orderNumber,
      customerName: (res.customerName != null && res.customerName!.isNotEmpty)
          ? res.customerName!
          : 'Guest Customer',
      orderType: type,
      total: res.total,
      status: res.displayStatus,
      placedAt: res.placedAt ?? DateTime.now(),
      items: res.items
          .map((i) => CafeOrderItem(
                name: i.name,
                quantity: i.quantity,
                customization: i.note,
              ))
          .toList(),
    );
  }
}

abstract final class CafeOrdersData {
  static final ValueNotifier<List<CafeOrder>> ordersNotifier =
      ValueNotifier<List<CafeOrder>>(_initialOrders);

  /// Loads live orders queue from Spring Boot `GET /api/orders`.
  static Future<void> loadOrdersQueue({bool activeOnly = false}) async {
    try {
      final query = activeOnly ? {'active': 'true'} : <String, dynamic>{};
      final data = await ApiClient.instance.get('/api/orders', queryParameters: query, requiresAuth: true);

      if (data is List) {
        final list = data
            .map((json) => CafeOrder.fromResponse(OrderResponse.fromJson(json as Map<String, dynamic>)))
            .toList();

        ordersNotifier.value = list;
        return;
      }
    } catch (_) {}
  }

  /// Updates status on Spring Boot `PATCH /api/orders/{id}/status`.
  static Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final backendStatus = _toBackendStatus(newStatus);

    // Optimistic UI update
    final currentList = List<CafeOrder>.from(ordersNotifier.value);
    final index = currentList.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      currentList[index].status = newStatus;
      ordersNotifier.value = currentList;
    }

    try {
      await ApiClient.instance.patch(
        '/api/orders/$orderId/status',
        body: {'status': backendStatus},
        requiresAuth: true,
      );
    } catch (_) {}

    // Refresh from backend
    await loadOrdersQueue();
  }

  static String _toBackendStatus(String status) {
    final s = status.trim().toUpperCase();
    if (s.contains('PEND')) return 'PENDING';
    if (s.contains('PREP')) return 'PREPARING';
    if (s.contains('READY')) return 'READY';
    if (s.contains('COMP')) return 'COMPLETED';
    if (s.contains('CANC')) return 'CANCELLED';
    return s;
  }

  static final _initialOrders = [
    CafeOrder(
      id: '1',
      orderNumber: 'CF-1001',
      customerName: 'Sarah K.',
      orderType: 'Table 01',
      total: 11.00,
      items: const [
        CafeOrderItem(name: 'Craft Flat White', quantity: 1, customization: 'Oat milk'),
        CafeOrderItem(name: 'Pistachio Raspberry Tart', quantity: 1),
      ],
      status: 'Pending',
      placedAt: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    CafeOrder(
      id: '2',
      orderNumber: 'CF-1002',
      customerName: 'John M.',
      orderType: 'Takeaway',
      total: 14.50,
      items: const [
        CafeOrderItem(name: 'Craft Flat White', quantity: 2, customization: 'Extra shot'),
      ],
      status: 'Preparing',
      placedAt: DateTime.now().subtract(const Duration(minutes: 6)),
    ),
  ];
}
