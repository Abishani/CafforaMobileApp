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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order details'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Back',
        ),
      ),
      body: FutureBuilder<OrderDetails>(
        future: _details,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: snapshot.hasError
                  ? Text('Unable to load order: ${snapshot.error}')
                  : const CircularProgressIndicator(
                      color: AppColors.accentDark,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: const Border.fromBorderSide(
                    BorderSide(color: AppColors.border),
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
                            style: const TextStyle(
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
                      style: const TextStyle(
                        color: AppColors.body,
                        fontSize: 12,
                      ),
                    ),
                    if (isAdmin && order.customerName != null) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'Customer',
                        style: TextStyle(color: AppColors.body, fontSize: 12),
                      ),
                      Text(
                        order.customerName!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (order.customerEmail != null)
                        Text(
                          order.customerEmail!,
                          style: const TextStyle(
                            color: AppColors.body,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: const Border.fromBorderSide(
                    BorderSide(color: AppColors.border),
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
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '\$${item.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.body,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(color: AppColors.border),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Order total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${order.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.accentDark,
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
                  decoration: const InputDecoration(
                    labelText: 'Update status',
                    border: OutlineInputBorder(),
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.softSurface,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      status,
      style: const TextStyle(
        color: AppColors.accentDark,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
