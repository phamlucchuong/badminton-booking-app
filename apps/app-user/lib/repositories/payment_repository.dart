import '../services/api_client.dart';

/// VNPay payment backed by `/api/payments/vnpay/create`.
class PaymentRepository {
  final ApiClient _api;
  PaymentRepository(this._api);

  /// Returns the VNPay redirect URL for [bookingId].
  Future<String> createVnpayUrl(String bookingId) async {
    final data = await _api.post('/api/payments/vnpay/create',
        query: {'bookingId': bookingId});
    return data as String;
  }
}
