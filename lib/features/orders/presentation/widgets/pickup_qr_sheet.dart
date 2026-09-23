import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_theme.dart';

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

class _PickupQrSheet extends StatelessWidget {
  const _PickupQrSheet({
    required this.orderId,
    required this.orderLabel,
  });

  final String orderId;
  final String orderLabel;

  String get _qrData => 'CAFFORA_ORDER:$orderId:VERIFY';

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
                  color: palette.softSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.qr_code_2_rounded,
                  color: palette.accentDark,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup QR Code',
                      style: TextStyle(
                        color: palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.3,
                      ),
                    ),
                    Text(
                      orderLabel,
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
          const SizedBox(height: 24),

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
                    'Order #$orderId',
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
          const SizedBox(height: 20),

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
                    'Show this QR to the staff at the counter, or let them scan it to confirm your pickup.',
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
          const SizedBox(height: 16),

          // ── Copy button ───────────────────────────────
          SizedBox(
            width: double.infinity,
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
                  size: 16, color: palette.accentDark),
              label: Text(
                'Copy Order Reference',
                style: TextStyle(
                  color: palette.accentDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: BorderSide(color: palette.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
