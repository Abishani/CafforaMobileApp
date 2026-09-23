import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({ThemeMode initialMode = ThemeMode.system})
      : _themeMode = initialMode;

  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  String get themeModeName {
    switch (_themeMode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void setThemeModeByName(String name) {
    switch (name) {
      case 'System':
        setThemeMode(ThemeMode.system);
        break;
      case 'Light':
        setThemeMode(ThemeMode.light);
        break;
      case 'Dark':
        setThemeMode(ThemeMode.dark);
        break;
    }
  }
}

class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'No ThemeScope found in context');
    return scope!.notifier!;
  }

  static ThemeController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeScope>()?.notifier;
  }
}
