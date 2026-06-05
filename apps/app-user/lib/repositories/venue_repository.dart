import '../services/api_client.dart';
import '../models/venue.dart';
import '../models/court.dart';

/// Venue browse, detail, courts, and search backed by `/api/venues`,
/// `/api/search`, and `/api/venues/{id}/courts`.
class VenueRepository {
  final ApiClient _api;
  VenueRepository(this._api);

  List<T> _contentOf<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    final list = data is Map<String, dynamic> ? data['items'] : data;
    return (list as List)
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Venue>> getActiveVenues({int page = 1}) async {
    final data = await _api.get('/api/venues', query: {'page': page});
    return _contentOf(data, Venue.fromJson);
  }

  Future<Venue> getVenue(String id) async {
    final data = await _api.get('/api/venues/$id');
    return Venue.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Venue>> search(String keyword, {int page = 1}) async {
    final data =
        await _api.get('/api/search', query: {'keyword': keyword, 'page': page});
    return _contentOf(data, Venue.fromJson);
  }

  Future<List<String>> hotKeywords({int limit = 10}) async {
    final data = await _api.get('/api/search/hot', query: {'limit': limit});
    return (data as List).map((e) => e.toString()).toList();
  }

  Future<List<Court>> getCourts(String venueId) async {
    final data = await _api.get('/api/venues/$venueId/courts');
    return (data as List)
        .map((e) => Court.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
