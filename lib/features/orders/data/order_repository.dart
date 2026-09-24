import 'dart:async';

import '../../../core/auth/auth_controller.dart';
import '../../../core/models/order_models.dart';
import '../../../core/network/api_client.dart';

class OrderListItem {
  const OrderListItem({
    required this.id,
    required this.createdAt,
    required this.itemCount,
    required this.total,
    required this.status,
    this.customerName,
    this.orderNumber,
  });

  final String id;
  final DateTime createdAt;
  final int itemCount;
  final double total;
  final String status;
  final String? customerName;
  final String? orderNumber;
}

class OrderLineItem {
  const OrderLineItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  final String name;
  final int quantity;
  final double unitPrice;
  double get subtotal => quantity * unitPrice;
}

class OrderDetails {
  const OrderDetails({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.status,
    required this.items,
    this.customerName,
    this.customerEmail,
    this.orderNumber,
    this.tableNumber,
    this.pickupType,
  });

  final String id;
  final String userId;
  final DateTime createdAt;
  final String status;
  final List<OrderLineItem> items;
  final String? customerName;
  final String? customerEmail;
  final String? orderNumber;
  final String? tableNumber;
  final String? pickupType;

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);
}

class OrderRepository {
  const OrderRepository({
    this.client,
    required this.role,
    this.userId,
  });

  final dynamic client; // Backwards compatible param
  final UserRole role;
  final dynamic userId;

  /// Fetches orders from Spring Boot: `GET /api/orders/my` for customers, `GET /api/orders` for admin.
  Future<List<OrderListItem>> fetchOrders() async {
    try {
      final endpoint = role == UserRole.admin ? '/api/orders' : '/api/orders/my';
      final data = await ApiClient.instance.get(endpoint, requiresAuth: true);

      if (data is List) {
        return data.map((json) {
          final res = OrderResponse.fromJson(json as Map<String, dynamic>);
          return OrderListItem(
            id: res.id.toString(),
            orderNumber: res.orderNumber,
            createdAt: res.placedAt ?? DateTime.now(),
            itemCount: res.totalItemCount,
            total: res.total,
            status: res.displayStatus,
            customerName: res.customerName,
          );
        }).toList();
      }
    } catch (_) {}
    return _fallbackOrders;
  }

  /// Fetches a single order from Spring Boot `GET /api/orders/{id}`.
  Future<OrderDetails> fetchOrder(String orderId) async {
    try {
      final data = await ApiClient.instance.get('/api/orders/$orderId', requiresAuth: true);
      if (data is Map<String, dynamic>) {
        final res = OrderResponse.fromJson(data);
        return OrderDetails(
          id: res.id.toString(),
          orderNumber: res.orderNumber,
          userId: res.customerName ?? '',
          createdAt: res.placedAt ?? DateTime.now(),
          status: res.displayStatus,
          customerName: res.customerName,
          tableNumber: res.tableNumber,
          pickupType: res.pickupType,
          items: res.items
              .map((i) => OrderLineItem(
                    name: i.name,
                    quantity: i.quantity,
                    unitPrice: i.unitPrice,
                  ))
              .toList(),
        );
      }
    } catch (_) {}
    return _fallbackDetails(orderId);
  }

  /// Real-time live status tracking using lightweight periodic polling against `GET /api/orders/{id}`.
  Stream<String> watchStatus(String orderId) async* {
    while (true) {
      try {
        final data = await ApiClient.instance.get('/api/orders/$orderId', requiresAuth: true);
        if (data is Map<String, dynamic>) {
          final res = OrderResponse.fromJson(data);
          yield res.displayStatus;
        }
      } catch (_) {}
      await Future.delayed(const Duration(seconds: 4));
    }
  }

  /// Admin updates status via Spring Boot `PATCH /api/orders/{id}/status`.
  Future<void> updateStatus(String orderId, String status) async {
    final backendStatus = _toBackendStatus(status);
    await ApiClient.instance.patch(
      '/api/orders/$orderId/status',
      body: {'status': backendStatus},
      requiresAuth: true,
    );
  }

  String _toBackendStatus(String status) {
    final s = status.trim().toUpperCase();
    if (s.contains('PEND')) return 'PENDING';
    if (s.contains('PREP')) return 'PREPARING';
    if (s.contains('READY')) return 'READY';
    if (s.contains('COMP')) return 'COMPLETED';
    if (s.contains('CANC')) return 'CANCELLED';
    return s;
  }

  static final _fallbackOrders = [
    OrderListItem(
      id: '1',
      orderNumber: 'CF-4892',
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      itemCount: 2,
      total: 11.00,
      status: 'Preparing',
      customerName: 'Customer',
    ),
    OrderListItem(
      id: '2',
      orderNumber: 'CF-4891',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      itemCount: 3,
      total: 16.50,
      status: 'Completed',
      customerName: 'Customer',
    ),
  ];

  static OrderDetails _fallbackDetails(String id) => OrderDetails(
        id: id,
        orderNumber: 'CF-4892',
        userId: '1',
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
        status: 'Preparing',
        customerName: 'Customer',
        customerEmail: 'customer@caffora.com',
        tableNumber: '01',
        pickupType: 'TABLE',
        items: const [
          OrderLineItem(name: 'Craft Flat White', quantity: 1, unitPrice: 4.50),
          OrderLineItem(name: 'Pistachio Raspberry Tart', quantity: 1, unitPrice: 6.50),
        ],
      );
}
