import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/auth/auth_controller.dart';
import 'core/auth/auth_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = await AuthController.create();
  final themeController = ThemeController();
  runApp(CafforaApp(
    authController: auth,
    themeController: themeController,
  ));
}

class CafforaApp extends StatelessWidget {
  const CafforaApp({
    super.key,
    this.authController,
    this.themeController,
  });

  final AuthController? authController;
  final ThemeController? themeController;

  @override
  Widget build(BuildContext context) {
    final auth = authController ?? AuthController.registered();
    final theme = themeController ?? ThemeController();

    return AuthScope(
      controller: auth,
      child: ThemeScope(
        controller: theme,
        child: ListenableBuilder(
          listenable: theme,
          builder: (context, _) {
            return MaterialApp(
              title: 'Caffora',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: theme.themeMode,
              onGenerateRoute: auth.routeGuard,
              initialRoute: '/',
            );
          },
        ),
      ),
    );
  }
}
