import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static final ApiClient instance = ApiClient();

  final http.Client _client;
  String? _token;

  String? get token => _token;

  void setToken(String? token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> _headers({bool requiresAuth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = '$base$cleanPath';

    final uri = Uri.parse(fullUrl);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final query = <String, String>{};
      queryParameters.forEach((key, value) {
        if (value != null) {
          query[key] = value.toString();
        }
      });
      return uri.replace(queryParameters: query);
    }
    return uri;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
  }) async {
    final uri = _buildUri(path, queryParameters);
    try {
      final response = await _client
          .get(uri, headers: _headers(requiresAuth: requiresAuth))
          .timeout(ApiConfig.timeout);
      return _processResponse(response);
    } on SocketException catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Cannot connect to server. Check your network connection. (${e.message})',
      );
    } on TimeoutException {
      throw const ApiException(
        statusCode: 408,
        message: 'Request timed out. Please try again.',
      );
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    bool requiresAuth = false,
  }) async {
    final uri = _buildUri(path);
    try {
      final response = await _client
          .post(
            uri,
            headers: _headers(requiresAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);
      return _processResponse(response);
    } on SocketException catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Cannot connect to server. Check your network connection. (${e.message})',
      );
    } on TimeoutException {
      throw const ApiException(
        statusCode: 408,
        message: 'Request timed out. Please try again.',
      );
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic body,
    bool requiresAuth = false,
  }) async {
    final uri = _buildUri(path);
    try {
      final response = await _client
          .put(
            uri,
            headers: _headers(requiresAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);
      return _processResponse(response);
    } on SocketException catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Cannot connect to server. Check your network connection. (${e.message})',
      );
    } on TimeoutException {
      throw const ApiException(
        statusCode: 408,
        message: 'Request timed out. Please try again.',
      );
    }
  }

  Future<dynamic> patch(
    String path, {
    dynamic body,
    bool requiresAuth = false,
  }) async {
    final uri = _buildUri(path);
    try {
      final response = await _client
          .patch(
            uri,
            headers: _headers(requiresAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);
      return _processResponse(response);
    } on SocketException catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Cannot connect to server. Check your network connection. (${e.message})',
      );
    } on TimeoutException {
      throw const ApiException(
        statusCode: 408,
        message: 'Request timed out. Please try again.',
      );
    }
  }

  Future<dynamic> delete(
    String path, {
    bool requiresAuth = false,
  }) async {
    final uri = _buildUri(path);
    try {
      final response = await _client
          .delete(uri, headers: _headers(requiresAuth: requiresAuth))
          .timeout(ApiConfig.timeout);
      return _processResponse(response);
    } on SocketException catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Cannot connect to server. Check your network connection. (${e.message})',
      );
    } on TimeoutException {
      throw const ApiException(
        statusCode: 408,
        message: 'Request timed out. Please try again.',
      );
    }
  }

  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final bodyString = response.body.trim();

    if (kDebugMode) {
      debugPrint('[API] ${response.request?.method} ${response.request?.url} -> $statusCode');
    }

    if (statusCode >= 200 && statusCode < 300) {
      if (bodyString.isEmpty) return null;
      try {
        return jsonDecode(bodyString);
      } catch (_) {
        return bodyString;
      }
    }

    String message = 'Request failed with status $statusCode';
    Map<String, dynamic>? fieldErrors;

    if (bodyString.isNotEmpty) {
      try {
        final decoded = jsonDecode(bodyString);
        if (decoded is Map<String, dynamic>) {
          if (decoded['message'] != null) {
            message = decoded['message'].toString();
          } else if (decoded['error'] != null) {
            message = decoded['error'].toString();
          }
          if (decoded['fieldErrors'] is Map<String, dynamic>) {
            fieldErrors = decoded['fieldErrors'] as Map<String, dynamic>;
            final firstError = fieldErrors.values.firstOrNull;
            if (firstError != null) {
              message = firstError.toString();
            }
          }
        }
      } catch (_) {
        message = bodyString;
      }
    }

    throw ApiException(
      statusCode: statusCode,
      message: message,
      fieldErrors: fieldErrors,
    );
  }
}
