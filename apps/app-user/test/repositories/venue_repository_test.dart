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

  test('getActiveVenues parses the paged items array and defaults to page 1', () async {
    late http.Request captured;
    final mock = MockClient((req) async {
      captured = req;
      return http.Response(
          '{"code":200,"message":"ok","data":{"items":[{"id":"v1","name":"Club","address":"Hanoi"}],"total":1,"page":1,"pageSize":10,"totalPages":1}}',
          200);
    });
    final repo = VenueRepository(ApiClient(
        httpClient: mock,
        baseUrl: 'http://test/badbook',
        tokenProvider: () async => 'T'));

    final venues = await repo.getActiveVenues();
    expect(venues, hasLength(1));
    expect(venues.first.name, 'Club');
    expect(captured.url.queryParameters['page'], '1');
  });

  test('getCourts parses a plain list', () async {
    final repo = VenueRepository(clientReturning(
        '{"code":200,"message":"ok","data":[{"id":"c1","venueId":"v1","name":"Florida","pricePerHour":120000}]}'));
    final courts = await repo.getCourts('v1');
    expect(courts.first.pricePerHour, 120000);
  });

  test('getProducts parses a plain list of products', () async {
    final repo = VenueRepository(clientReturning(
        '{"code":200,"message":"ok","data":[{"id":"p1","venueId":"v1","name":"Racket","price":50000.0,"stock":10,"imageId":"img_url","active":true}]}'));
    final products = await repo.getProducts('v1');
    expect(products.first.price, 50000.0);
    expect(products.first.name, 'Racket');
    expect(products.first.imageId, 'img_url');
  });
}
