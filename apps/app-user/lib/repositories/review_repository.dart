import '../services/api_client.dart';

/// Reviews backed by `/api/reviews`.
class ReviewRepository {
  final ApiClient _api;
  ReviewRepository(this._api);

  /// Creates a review. [targetType] is "VENUE" or "COURT"; [targetId] is the
  /// id of that venue/court; [bookingId] ties the review to a completed booking.
  Future<void> createReview({
    required String bookingId,
    required String targetType,
    required String targetId,
    required int rating,
    required String content,
  }) async {
    await _api.post('/api/reviews', body: {
      'bookingId': bookingId,
      'targetType': targetType,
      'targetId': targetId,
      'rating': rating,
      'content': content,
    });
  }
}
