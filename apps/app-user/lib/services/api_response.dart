import 'dart:convert';
import 'api_exception.dart';

/// Parses the backend's uniform envelope `{code, message, data}`.
class ApiResponse {
  /// Decodes [body], returns `data` when `code == 200`, otherwise throws
  /// [ApiException] with the backend code and message.
  static dynamic unwrap(String body) {
    final Map<String, dynamic> json =
        body.isEmpty ? const {} : jsonDecode(body) as Map<String, dynamic>;
    final int code = (json['code'] ?? 200) as int;
    if (code != 200) {
      throw ApiException(code, (json['message'] ?? 'Unknown error') as String);
    }
    return json['data'];
  }
}
