import 'package:flutter/material.dart';

import 'core/network/api_config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/auth/auth_controller.dart';
import 'core/auth/auth_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start with a guest auth controller so runApp is called immediately
  // (avoids blocking the splash screen on slow network timeouts).
  final auth = AuthController.guest();
  final themeController = ThemeController();

  runApp(CafforaApp(
    authController: auth,
    themeController: themeController,
  ));

  // Initialize network config and restore session in the background AFTER
  // the first frame is rendered.
  Future.microtask(() async {
    await ApiConfig.init();
    await auth.restoreSession();
  });
}

class CafforaApp extends StatefulWidget {
  const CafforaApp({
    super.key,
    this.authController,
    this.themeController,
  });

  final AuthController? authController;
  final ThemeController? themeController;

  @override
  State<CafforaApp> createState() => _CafforaAppState();
}

class _CafforaAppState extends State<CafforaApp> {
  late AuthController _auth;
  late ThemeController _theme;

  @override
  void initState() {
    super.initState();
    _auth = widget.authController ?? AuthController.registered();
    _theme = widget.themeController ?? ThemeController();
  }

  @override
  void didUpdateWidget(covariant CafforaApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.authController != null && widget.authController != _auth) {
      _auth = widget.authController!;
    }
    if (widget.themeController != null && widget.themeController != _theme) {
      _theme = widget.themeController!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      controller: _auth,
      child: ThemeScope(
        controller: _theme,
        child: ListenableBuilder(
          listenable: _theme,
          builder: (context, _) {
            return MaterialApp(
              title: 'Caffora',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: _theme.themeMode,
              onGenerateRoute: _auth.routeGuard,
              initialRoute: '/',
            );
          },
        ),
      ),
    );
  }
}
