import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:app_user/services/api_client.dart';
import 'package:app_user/repositories/venue_repository.dart';

void main() {
  ApiClient clientReturning(String body) => ApiClient(
        httpClient: MockClient((req) async => http.Response(body, 200)),
        baseUrl: 'http://test/badbook',
        tokenProvider: () async => 'T',
      );

  test('getActiveVenues parses the paged content array', () async {
    final repo = VenueRepository(clientReturning(
        '{"code":200,"message":"ok","data":{"content":[{"id":"v1","name":"Club","address":"Hanoi"}],"page":0}}'));
    final venues = await repo.getActiveVenues();
    expect(venues, hasLength(1));
    expect(venues.first.name, 'Club');
  });

  test('getCourts parses a plain list', () async {
    final repo = VenueRepository(clientReturning(
        '{"code":200,"message":"ok","data":[{"id":"c1","venueId":"v1","name":"Florida","pricePerHour":120000}]}'));
    final courts = await repo.getCourts('v1');
    expect(courts.first.pricePerHour, 120000);
  });
}
