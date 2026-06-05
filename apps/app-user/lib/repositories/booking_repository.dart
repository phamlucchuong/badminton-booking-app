import '../services/api_client.dart';
import '../models/booking.dart';

/// Booking operations backed by `/api/bookings`.
class BookingRepository {
  final ApiClient _api;
  BookingRepository(this._api);

  Future<Booking> createBooking(BookingCreateRequest request) async {
    final data = await _api.post('/api/bookings', body: request.toJson());
    return Booking.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Booking>> myBookings({int page = 0}) async {
    final data = await _api.get('/api/bookings/my', query: {'page': page});
    final list = data is Map<String, dynamic> ? data['content'] : data;
    return (list as List)
        .map((e) => Booking.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Booking> cancel(String id, {String? reason}) async {
    final data = await _api.put('/api/bookings/$id/cancel',
        query: reason == null ? null : {'reason': reason});
    return Booking.fromJson(data as Map<String, dynamic>);
  }
}
