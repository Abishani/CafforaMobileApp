class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
    this.fieldErrors,
  });

  final int statusCode;
  final String message;
  final Map<String, dynamic>? fieldErrors;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;

  @override
  String toString() => message;
}
