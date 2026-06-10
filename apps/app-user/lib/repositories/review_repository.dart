import '../models/review_dto.dart';
import '../services/api_client.dart';

/// Reviews backed by `/api/reviews`.
class ReviewRepository {
  final ApiClient _api;
  ReviewRepository(this._api);

  /// Returns the first page of reviews for [venueId].
  Future<List<ReviewDto>> getVenueReviews(String venueId) async {
    final data = await _api.get('/api/reviews', query: {
      'targetType': 'VENUE',
      'targetId': venueId,
      'page': '1',
      'size': '10',
    });
    final items = (data as Map<String, dynamic>)['items'] as List? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(ReviewDto.fromJson)
        .toList();
  }

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
