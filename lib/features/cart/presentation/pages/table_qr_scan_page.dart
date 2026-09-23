import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_theme.dart';

/// Full-screen QR scanner.
///
/// When a valid payload is scanned:
/// - Table scan: expects `CAFFORA_TABLE:<number>`, pops with `TableScanResult`.
/// - Order scan: expects `CAFFORA_ORDER:<id>:VERIFY`, pops with `OrderScanResult`.
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
  TableScanResult(this.tableNumber);
  final String tableNumber;
}

class OrderScanResult extends QrScanResult {
  OrderScanResult(this.orderId);
  final String orderId;
}

class _TableQrScanPageState extends State<TableQrScanPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    QrScanResult? result;

    if (widget.mode == QrScanMode.table &&
        raw.startsWith('CAFFORA_TABLE:')) {
      final tableNum = raw.replaceFirst('CAFFORA_TABLE:', '').trim();
      if (tableNum.isNotEmpty) {
        result = TableScanResult(tableNum);
      }
    } else if (widget.mode == QrScanMode.order &&
        raw.startsWith('CAFFORA_ORDER:')) {
      // Payload: CAFFORA_ORDER:<orderId>:VERIFY
      final parts = raw.split(':');
      if (parts.length >= 3) {
        result = OrderScanResult(parts[1]);
      }
    }

    if (result != null) {
      _scanned = true;
      _controller.stop();
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final isTable = widget.mode == QrScanMode.table;

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
          isTable ? 'Scan Table QR' : 'Scan Order QR',
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
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(color: palette.accent, width: 3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Stack(
                      children: [
                        // Corner markers
                        ..._corners(palette.accent),
                        // Animated scan line
                        const _ScanLine(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    isTable
                        ? 'Point at the QR code on your table'
                        : 'Point at the customer\'s pickup QR',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Frosted overlay around the scan window ────
          _ScanOverlay(frameSize: 240),
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
            top: isTop
                ? BorderSide(color: color, width: 3)
                : BorderSide.none,
            bottom: !isTop
                ? BorderSide(color: color, width: 3)
                : BorderSide.none,
            left: isLeft
                ? BorderSide(color: color, width: 3)
                : BorderSide.none,
            right: !isLeft
                ? BorderSide(color: color, width: 3)
                : BorderSide.none,
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
