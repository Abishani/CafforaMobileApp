import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  ApiConfig._();

  static const String _kCustomUrlKey = 'caffora_server_url';
  static const String _envUrl = String.fromEnvironment('API_URL');
  static String? _resolvedUrl;

  /// Fast-probe an IP and port via raw TCP socket.
  static Future<bool> isReachable(String host, int port, {int timeoutMs = 400}) async {
    try {
      final socket = await Socket.connect(host, port, timeout: Duration(milliseconds: timeoutMs));
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Initialize and detect the active backend base URL.
  static Future<void> init() async {
    if (_envUrl.isNotEmpty) {
      _resolvedUrl = _envUrl;
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString(_kCustomUrlKey);
      if (savedUrl != null && savedUrl.trim().isNotEmpty) {
        _resolvedUrl = savedUrl.trim();
        return;
      }
    } catch (_) {}

    if (kIsWeb) {
      _resolvedUrl = 'http://localhost:8080';
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // 1. Try 127.0.0.1 (physical device connected via USB with `adb reverse tcp:8080 tcp:8080`)
      if (await isReachable('127.0.0.1', 8080, timeoutMs: 300)) {
        _resolvedUrl = 'http://127.0.0.1:8080';
        return;
      }
      // 2. Try 10.0.2.2 (standard Android emulator)
      if (await isReachable('10.0.2.2', 8080, timeoutMs: 300)) {
        _resolvedUrl = 'http://10.0.2.2:8080';
        return;
      }
      // 3. Fallback default
      _resolvedUrl = 'http://10.0.2.2:8080';
      return;
    }

    _resolvedUrl = 'http://localhost:8080';
  }

  static void setBaseUrl(String url) {
    _resolvedUrl = url.trim();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_kCustomUrlKey, _resolvedUrl!);
    }).catchError((_) {});
  }

  static String get baseUrl {
    if (_resolvedUrl != null && _resolvedUrl!.isNotEmpty) {
      return _resolvedUrl!;
    }
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
