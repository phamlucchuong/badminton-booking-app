import 'dart:convert';

import 'api_exception.dart';

/// Parses the backend's uniform envelope `{code, message, data}` and degrades
/// gracefully when the server returns a non-envelope JSON error body.
class ApiResponse {
  static dynamic unwrap(
    String body, {
    required int statusCode,
    required Uri uri,
  }) {
    if (body.isEmpty) {
      if (statusCode >= 400) {
        throw ApiException(statusCode,
            'Request to $uri failed with HTTP $statusCode and an empty response body.');
      }
      return null;
    }

    final dynamic decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      if (statusCode >= 400) {
        throw ApiException(
            statusCode, 'Request to $uri failed with HTTP $statusCode.');
      }
      throw ApiException(statusCode, 'Unexpected response format from $uri.');
    }

    if (decoded.containsKey('code')) {
      final codeValue = decoded['code'];
      final int code = codeValue is int
          ? codeValue
          : int.tryParse('$codeValue') ?? statusCode;
      if (code != 200) {
        throw ApiException(
            code, (decoded['message'] ?? 'Unknown error') as String);
      }
      return decoded['data'];
    }

    if (statusCode >= 400) {
      final message = (decoded['message'] ??
          decoded['error'] ??
          'Request failed') as String;
      final status = decoded['status'];
      final int code = status is int ? status : statusCode;
      throw ApiException(code, message);
    }

    return decoded['data'] ?? decoded;
  }
}
