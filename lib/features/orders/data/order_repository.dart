import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/auth/auth_controller.dart';

class OrderListItem {
  const OrderListItem({
    required this.id,
    required this.createdAt,
    required this.itemCount,
    required this.total,
    required this.status,
    this.customerName,
  });

  final String id;
  final DateTime createdAt;
  final int itemCount;
  final double total;
  final String status;
  final String? customerName;
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
  });

  final String id;
  final String userId;
  final DateTime createdAt;
  final String status;
  final List<OrderLineItem> items;
  final String? customerName;
  final String? customerEmail;
  double get total => items.fold(0, (sum, item) => sum + item.subtotal);
}

class OrderRepository {
  const OrderRepository({
    required this.client,
    required this.role,
    required this.userId,
  });

  final SupabaseClient? client;
  final UserRole role;
  final String? userId;

  Future<List<OrderListItem>> fetchOrders() async {
    if (client == null) return _fallbackOrders;
    final query = client!
        .from('Orders')
        .select(
          'id,user_id,status,created_at,Users(name),OrderItems(quantity,unit_price)',
        );
    final rows = role == UserRole.admin
        ? await query.order('created_at', ascending: false)
        : await query
              .eq('user_id', userId!)
              .order('created_at', ascending: false);
    return rows.map(_listItemFromRow).toList();
  }

  Future<OrderDetails> fetchOrder(String orderId) async {
    if (client == null) return _fallbackDetails(orderId);
    final row = await client!
        .from('Orders')
        .select(
          'id,user_id,status,created_at,Users(name,email),OrderItems(quantity,unit_price,MenuItems(name))',
        )
        .eq('id', orderId)
        .single();
    return _detailsFromRow(row);
  }

  Stream<String> watchStatus(String orderId) {
    if (client == null) return const Stream.empty();
    return client!
        .from('Orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map(
          (rows) => rows.isEmpty ? '' : (rows.first['status'] as String? ?? ''),
        );
  }

  Future<void> updateStatus(String orderId, String status) async {
    if (client == null || role != UserRole.admin) return;
    await client!.from('Orders').update({'status': status}).eq('id', orderId);
  }

  OrderListItem _listItemFromRow(Map<String, dynamic> row) {
    final items = List<Map<String, dynamic>>.from(
      row['OrderItems'] ?? const [],
    );
    return OrderListItem(
      id: '${row['id']}',
      createdAt: DateTime.parse(row['created_at']),
      itemCount: items.fold(
        0,
        (sum, item) => sum + (item['quantity'] as int? ?? 0),
      ),
      total: items.fold(
        0.0,
        (sum, item) =>
            sum +
            ((item['quantity'] as num? ?? 0) *
                (item['unit_price'] as num? ?? 0)),
      ),
      status: '${row['status']}',
      customerName: (row['Users'] as Map<String, dynamic>?)?['name'] as String?,
    );
  }

  OrderDetails _detailsFromRow(Map<String, dynamic> row) {
    final items = List<Map<String, dynamic>>.from(
      row['OrderItems'] ?? const [],
    );
    final user = row['Users'] as Map<String, dynamic>?;
    return OrderDetails(
      id: '${row['id']}',
      userId: '${row['user_id']}',
      createdAt: DateTime.parse(row['created_at']),
      status: '${row['status']}',
      customerName: user?['name'] as String?,
      customerEmail: user?['email'] as String?,
      items: items
          .map(
            (item) => OrderLineItem(
              name:
                  '${(item['MenuItems'] as Map<String, dynamic>?)?['name'] ?? 'Menu item'}',
              quantity: item['quantity'] as int? ?? 0,
              unitPrice: (item['unit_price'] as num? ?? 0).toDouble(),
            ),
          )
          .toList(),
    );
  }

  static final _fallbackOrders = [
    OrderListItem(
      id: '4892',
      createdAt: DateTime(2026, 9, 22, 10, 30),
      itemCount: 2,
      total: 14.99,
      status: 'Preparing',
      customerName: 'Alex Morgan',
    ),
    OrderListItem(
      id: '4891',
      createdAt: DateTime(2026, 9, 21, 16, 10),
      itemCount: 3,
      total: 28.50,
      status: 'Ready',
      customerName: 'Jamie Lee',
    ),
    OrderListItem(
      id: '4890',
      createdAt: DateTime(2026, 9, 20, 12, 5),
      itemCount: 1,
      total: 9.75,
      status: 'Completed',
      customerName: 'Sam Rivera',
    ),
  ];

  static OrderDetails _fallbackDetails(String id) => OrderDetails(
    id: id,
    userId: 'demo-user',
    createdAt: DateTime(2026, 9, 22, 10, 30),
    status: 'Preparing',
    customerName: 'Alex Morgan',
    customerEmail: 'alex.morgan@example.com',
    items: const [
      OrderLineItem(name: 'Artisan Flat White', quantity: 1, unitPrice: 6.35),
      OrderLineItem(
        name: 'Wild Berry Brioche Toast',
        quantity: 1,
        unitPrice: 7.50,
      ),
    ],
  );
}
