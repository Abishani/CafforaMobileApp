import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFFFF8F6);
  static const surface = Colors.white;
  static const softSurface = Color(0xFFFFF1ED);
  static const chipSurface = Color(0xFFF8DDD4);
  static const ink = Color(0xFF2B1810);
  static const body = Color(0xFF765446);
  static const muted = Color(0xFF89726B);
  static const accent = Color(0xFFDE7858);
  static const accentDark = Color(0xFFC86240);
  static const border = Color(0x80DCC1B8);
}

abstract final class AppSpacing {
  static const page = 16.0;
  static const section = 32.0;
  static const grid = 16.0;
  static const card = 8.0;
}

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.accent,
        onPrimary: Colors.white,
        surface: AppColors.background,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Plus Jakarta Sans',
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
    );
  }
}
