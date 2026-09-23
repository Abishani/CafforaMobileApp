import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/auth_scope.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/order_repository.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});
  final String orderId;
  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Future<OrderDetails> _details;
  StreamSubscription<String>? _statusSubscription;
  String? _liveStatus;
  OrderRepository get _repository {
    final auth = AuthScope.maybeOf(context);
    return OrderRepository(
      client: auth?.client,
      role: auth?.role ?? UserRole.registered,
      userId: auth?.userId,
    );
  }

  @override
  void initState() {
    super.initState();
    _details = _load();
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
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
