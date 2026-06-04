import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:app_user/services/api_client.dart';
import 'package:app_user/services/api_exception.dart';

void main() {
  test('get unwraps data and sends bearer token', () async {
    late http.Request captured;
    final mock = MockClient((req) async {
      captured = req;
      return http.Response('{"code":200,"message":"ok","data":[1,2]}', 200);
    });
    final client = ApiClient(
      httpClient: mock,
      baseUrl: 'http://test/badbook',
      tokenProvider: () async => 'TOKEN123',
    );

    final data = await client.get('/api/search/hot');

    expect(data, [1, 2]);
    expect(captured.url.toString(), 'http://test/badbook/api/search/hot');
    expect(captured.headers['Authorization'], 'Bearer TOKEN123');
  });

  test('post throws ApiException on error code', () async {
    final mock = MockClient((req) async => http.Response.bytes(
        utf8.encode('{"code":2002,"message":"Mật khẩu không đúng"}'), 200,
        headers: {'content-type': 'application/json; charset=utf-8'}));
    final client = ApiClient(
      httpClient: mock,
      baseUrl: 'http://test/badbook',
      tokenProvider: () async => null,
    );

    expect(
      () => client.post('/api/auth', body: {'email': 'a', 'password': 'b'}),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 2002)),
    );
  });
}
