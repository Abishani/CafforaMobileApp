import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/auth/auth_controller.dart';
import 'core/auth/auth_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CafforaApp(authController: await AuthController.create()));
}

class CafforaApp extends StatelessWidget {
  const CafforaApp({super.key, this.authController});

  final AuthController? authController;

  @override
  Widget build(BuildContext context) {
    final controller = authController ?? AuthController.registered();
    return AuthScope(
      controller: controller,
      child: MaterialApp(
        title: 'Caffora',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        onGenerateRoute: controller.routeGuard,
        initialRoute: '/',
      ),
    );
  }
}
