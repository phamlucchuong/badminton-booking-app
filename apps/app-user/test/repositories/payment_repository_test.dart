import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:app_user/services/api_client.dart';
import 'package:app_user/repositories/payment_repository.dart';

void main() {
  test('createVnpayUrl returns the payment URL string', () async {
    late http.Request captured;
    final mock = MockClient((req) async {
      captured = req as http.Request;
      return http.Response(
          '{"code":200,"message":"ok","data":"https://sandbox.vnpayment.vn/pay?x=1"}',
          200);
    });
    final repo = PaymentRepository(ApiClient(
        httpClient: mock, baseUrl: 'http://test/badbook',
        tokenProvider: () async => 'T'));

    final url = await repo.createVnpayUrl('b1');
    expect(url, startsWith('https://sandbox.vnpayment.vn'));
    expect(captured.url.queryParameters['bookingId'], 'b1');
  });
}
