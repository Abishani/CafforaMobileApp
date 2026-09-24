import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String _envUrl = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_envUrl.isNotEmpty) {
      return _envUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        return 'http://localhost:8080';
    }
  }

  static const Duration timeout = Duration(seconds: 15);
}
