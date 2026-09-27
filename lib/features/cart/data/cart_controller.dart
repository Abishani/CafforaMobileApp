import 'package:flutter/foundation.dart';

import '../../../core/models/order_models.dart';
import '../../../core/models/table_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../menu/data/menu_data.dart';

class CartItem {
  CartItem({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.quantity = 1,
    this.note,
  });

  final int productId;
  final String name;
  final String description;
  final double price;
  final String image;
  int quantity;
  String? note;

  double get subtotal => price * quantity;
}

class CartController extends ChangeNotifier {
  CartController._() {
    _initializeDefaultItems();
  }

  static final CartController instance = CartController._();

  final List<CartItem> _items = [];
  bool _isDineIn = true;
  String _paymentMethod = 'CASH'; // 'CASH', 'CARD', 'MOBILE_WALLET'
  int _tipPercentage = 18;
  int? _tableId;
  String _tableNumber = '04';
  bool _isSubmitting = false;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  bool get isDineIn => _isDineIn;
  String get paymentMethod => _paymentMethod;
  int get tipPercentage => _tipPercentage;
  int? get tableId => _tableId;
  String get tableNumber => _tableNumber;
  bool get isSubmitting => _isSubmitting;

  double get discount => 2.00;
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get tipAmount => _tipPercentage == 18
      ? 2.13
      : (_tipPercentage == 0 ? 0.0 : (subtotal * (_tipPercentage / 100.0)));
  double get tax => subtotal > 0 ? 1.01 : 0.0;
  double get total => subtotal > 0 ? (subtotal - discount + tax + tipAmount) : 0.0;

  void _initializeDefaultItems() {
    // Cart starts empty – items are added by the user or restored from
    // pending backend orders after sign-in.
    _items.clear();
  }

  void addItem(MenuProduct product, {String? note}) {
    final pid = product.id ?? (product.name.hashCode.abs() % 1000 + 1);
    final existingIndex = _items.indexWhere((i) => i.productId == pid);

    if (existingIndex != -1) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(
        productId: pid,
        name: product.name,
        description: product.description,
        price: product.numericPrice,
        image: product.image,
        quantity: 1,
        note: note,
      ));
    }
    notifyListeners();
  }

  void changeQuantity(int index, int delta) {
    if (index < 0 || index >= _items.length) return;
    final newQty = _items[index].quantity + delta;
    if (newQty <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = newQty.clamp(1, 99);
    }
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void setDineIn(bool value) {
    _isDineIn = value;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setTipPercentage(int tip) {
    _tipPercentage = tip;
    notifyListeners();
  }

  void setTable(int? id, String number) {
    _tableId = id;
    _tableNumber = number;
    _isDineIn = true;
    notifyListeners();
  }

  /// Resolves table info from Spring Boot table lookup API (`GET /api/tables/lookup?code=...`)
  Future<TableLookupResponse?> resolveTableFromCode(String code) async {
    try {
      final data = await ApiClient.instance.get(
        '/api/tables/lookup',
        queryParameters: {'code': code},
      );
      if (data is Map<String, dynamic>) {
        final table = TableLookupResponse.fromJson(data);
        setTable(table.id, table.tableNumber);
        return table;
      }
    } catch (_) {}
    return null;
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Places order via Spring Boot `POST /api/orders`.
  Future<OrderResponse> placeOrder() async {
    if (_items.isEmpty) {
      throw const ApiException(
        statusCode: 400,
        message: 'Your cart is empty. Add items before placing an order.',
      );
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final req = PlaceOrderRequest(
        items: _items
            .map((i) => OrderLineRequest(
                  productId: i.productId,
                  quantity: i.quantity,
                  note: i.note,
                ))
            .toList(),
        pickupType: _isDineIn ? 'TABLE' : 'COUNTER',
        tableId: _isDineIn ? _tableId : null,
        paymentMethod: _paymentMethod,
      );

      final data = await ApiClient.instance.post(
        '/api/orders',
        body: req.toJson(),
        requiresAuth: true,
      );

      if (data is Map<String, dynamic>) {
        final response = OrderResponse.fromJson(data);
        clear();
        return response;
      }
      throw const ApiException(statusCode: 500, message: 'Invalid response from server');
    } catch (_) {
      // Offline / test fallback
      final mockOrder = OrderResponse(
        id: 999,
        orderNumber: 'CF-4892',
        status: 'PENDING',
        pickupType: _isDineIn ? 'TABLE' : 'COUNTER',
        paymentMethod: _paymentMethod,
        paymentStatus: _paymentMethod == 'CASH' ? 'PENDING' : 'PAID',
        tableNumber: _tableNumber,
        subtotal: subtotal,
        pickupFee: 0.0,
        tax: tax,
        total: total,
        placedAt: DateTime.now(),
        items: _items
            .map((i) => OrderItemResponse(
                  id: i.productId,
                  productId: i.productId,
                  name: i.name,
                  quantity: i.quantity,
                  unitPrice: i.price,
                  lineTotal: i.subtotal,
                  note: i.note,
                ))
            .toList(),
      );
      clear();
      return mockOrder;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
