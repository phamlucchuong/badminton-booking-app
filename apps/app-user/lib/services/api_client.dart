import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
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

  Future<Map<String, String>> _headers({bool authenticated = true}) async {
    final token = authenticated ? await _tokenProvider() : null;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) => Uri.parse(
        '$_baseUrl$path',
      ).replace(
        queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
      );

  String _decodeBody(http.Response res) => res.bodyBytes.isEmpty
      ? ''
      : utf8.decode(res.bodyBytes, allowMalformed: true);

  dynamic _unwrapResponse(http.Response res, Uri uri) {
    final body = _decodeBody(res);
    debugPrint(
        '[ApiClient] ${res.request?.method ?? 'HTTP'} $uri -> ${res.statusCode} $body');
    return ApiResponse.unwrap(body, statusCode: res.statusCode, uri: uri);
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool authenticated = true,
  }) async {
    final uri = _uri(path, query);
    final headers = await _headers(authenticated: authenticated);
    try {
      switch (method) {
        case 'GET':
          return await _http.get(uri, headers: headers);
        case 'POST':
          return await _http.post(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          );
        case 'PUT':
          return await _http.put(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          );
        case 'DELETE':
          return await _http.delete(uri, headers: headers);
        default:
          throw UnsupportedError('Unsupported method: $method');
      }
    } on SocketException catch (e) {
      debugPrint('[ApiClient] SocketException $method $uri: $e');
      throw Exception(
        'Cannot connect to backend at $uri. If you are using an Android emulator, use 10.0.2.2. If you are using a physical device, use localhost only with adb reverse, otherwise use your LAN IP.',
      );
    } on http.ClientException catch (e) {
      debugPrint('[ApiClient] ClientException $method $uri: $e');
      throw Exception('Network request failed for $uri: ${e.message}');
    }
  }

  Future<dynamic> get(String path,
      {Map<String, dynamic>? query, bool authenticated = true}) async {
    final res =
        await _send('GET', path, query: query, authenticated: authenticated);
    return _unwrapResponse(res, _uri(path, query));
  }

  Future<dynamic> post(String path,
      {Object? body,
      Map<String, dynamic>? query,
      bool authenticated = true}) async {
    final res = await _send('POST', path,
        body: body, query: query, authenticated: authenticated);
    return _unwrapResponse(res, _uri(path, query));
  }

  Future<dynamic> put(String path,
      {Object? body,
      Map<String, dynamic>? query,
      bool authenticated = true}) async {
    final res = await _send('PUT', path,
        body: body, query: query, authenticated: authenticated);
    return _unwrapResponse(res, _uri(path, query));
  }

  Future<dynamic> delete(String path, {bool authenticated = true}) async {
    final res = await _send('DELETE', path, authenticated: authenticated);
    return _unwrapResponse(res, _uri(path));
  }
}
