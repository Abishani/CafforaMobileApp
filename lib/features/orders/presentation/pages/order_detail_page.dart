import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/auth_scope.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/order_repository.dart';
import '../../../cart/presentation/pages/table_qr_scan_page.dart';
import '../widgets/pickup_qr_sheet.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});
  final String orderId;
  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Future<OrderDetails>? _details;
  bool _initialized = false;
  StreamSubscription<String>? _statusSubscription;
  String? _liveStatus;
  OrderRepository get _repository {
    final auth = AuthScope.maybeOf(context);
    return OrderRepository(
      role: auth?.role ?? UserRole.registered,
      userId: auth?.userId,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _details = _load();
    }
  }

  Future<OrderDetails> _load() async {
    final details = await _repository.fetchOrder(widget.orderId);
    _statusSubscription = _repository.watchStatus(widget.orderId).listen((
      status,
    ) {
      if (status.isNotEmpty && mounted) setState(() => _liveStatus = status);
    });
    return details;
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = AuthScope.maybeOf(context)?.isAdmin ?? false;
    final palette = context.appColors;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(
          'Order details',
          style: TextStyle(color: palette.ink),
        ),
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.chevron_left, color: palette.ink),
          tooltip: 'Back',
        ),
      ),
      body: FutureBuilder<OrderDetails>(
        future: _details,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: snapshot.hasError
                  ? Text(
                      'Unable to load order: ${snapshot.error}',
                      style: TextStyle(color: palette.ink),
                    )
                  : CircularProgressIndicator(
                      color: palette.accentDark,
                    ),
            );
          }
          final order = snapshot.data!;
          final status = _liveStatus ?? order.status;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.fromBorderSide(
                    BorderSide(color: palette.border),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '#${order.id}',
                            style: TextStyle(
                              color: palette.ink,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _StatusBadge(status: status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: palette.body,
                        fontSize: 12,
                      ),
                    ),
                    if (isAdmin && order.customerName != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Customer',
                        style: TextStyle(color: palette.body, fontSize: 12),
                      ),
                      Text(
                        order.customerName!,
                        style: TextStyle(
                          color: palette.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (order.customerEmail != null)
                        Text(
                          order.customerEmail!,
                          style: TextStyle(
                            color: palette.body,
                            fontSize: 12,
                          ),
                        ),
                    ],
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Service / Pickup',
                              style: TextStyle(color: palette.body, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.pickupType == 'TABLE' || order.tableNumber != null
                                  ? 'Dine-In • Table ${order.tableNumber ?? "04"}'
                                  : 'Counter Pickup',
                              style: TextStyle(
                                color: palette.ink,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Payment Method',
                              style: TextStyle(color: palette.body, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  order.paymentMethod?.contains('Card') == true
                                      ? Icons.credit_card
                                      : (order.paymentMethod?.contains('Wallet') == true
                                          ? Icons.account_balance_wallet
                                          : Icons.payments_outlined),
                                  size: 15,
                                  color: palette.accentDark,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  order.paymentMethod ?? 'Cash at Counter',
                                  style: TextStyle(
                                    color: palette.ink,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.fromBorderSide(
                    BorderSide(color: palette.border),
                  ),
                ),
                child: Column(
                  children: [
                    for (final item in order.items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.quantity}x ${item.name}',
                                style: TextStyle(
                                  color: palette.ink,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '\$${item.subtotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: palette.body,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Divider(color: palette.border),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order total',
                          style: TextStyle(
                            color: palette.ink,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${order.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: palette.accentDark,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isAdmin) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  dropdownColor: palette.surface,
                  style: TextStyle(color: palette.ink),
                  decoration: InputDecoration(
                    labelText: 'Update status',
                    labelStyle: TextStyle(color: palette.body),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: palette.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: palette.border),
                    ),
                  ),
                  items: const ['Pending', 'Preparing', 'Ready', 'Completed']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      await _repository.updateStatus(order.id, value);
                      if (mounted) setState(() => _liveStatus = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                // Admin: scan customer's pickup QR to mark Completed
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);
                      final result = await navigator.push<QrScanResult>(
                        MaterialPageRoute(
                          builder: (_) => const TableQrScanPage(
                            mode: QrScanMode.order,
                          ),
                        ),
                      );
                      if (result is OrderScanResult && mounted) {
                        await _repository.updateStatus(
                            order.id, 'Completed');
                        if (mounted) {
                          setState(() => _liveStatus = 'Completed');
                          messenger.showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 8),
                                  Text('Order marked as Completed'),
                                ],
                              ),
                              backgroundColor: const Color(0xFF4C8A65),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              duration: const Duration(milliseconds: 2000),
                            ),
                          );
                        }
                      }
                    },
                    icon: Icon(
                      Icons.qr_code_scanner,
                      size: 18,
                      color: palette.accentDark,
                    ),
                    label: Text(
                      'Scan to Mark Completed',
                      style: TextStyle(
                        color: palette.accentDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: palette.accentDark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
              if (!isAdmin) ...[
                const SizedBox(height: 16),
                if (order.status.toLowerCase() == 'completed') ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Color(0xFF16A34A), size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Order Picked Up & Completed! Enjoy your meal.',
                            style: TextStyle(
                              color: Color(0xFF166534),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/menu', (route) => route.isFirst);
                      },
                      icon: const Icon(Icons.coffee_rounded, size: 18),
                      label: const Text(
                        'Place Next Order',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.accentDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ] else ...[
                  // Customer: show their pickup QR
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => showPickupQrSheet(
                        context,
                        orderId: order.id,
                        orderLabel: 'Order #${order.id}',
                      ),
                      icon: Icon(
                        Icons.qr_code_2,
                        size: 18,
                        color: palette.accentDark,
                      ),
                      label: Text(
                        'Show Pickup QR',
                        style: TextStyle(
                          color: palette.accentDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: palette.border),
                        backgroundColor: palette.softSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 36),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: palette.softSurface,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: palette.accentDark,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
