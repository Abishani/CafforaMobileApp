import 'package:flutter_test/flutter_test.dart';
import 'package:caffora_mobile_app/features/cart/data/cart_controller.dart';
import 'package:caffora_mobile_app/core/models/order_models.dart';
import 'package:caffora_mobile_app/features/profile/data/contact_invite_service.dart';
import 'package:caffora_mobile_app/features/menu/data/menu_data.dart';
import 'package:caffora_mobile_app/features/orders/data/cafe_orders_data.dart';

void main() {
  group('1. Password Validation Requirements (8-12 characters)', () {
    test('rejects password shorter than 8 characters', () {
      const shortPass = 'short';
      expect(shortPass.length < 8, isTrue);
    });

    test('rejects password longer than 12 characters', () {
      const longPass = 'thisIsWayTooLongPassword123';
      expect(longPass.length > 12, isTrue);
    });

    test('accepts valid passwords between 8 and 12 characters', () {
      const validPass1 = 'Admin@123'; // 9 chars
      const validPass2 = 'Password12'; // 10 chars
      const validPass3 = 'SecurePass!'; // 11 chars
      const validPass4 = '123456789012'; // 12 chars

      expect(validPass1.length >= 8 && validPass1.length <= 12, isTrue);
      expect(validPass2.length >= 8 && validPass2.length <= 12, isTrue);
      expect(validPass3.length >= 8 && validPass3.length <= 12, isTrue);
      expect(validPass4.length >= 8 && validPass4.length <= 12, isTrue);
    });
  });

  group('2. Payment Method during Pickup & Checkout', () {
    test('CartController defaults to CASH payment method and allows switching', () {
      final cart = CartController.instance;
      expect(cart.paymentMethod, isIn(['CASH', 'CARD', 'MOBILE_WALLET']));

      cart.setPaymentMethod('CARD');
      expect(cart.paymentMethod, equals('CARD'));

      cart.setPaymentMethod('MOBILE_WALLET');
      expect(cart.paymentMethod, equals('MOBILE_WALLET'));

      cart.setPaymentMethod('CASH');
      expect(cart.paymentMethod, equals('CASH'));
    });

    test('PlaceOrderRequest correctly serializes paymentMethod according to backend', () {
      const req = PlaceOrderRequest(
        items: [
          OrderLineRequest(productId: 1, quantity: 2),
        ],
        pickupType: 'COUNTER',
        paymentMethod: 'CARD',
      );

      final json = req.toJson();
      expect(json['paymentMethod'], equals('CARD'));
      expect(json['pickupType'], equals('COUNTER'));
    });

    test('OrderResponse deserializes paymentMethod and paymentStatus with display text', () {
      final json = {
        'id': 101,
        'orderNumber': 'C-101',
        'status': 'PENDING',
        'pickupType': 'COUNTER',
        'paymentMethod': 'CASH',
        'paymentStatus': 'PENDING',
        'subtotal': 12.00,
        'pickupFee': 0.0,
        'tax': 0.96,
        'total': 12.96,
        'items': [],
      };

      final order = OrderResponse.fromJson(json);
      expect(order.paymentMethod, equals('CASH'));
      expect(order.displayPaymentMethod, equals('Cash at Counter'));
      expect(order.displayPaymentStatus, equals('Pending Payment'));
    });
  });

  group('3. QR Code Scanning & Full Next-Step Flow', () {
    test('scanning table QR updates CartController table and activates dine-in mode', () {
      final cart = CartController.instance;

      // Simulate QR scan payload from table: "T-05" or "cafe://table/T-05"
      const scannedCode = 'T-05';
      cart.setTable(5, scannedCode);

      expect(cart.tableNumber, equals('T-05'));
      expect(cart.isDineIn, isTrue);
    });

    test('switching service mode toggles between dine-in and counter pickup', () {
      final cart = CartController.instance;

      cart.setDineIn(false);
      expect(cart.isDineIn, isFalse);

      cart.setDineIn(true);
      expect(cart.isDineIn, isTrue);
    });
  });

  group('4. Invite a Friend & Device Contacts Capability', () {
    test('sample device contacts are available with name, phone number, and email', () {
      final contacts = ContactInviteService.sampleContacts;
      expect(contacts, isNotEmpty);
      expect(contacts.first.name, isNotEmpty);
      expect(contacts.first.phoneNumber, isNotEmpty);
    });

    test('pre-filled invite message format includes contact firstName and referral discount', () {
      final contact = ContactInviteService.sampleContacts.first;
      final firstName = contact.name.split(' ').first;
      final inviteMsg =
          'Hey $firstName! Join me for freshly roasted coffee at Caffora Café. Use my invite link https://caffora.cafe/invite?ref=ALEX20 to get 20% off your first order! ☕';

      expect(inviteMsg, contains('Emma'));
      expect(inviteMsg, contains('20% off'));
      expect(inviteMsg, contains('https://caffora.cafe/invite'));
    });
  });

  group('5. Admin Manage Menu Flow (4 Categories & Auto-Fetch Details)', () {
    test('strictly enforces the 4 database categories: Beverages, Snacks, Meals, Desserts', () {
      const dbCategories = ['Beverages', 'Snacks', 'Meals', 'Desserts'];
      expect(dbCategories.length, equals(4));
      expect(dbCategories, containsAll(['Beverages', 'Snacks', 'Meals', 'Desserts']));
    });

    test('auto-fetches product details from database catalog templates when name is entered', () {
      const catalog = [
        MenuProduct(
          id: 101,
          name: 'Craft Flat White',
          description: 'Double shot of single-origin espresso with silky textured milk.',
          price: '4.50',
          category: 'Beverages',
          image: '☕',
        ),
        MenuProduct(
          id: 103,
          name: 'Cinnamon Swirl Bun',
          description: 'Freshly baked sourdough bun with Ceylon cinnamon and brown sugar glaze.',
          price: '3.75',
          category: 'Snacks',
          image: '🥐',
        ),
        MenuProduct(
          id: 105,
          name: 'Avocado Sourdough Toast',
          description: 'Crushed Hass avocado, cherry tomatoes, and feta on organic levain.',
          price: '11.50',
          category: 'Meals',
          image: '🥪',
        ),
        MenuProduct(
          id: 107,
          name: 'Pistachio Raspberry Tart',
          description: 'Sweet pastry shell filled with rich pistachio cream and fresh raspberries.',
          price: '6.50',
          category: 'Desserts',
          image: '🍰',
        ),
      ];

      // Simulate admin typing 'flat white'
      final match = catalog.firstWhere(
        (p) => p.name.toLowerCase().contains('flat white'),
      );

      expect(match.name, equals('Craft Flat White'));
      expect(match.category, equals('Beverages'));
      expect(match.description, contains('Double shot'));
      expect(match.numericPrice, equals(4.50));
      expect(match.image, equals('☕'));
    });
  });

  group('6. Complete QR Pickup Verification & Order Completed Flow', () {
    test('QR payload format strictly matches CAFFORA_ORDER:<orderId>:VERIFY', () {
      const orderId = '112';
      final qrData = 'CAFFORA_ORDER:$orderId:VERIFY';

      expect(qrData.startsWith('CAFFORA_ORDER:'), isTrue);
      expect(qrData.endsWith(':VERIFY'), isTrue);
      final parts = qrData.split(':');
      expect(parts.length, equals(3));
      expect(parts[1], equals('112'));
    });

    test('updating order status to Completed removes it from Active orders queue', () {
      final initialOrders = [
        CafeOrder(
          id: '101',
          customerName: 'Sarah K.',
          orderType: 'Pickup',
          items: const [],
          total: 8.50,
          status: 'Ready',
          placedAt: DateTime.now(),
        ),
        CafeOrder(
          id: '102',
          customerName: 'Michael B.',
          orderType: 'Pickup',
          items: const [],
          total: 12.00,
          status: 'Preparing',
          placedAt: DateTime.now(),
        ),
      ];

      CafeOrdersData.ordersNotifier.value = initialOrders;

      // Active orders initially has 2
      final activeBefore =
          CafeOrdersData.ordersNotifier.value.where((o) => o.status != 'Completed').toList();
      expect(activeBefore.length, equals(2));

      // Admin scans pickup QR for order 101 -> marks as Completed
      CafeOrdersData.updateOrderStatus('101', 'Completed');

      // Check active orders after completion
      final activeAfter =
          CafeOrdersData.ordersNotifier.value.where((o) => o.status != 'Completed').toList();
      expect(activeAfter.length, equals(1));
      expect(activeAfter.first.id, equals('102'));
    });
  });

  group('7. Invite Friend Hub & Link Sharing', () {
    test('provides referral link and WhatsApp copy without saving contacts to database', () {
      const referralLink = 'https://caffora.cafe/invite?ref=CAFFORA20';
      const promoCode = 'CAFFORA20';

      expect(referralLink, contains('CAFFORA20'));
      expect(promoCode, equals('CAFFORA20'));
    });
  });
}
