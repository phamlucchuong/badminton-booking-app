import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_response.dart';

typedef TokenProvider = Future<String?> Function();

/// Thin REST client over the backend. Injects the bearer token, sets JSON
/// headers, and unwraps the `{code, message, data}` envelope via [ApiResponse].
class ApiClient {
  final http.Client _http;
  final String _baseUrl;
  final TokenProvider _tokenProvider;

  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
    required TokenProvider tokenProvider,
  })  : _http = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _tokenProvider = tokenProvider;

  Future<Map<String, String>> _headers() async {
    final token = await _tokenProvider();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) => Uri.parse(
        '$_baseUrl$path',
      ).replace(
        queryParameters:
            query?.map((k, v) => MapEntry(k, v.toString())),
      );

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final res = await _http.get(_uri(path, query), headers: await _headers());
    return ApiResponse.unwrap(res.body);
  }

  Future<dynamic> post(String path,
      {Object? body, Map<String, dynamic>? query}) async {
    final res = await _http.post(_uri(path, query),
        headers: await _headers(), body: body == null ? null : jsonEncode(body));
    return ApiResponse.unwrap(res.body);
  }

  Future<dynamic> put(String path,
      {Object? body, Map<String, dynamic>? query}) async {
    final res = await _http.put(_uri(path, query),
        headers: await _headers(), body: body == null ? null : jsonEncode(body));
    return ApiResponse.unwrap(res.body);
  }

  Future<dynamic> delete(String path) async {
    final res = await _http.delete(_uri(path), headers: await _headers());
    return ApiResponse.unwrap(res.body);
  }
}
