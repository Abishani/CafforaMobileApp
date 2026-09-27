import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_theme.dart';

/// Full-screen QR scanner with instant QR detection and visual confirmation.
///
/// When a valid payload is scanned:
/// - Table scan: expects `CAFFORA_TABLE:<number>` or `cafe://table/<number>`, pops with `TableScanResult`.
/// - Order scan: expects `CAFFORA_ORDER:<id>:VERIFY` from registered user, pops with `OrderScanResult`.
class TableQrScanPage extends StatefulWidget {
  const TableQrScanPage({super.key, this.mode = QrScanMode.table});

  /// Controls what kind of QR payload this scanner accepts.
  final QrScanMode mode;

  @override
  State<TableQrScanPage> createState() => _TableQrScanPageState();
}

enum QrScanMode { table, order }

sealed class QrScanResult {}

class TableScanResult extends QrScanResult {
  TableScanResult(this.tableNumber, {this.rawCode});
  final String tableNumber;
  final String? rawCode;
}

class OrderScanResult extends QrScanResult {
  OrderScanResult(this.orderId);
  final String orderId;
}

class _TableQrScanPageState extends State<TableQrScanPage> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
  );
  bool _scanned = false;
  String? _detectedLabel;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    final clean = raw.trim();

    QrScanResult? result;

    if (widget.mode == QrScanMode.table) {
      if (clean.startsWith('cafe://table/')) {
        final tableNum = clean.replaceFirst('cafe://table/', '').trim();
        if (tableNum.isNotEmpty) {
          result = TableScanResult(tableNum, rawCode: clean);
        }
      } else if (clean.startsWith('CAFFORA_TABLE:')) {
        final tableNum = clean.replaceFirst('CAFFORA_TABLE:', '').trim();
        if (tableNum.isNotEmpty) {
          result = TableScanResult(tableNum, rawCode: clean);
        }
      } else if (clean.toUpperCase().startsWith('T-')) {
        result = TableScanResult(clean, rawCode: 'cafe://table/$clean');
      }
    } else if (widget.mode == QrScanMode.order) {
      // Strictly match Caffora pickup order QR format: CAFFORA_ORDER:<orderId>:VERIFY or CAFFORA_ORDER:<orderId>
      if (clean.contains('CAFFORA_ORDER:')) {
        final start = clean.indexOf('CAFFORA_ORDER:') + 'CAFFORA_ORDER:'.length;
        final remainder = clean.substring(start);
        final idPart = remainder.split(':').first.trim();
        if (idPart.isNotEmpty) {
          result = OrderScanResult(idPart);
        }
      }
    }

    if (result != null && !_scanned) {
      _scanned = true;
      HapticFeedback.heavyImpact();

      if (mounted) {
        setState(() {
          if (result is OrderScanResult) {
            _detectedLabel = 'Order #${result.orderId} Recognized!';
          } else if (result is TableScanResult) {
            _detectedLabel = 'Table ${result.tableNumber} Recognized!';
          }
        });
      }

      _controller.stop();

      // Hold for 600ms visual confirmation so user clearly sees the scan succeed
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        Navigator.of(context).pop(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final isTable = widget.mode == QrScanMode.table;

    final frameColor = _scanned ? const Color(0xFF22C55E) : palette.accent;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Close scanner',
        ),
        title: Text(
          isTable ? 'Scan Table QR' : 'Scan Customer Pickup QR',
          style: const TextStyle(color: Colors.white, fontSize: 17),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_outlined, color: Colors.white),
            onPressed: () => _controller.toggleTorch(),
            tooltip: 'Toggle flash',
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Camera feed ───────────────────────────────
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // ── Overlay frame ─────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Scanning window
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(color: frameColor, width: _scanned ? 4 : 3),
                    borderRadius: BorderRadius.circular(20),
                    color: _scanned
                        ? const Color(0xFF22C55E).withValues(alpha: 0.25)
                        : Colors.transparent,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Stack(
                      children: [
                        // Corner markers
                        ..._corners(frameColor),
                        // Animated scan line or Success Check
                        if (_scanned)
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF22C55E),
                                  size: 64,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    _detectedLabel ?? 'Recognized!',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const _ScanLine(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _scanned ? const Color(0xFF15803D) : Colors.black87,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: _scanned ? const Color(0xFF86EFAC) : Colors.white24,
                    ),
                  ),
                  child: Text(
                    _scanned
                        ? '✓ $_detectedLabel'
                        : isTable
                            ? 'Point at the QR code on your table'
                            : 'Align customer\'s pickup QR inside the frame',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isTable) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final table in ['T-01', 'T-02', 'T-03'])
                        ActionChip(
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          side: BorderSide(color: palette.accent),
                          label: Text(
                            table,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            _scanned = true;
                            _controller.stop();
                            Navigator.of(context).pop(
                              TableScanResult(table, rawCode: 'cafe://table/$table'),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── Frosted overlay around the scan window ────
          IgnorePointer(child: _ScanOverlay(frameSize: 240)),
        ],
      ),
    );
  }

  List<Widget> _corners(Color color) => [
        _Corner(alignment: Alignment.topLeft, color: color),
        _Corner(alignment: Alignment.topRight, color: color),
        _Corner(alignment: Alignment.bottomLeft, color: color),
        _Corner(alignment: Alignment.bottomRight, color: color),
      ];
}

class _Corner extends StatelessWidget {
  const _Corner({required this.alignment, required this.color});
  final Alignment alignment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;
    return Align(
      alignment: alignment,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? BorderSide(color: color, width: 3) : BorderSide.none,
            bottom: !isTop ? BorderSide(color: color, width: 3) : BorderSide.none,
            left: isLeft ? BorderSide(color: color, width: 3) : BorderSide.none,
            right: !isLeft ? BorderSide(color: color, width: 3) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay({required this.frameSize});
  final double frameSize;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(frameSize: frameSize),
      child: const SizedBox.expand(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  _OverlayPainter({required this.frameSize});
  final double frameSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final half = frameSize / 2;
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTRB(cx - half, cy - half, cx + half, cy + half),
        const Radius.circular(20),
      ))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanLine extends StatefulWidget {
  const _ScanLine();

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (ctx, child) => Positioned(
        top: 240 * _anim.value - 1,
        left: 0,
        right: 0,
        child: Container(
          height: 2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Color(0xFFDE7858), Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }
}
