import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';

class LoginBrand extends StatelessWidget {
  const LoginBrand({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: palette.softSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: palette.accentDark.withValues(alpha: .15),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Image.asset(AppAssets.logo),
        ),
        const SizedBox(height: 16),
        Text(
          'Welcome back',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: palette.ink,
            fontSize: 28,
            height: 36 / 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -.7,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to continue your Caffora experience.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: palette.body,
            fontSize: 13,
            height: 18 / 13,
          ),
        ),
      ],
    );
  }
}

class LoginField extends StatelessWidget {
  const LoginField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.controller,
  });

  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: palette.ink,
            fontSize: 13,
            height: 20 / 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(color: palette.ink, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: palette.muted, fontSize: 14),
            prefixIcon: Icon(icon, size: 19, color: palette.body),
            filled: true,
            fillColor: palette.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: palette.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: palette.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: palette.accentDark,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(
          label,
          style: TextStyle(
            color: palette.ink,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: palette.surface,
          side: BorderSide(color: palette.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  const _GoogleIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    void drawArc(Color color, double startAngle, double sweepAngle) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 1.75),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    drawArc(const Color(0xFF4285F4), -0.2, 1.75);
    drawArc(const Color(0xFF34A853), 1.55, 1.35);
    drawArc(const Color(0xFFFBBC05), 2.9, 1.25);
    drawArc(const Color(0xFFEA4335), 4.15, 1.70);

    final blueBar = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(center.dx - 1, center.dy),
      Offset(w - 1.5, center.dy),
      blueBar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
