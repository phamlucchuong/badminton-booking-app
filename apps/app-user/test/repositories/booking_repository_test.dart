import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:app_user/services/api_client.dart';
import 'package:app_user/repositories/booking_repository.dart';
import 'package:app_user/models/booking.dart';

void main() {
  test('createBooking posts request and parses response', () async {
    late http.Request captured;
    final mock = MockClient((req) async {
      captured = req;
      return http.Response(
          '{"code":200,"message":"ok","data":{"id":"b1","courtName":"Florida","venueName":"Club","status":"PENDING","totalAmount":240000}}',
          200);
    });
    final repo = BookingRepository(ApiClient(
        httpClient: mock, baseUrl: 'http://test/badbook',
        tokenProvider: () async => 'T'));

    final booking = await repo.createBooking(BookingCreateRequest(
      courtId: 'c1', venueId: 'v1', bookingDate: '2026-06-10',
      startTime: '06:00:00', endTime: '08:00:00',
      type: 'HOURLY', paymentMethod: 'VNPAY',
    ));

    expect(booking.id, 'b1');
    expect(captured.url.path, '/badbook/api/bookings');
  });
}
