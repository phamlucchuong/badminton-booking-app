/// Thrown when the backend returns a non-200 envelope code or the HTTP
/// request fails. `code` mirrors the backend `ErrorCode` numeric value
/// (or the HTTP status for transport errors).
class ApiException implements Exception {
  final int code;
  final String message;

  ApiException(this.code, this.message);

  @override
  String toString() => 'ApiException($code): $message';
}
