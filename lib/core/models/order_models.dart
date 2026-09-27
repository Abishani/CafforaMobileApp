class OrderLineRequest {
  const OrderLineRequest({
    required this.productId,
    required this.quantity,
    this.note,
  });

  final int productId;
  final int quantity;
  final String? note;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
        if (note != null && note!.isNotEmpty) 'note': note,
      };
}

class PlaceOrderRequest {
  const PlaceOrderRequest({
    required this.items,
    this.pickupType = 'COUNTER', // "COUNTER" or "TABLE"
    this.tableId,
    this.paymentMethod = 'CASH', // "CASH", "CARD", "MOBILE_WALLET"
  });

  final List<OrderLineRequest> items;
  final String pickupType;
  final int? tableId;
  final String? paymentMethod;

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        'pickupType': pickupType,
        if (tableId != null) 'tableId': tableId,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
      };
}

class OrderItemResponse {
  const OrderItemResponse({
    required this.id,
    this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.note,
    required this.lineTotal,
  });

  final int id;
  final int? productId;
  final String name;
  final double unitPrice;
  final int quantity;
  final String? note;
  final double lineTotal;

  factory OrderItemResponse.fromJson(Map<String, dynamic> json) {
    return OrderItemResponse(
      id: (json['id'] as num).toInt(),
      productId: (json['productId'] as num?)?.toInt(),
      name: json['name'] as String? ?? 'Item',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      note: json['note'] as String?,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OrderResponse {
  const OrderResponse({
    required this.id,
    required this.orderNumber,
    required this.status, // PENDING, PREPARING, READY, COMPLETED, CANCELLED
    required this.pickupType, // COUNTER, TABLE
    this.paymentMethod, // CASH, CARD, MOBILE_WALLET
    this.paymentStatus, // PENDING, PAID, FAILED
    required this.subtotal,
    required this.pickupFee,
    required this.tax,
    required this.total,
    required this.items,
    this.placedAt,
    this.readyAt,
    this.completedAt,
    this.customerName,
    this.tableId,
    this.tableNumber,
  });

  final int id;
  final String orderNumber;
  final String status;
  final String pickupType;
  final String? paymentMethod;
  final String? paymentStatus;
  final double subtotal;
  final double pickupFee;
  final double tax;
  final double total;
  final List<OrderItemResponse> items;
  final DateTime? placedAt;
  final DateTime? readyAt;
  final DateTime? completedAt;
  final String? customerName;
  final int? tableId;
  final String? tableNumber;

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  String get displayPaymentMethod {
    switch (paymentMethod?.toUpperCase()) {
      case 'CARD':
        return 'Card';
      case 'MOBILE_WALLET':
        return 'Mobile Wallet';
      case 'CASH':
      default:
        return 'Cash at Counter';
    }
  }

  String get displayPaymentStatus {
    switch (paymentStatus?.toUpperCase()) {
      case 'PAID':
        return 'Paid';
      case 'PENDING':
        return 'Pending Payment';
      case 'FAILED':
        return 'Payment Failed';
      default:
        return paymentStatus ?? 'Pending';
    }
  }

  String get displayStatus {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'PREPARING':
        return 'Preparing';
      case 'READY':
        return 'Ready';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return null;
      }
    }

    final rawItems = json['items'] as List<dynamic>? ?? [];
    return OrderResponse(
      id: (json['id'] as num).toInt(),
      orderNumber: json['orderNumber'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      pickupType: json['pickupType'] as String? ?? 'COUNTER',
      paymentMethod: json['paymentMethod'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      pickupFee: (json['pickupFee'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      items: rawItems
          .map((i) => OrderItemResponse.fromJson(i as Map<String, dynamic>))
          .toList(),
      placedAt: parseDate(json['placedAt']),
      readyAt: parseDate(json['readyAt']),
      completedAt: parseDate(json['completedAt']),
      customerName: json['customerName'] as String?,
      tableId: (json['tableId'] as num?)?.toInt(),
      tableNumber: json['tableNumber'] as String?,
    );
  }
}
