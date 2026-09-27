import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/models/order_models.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/cafe_orders_data.dart';

/// Shows a bottom sheet with a generated pickup QR code for an order.
///
/// The QR encodes: `CAFFORA_ORDER:<orderId>:VERIFY`
/// Staff scan this to mark the order as Completed.
void showPickupQrSheet(
  BuildContext context, {
  required String orderId,
  required String orderLabel,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PickupQrSheet(
      orderId: orderId,
      orderLabel: orderLabel,
    ),
  );
}

class _PickupQrSheet extends StatefulWidget {
  const _PickupQrSheet({
    required this.orderId,
    required this.orderLabel,
  });

  final String orderId;
  final String orderLabel;

  @override
  State<_PickupQrSheet> createState() => _PickupQrSheetState();
}

class _PickupQrSheetState extends State<_PickupQrSheet> {
  String get _qrData => 'CAFFORA_ORDER:${widget.orderId}:VERIFY';
  bool _isCompleted = false;
  Timer? _statusCheckTimer;

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();
    CafeOrdersData.ordersNotifier.addListener(_onOrdersChanged);
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _checkBackendStatus();
    });
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    CafeOrdersData.ordersNotifier.removeListener(_onOrdersChanged);
    super.dispose();
  }

  Future<void> _checkBackendStatus() async {
    if (_isCompleted) return;
    try {
      final cleanId = widget.orderId.replaceAll(RegExp(r'\D'), '');
      final targetId = cleanId.isNotEmpty ? cleanId : widget.orderId;
      final data = await ApiClient.instance.get(
        '/api/orders/$targetId',
        requiresAuth: true,
      );
      if (data is Map<String, dynamic>) {
        final res = OrderResponse.fromJson(data);
        if (res.status.toUpperCase() == 'COMPLETED') {
          if (mounted && !_isCompleted) {
            setState(() {
              _isCompleted = true;
            });
          }
        }
      }
    } catch (_) {}
  }

  void _checkInitialStatus() {
    final orders = CafeOrdersData.ordersNotifier.value;
    final order = orders.where((o) => o.id == widget.orderId).firstOrNull;
    if (order != null && order.status == 'Completed') {
      _isCompleted = true;
    }
  }

  void _onOrdersChanged() {
    final orders = CafeOrdersData.ordersNotifier.value;
    final order = orders.where((o) => o.id == widget.orderId).firstOrNull;
    if (order != null && order.status == 'Completed') {
      if (!_isCompleted && mounted) {
        setState(() {
          _isCompleted = true;
        });
      }
    }
  }

  Future<void> _handleStaffConfirmPickup() async {
    await CafeOrdersData.updateOrderStatus(widget.orderId, 'Completed');
    if (mounted) {
      setState(() {
        _isCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ───────────────────────────────
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: palette.border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),

          // ── Header ────────────────────────────────────
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _isCompleted
                      ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                      : palette.softSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.qr_code_2_rounded,
                  color: _isCompleted
                      ? const Color(0xFF22C55E)
                      : palette.accentDark,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isCompleted ? 'Pickup Completed!' : 'Pickup QR Code',
                      style: TextStyle(
                        color: palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.3,
                      ),
                    ),
                    Text(
                      widget.orderLabel,
                      style: TextStyle(
                        color: palette.body,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: palette.muted, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── If Completed: Show Pickup Completed State & Place Next Order ──
          if (_isCompleted) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: palette.isDark
                    ? const Color(0xFF1E2E23)
                    : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF86EFAC).withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Order #${widget.orderId} Picked Up!',
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your order has been handed over successfully. Thank you for choosing Caffora! Enjoy your coffee and meal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.body,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 15, color: Color(0xFF16A34A)),
                        SizedBox(width: 6),
                        Text(
                          'Status: Order Completed',
                          style: TextStyle(
                            color: Color(0xFF16A34A),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Next Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/menu');
                },
                icon: const Icon(Icons.coffee_rounded, size: 18),
                label: const Text(
                  'Place Next Order',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.accentDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close Window',
                style: TextStyle(
                  color: palette.body,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else ...[
            // ── QR code card ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.fromBorderSide(
                  BorderSide(color: palette.border),
                ),
                boxShadow: [
                  BoxShadow(
                    color: palette.cardShadow,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: _qrData,
                    version: QrVersions.auto,
                    size: 200,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF1F1612),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF1F1612),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Order ID chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: palette.softSurface,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.fromBorderSide(
                        BorderSide(color: palette.border),
                      ),
                    ),
                    child: Text(
                      'Order #${widget.orderId}',
                      style: TextStyle(
                        color: palette.accentDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Instruction ───────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: palette.softSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: palette.accentDark,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Show this QR to the staff at the counter to confirm pickup and receive your order.',
                      style: TextStyle(
                        color: palette.body,
                        fontSize: 12,
                        height: 18 / 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Action Buttons ─────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _qrData));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text('Order reference copied'),
                            ],
                          ),
                          backgroundColor: const Color(0xFF4C8A65),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(milliseconds: 1500),
                        ),
                      );
                    },
                    icon: Icon(Icons.copy_outlined,
                        size: 15, color: palette.accentDark),
                    label: Text(
                      'Copy Code',
                      style: TextStyle(
                        color: palette.accentDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: palette.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _handleStaffConfirmPickup,
                    icon: const Icon(Icons.verified, size: 15),
                    label: const Text(
                      'Staff Verify',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.accentDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
