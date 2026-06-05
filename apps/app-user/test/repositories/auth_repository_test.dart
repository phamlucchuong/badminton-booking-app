import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:app_user/services/api_client.dart';
import 'package:app_user/services/token_store.dart';
import 'package:app_user/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('login saves token and returns AuthResult', () async {
    late http.Request captured;
    final mock = MockClient((req) async {
      captured = req;
      return http.Response(
          '{"code":200,"message":"ok","data":{"token":"JWT","authenticated":true}}',
          200);
    });
    final store = TokenStore();
    await store.save('STALE_TOKEN');
    final repo = AuthRepository(
      ApiClient(
          httpClient: mock,
          baseUrl: 'http://test/badbook',
          tokenProvider: store.read),
      store,
    );

    final result = await repo.login('a@b.com', 'pw');

    expect(result.authenticated, isTrue);
    expect(await store.read(), 'JWT');
    expect(captured.headers.containsKey('Authorization'), isFalse);
  });

  test('verifyOtp returns boolean data', () async {
    final mock = MockClient((req) async =>
        http.Response('{"code":200,"message":"ok","data":true}', 200));
    final repo = AuthRepository(
      ApiClient(
          httpClient: mock,
          baseUrl: 'http://test/badbook',
          tokenProvider: () async => null),
      TokenStore(),
    );

    expect(await repo.verifyOtp('a@b.com', '123456'), isTrue);
  });
}
