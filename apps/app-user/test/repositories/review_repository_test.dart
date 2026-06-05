import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:app_user/services/api_client.dart';
import 'package:app_user/repositories/review_repository.dart';

void main() {
  test('createReview posts the review payload', () async {
    late http.Request captured;
    final mock = MockClient((req) async {
      captured = req as http.Request;
      return http.Response('{"code":200,"message":"ok","data":{"id":"r1"}}', 200);
    });
    final repo = ReviewRepository(ApiClient(
        httpClient: mock, baseUrl: 'http://test/badbook',
        tokenProvider: () async => 'T'));

    await repo.createReview(
      bookingId: 'b1', targetType: 'VENUE', targetId: 'v1',
      rating: 5, content: 'Great',
    );
    expect(captured.body, contains('"rating":5'));
    expect(captured.body, contains('"targetType":"VENUE"'));
    expect(captured.body, contains('"targetId":"v1"'));
    expect(captured.body, contains('"bookingId":"b1"'));
  });
}
