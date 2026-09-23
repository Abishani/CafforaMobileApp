import 'package:flutter/material.dart';

class AppPalette {
  final Color background;
  final Color surface;
  final Color softSurface;
  final Color chipSurface;
  final Color ink;
  final Color body;
  final Color muted;
  final Color accent;
  final Color accentDark;
  final Color border;
  final Color cardShadow;
  final bool isDark;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.softSurface,
    required this.chipSurface,
    required this.ink,
    required this.body,
    required this.muted,
    required this.accent,
    required this.accentDark,
    required this.border,
    required this.cardShadow,
    required this.isDark,
  });
}

abstract final class AppColors {
  // Static Light Palette values
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

  // Dark Palette values
  static const darkBackground = Color(0xFF171210);
  static const darkSurface = Color(0xFF241C18);
  static const darkSoftSurface = Color(0xFF2D221D);
  static const darkChipSurface = Color(0xFF3B2C24);
  static const darkInk = Color(0xFFFFF8F6);
  static const darkBody = Color(0xFFD4BEB6);
  static const darkMuted = Color(0xFF9E847A);
  static const darkAccent = Color(0xFFDE7858);
  static const darkAccentDark = Color(0xFFE5876B);
  static const darkBorder = Color(0xFF3A2D27);

  static const lightPalette = AppPalette(
    background: background,
    surface: surface,
    softSurface: softSurface,
    chipSurface: chipSurface,
    ink: ink,
    body: body,
    muted: muted,
    accent: accent,
    accentDark: accentDark,
    border: border,
    cardShadow: Color(0x0D000000),
    isDark: false,
  );

  static const darkPalette = AppPalette(
    background: darkBackground,
    surface: darkSurface,
    softSurface: darkSoftSurface,
    chipSurface: darkChipSurface,
    ink: darkInk,
    body: darkBody,
    muted: darkMuted,
    accent: darkAccent,
    accentDark: darkAccentDark,
    border: darkBorder,
    cardShadow: Color(0x40000000),
    isDark: true,
  );

  static AppPalette of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? darkPalette : lightPalette;
  }
}

extension AppThemeX on BuildContext {
  AppPalette get appColors => AppColors.of(this);
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
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
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      dividerColor: AppColors.border,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.accent,
        onPrimary: Colors.white,
        secondary: AppColors.accentDark,
        surface: AppColors.background,
        onSurface: AppColors.ink,
        surfaceContainerHighest: AppColors.softSurface,
        outline: AppColors.border,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Plus Jakarta Sans',
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkSurface,
      dividerColor: AppColors.darkBorder,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.darkAccent,
        onPrimary: Colors.white,
        secondary: AppColors.darkAccentDark,
        surface: AppColors.darkBackground,
        onSurface: AppColors.darkInk,
        surfaceContainerHighest: AppColors.darkSoftSurface,
        outline: AppColors.darkBorder,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Plus Jakarta Sans',
        bodyColor: AppColors.darkInk,
        displayColor: AppColors.darkInk,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkInk,
        elevation: 0,
      ),
    );
  }
}
