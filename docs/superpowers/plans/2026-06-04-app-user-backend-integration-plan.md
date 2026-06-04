# App-User ↔ Backend Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Flutter user app's Firebase/Firestore data layer with the existing Spring REST API, delivering the first end-to-end user journey (auth → browse → book → pay → review).

**Architecture:** Introduce a thin networking layer in `apps/app-user/lib/services/` — an `ApiClient` that injects the JWT bearer token, unwraps the backend's `{code, message, data}` envelope, and throws a typed `ApiException`. On top of it, one repository per domain (`AuthRepository`, `VenueRepository`, `BookingRepository`, `PaymentRepository`, `ReviewRepository`) returns plain Dart models. FlutterFlow pages call repositories instead of Firestore queries. Firebase is removed last, once nothing references it.

**Tech Stack:** Flutter, `http` 1.4.0 (already an override), `shared_preferences` 2.5.3 (token persistence), `provider` (state), `flutter_test` + `http`'s `MockClient` for tests. Backend: Spring Boot at context-path `/badbook`, JWT (HS512, 1h expiry, subject = user id, `scope` claim = roles), uniform `ApiResponse<T>` envelope where `code == 200` means success.

**Backend prerequisites (gaps from `docs/knowledge/roadmap.md`).** These requirements have *no* endpoint yet — surface them as blockers, do not invent client behaviour:
- FR-USER-17 profile read/update + change password — needs a `UserController` (service logic exists).
- FR-USER-05 forgot password, FR-USER-04 OAuth2 social login — no backend.
- FR-USER-09 time-slot availability — confirm/define a court-availability endpoint before wiring the matrix.

Tasks 1–24 cover the integration that the current backend already supports. Profile (Task 22) and the matrix availability call (Task 16) include an explicit "if endpoint missing, stop and report" step.

---

## File Structure

Created under `apps/app-user/lib/`:

- `services/api_config.dart` — base URL resolution from `--dart-define`.
- `services/api_exception.dart` — typed error carrying backend code + message.
- `services/api_response.dart` — envelope parser.
- `services/token_store.dart` — JWT persistence via `shared_preferences`.
- `services/api_client.dart` — HTTP verbs + auth header + envelope unwrap.
- `models/auth_models.dart`, `models/venue.dart`, `models/court.dart`, `models/booking.dart`, `models/review.dart` — domain models.
- `repositories/auth_repository.dart`, `repositories/venue_repository.dart`, `repositories/booking_repository.dart`, `repositories/payment_repository.dart`, `repositories/review_repository.dart`.

Tests under `apps/app-user/test/`:
- `services/api_client_test.dart`, `repositories/*_repository_test.dart`.

All commands below run from `apps/app-user/` unless stated.

---

## PHASE 0 — Networking foundation

### Task 1: API base-URL config

**Files:**
- Create: `apps/app-user/lib/services/api_config.dart`

- [ ] **Step 1: Write the config**

```dart
/// Resolves the backend base URL.
///
/// Override per run with:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/badbook
/// Default targets the Android emulator host loopback at the Spring
/// context-path `/badbook`.
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/badbook',
  );
}
```

- [ ] **Step 2: Verify it analyzes**

Run: `flutter analyze lib/services/api_config.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/services/api_config.dart
git commit -m "feat(app-user): add API base-URL config"
```

---

### Task 2: Typed API exception

**Files:**
- Create: `apps/app-user/lib/services/api_exception.dart`

- [ ] **Step 1: Write the exception**

```dart
/// Thrown when the backend returns a non-200 envelope code or the HTTP
/// request fails. `code` mirrors the backend `ErrorCode` numeric value
/// (or the HTTP status for transport errors).
class ApiException implements Exception {
  final int code;
  final String message;

  ApiException(this.code, this.message);

  @override
  String toString() => 'ApiException($code): $message';
}
```

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/services/api_exception.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/services/api_exception.dart
git commit -m "feat(app-user): add ApiException"
```

---

### Task 3: Envelope parser

**Files:**
- Create: `apps/app-user/lib/services/api_response.dart`
- Test: `apps/app-user/test/services/api_response_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app_user/services/api_response.dart';
import 'package:app_user/services/api_exception.dart';

void main() {
  test('unwrap returns data on code 200', () {
    final data = ApiResponse.unwrap('{"code":200,"message":"ok","data":{"x":1}}');
    expect(data, {'x': 1});
  });

  test('unwrap throws ApiException on non-200 code', () {
    expect(
      () => ApiResponse.unwrap('{"code":2001,"message":"Tài khoản không tồn tại"}'),
      throwsA(isA<ApiException>()
          .having((e) => e.code, 'code', 2001)
          .having((e) => e.message, 'message', 'Tài khoản không tồn tại')),
    );
  });

  test('unwrap returns null data when absent', () {
    final data = ApiResponse.unwrap('{"code":200,"message":"ok"}');
    expect(data, isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/api_response_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:app_user/services/api_response.dart'`.

- [ ] **Step 3: Write the implementation**

```dart
import 'dart:convert';
import 'api_exception.dart';

/// Parses the backend's uniform envelope `{code, message, data}`.
class ApiResponse {
  /// Decodes [body], returns `data` when `code == 200`, otherwise throws
  /// [ApiException] with the backend code and message.
  static dynamic unwrap(String body) {
    final Map<String, dynamic> json =
        body.isEmpty ? const {} : jsonDecode(body) as Map<String, dynamic>;
    final int code = (json['code'] ?? 200) as int;
    if (code != 200) {
      throw ApiException(code, (json['message'] ?? 'Unknown error') as String);
    }
    return json['data'];
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/api_response_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/services/api_response.dart test/services/api_response_test.dart
git commit -m "feat(app-user): add API envelope parser with tests"
```

---

### Task 4: Token store

**Files:**
- Create: `apps/app-user/lib/services/token_store.dart`

- [ ] **Step 1: Write the implementation**

```dart
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the JWT access token across launches.
class TokenStore {
  static const _key = 'auth_token';

  Future<void> save(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
```

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/services/token_store.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/services/token_store.dart
git commit -m "feat(app-user): add JWT token store"
```

---

### Task 5: API client

**Files:**
- Create: `apps/app-user/lib/services/api_client.dart`
- Test: `apps/app-user/test/services/api_client_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:app_user/services/api_client.dart';
import 'package:app_user/services/api_exception.dart';

void main() {
  test('get unwraps data and sends bearer token', () async {
    late http.Request captured;
    final mock = MockClient((req) async {
      captured = req;
      return http.Response('{"code":200,"message":"ok","data":[1,2]}', 200);
    });
    final client = ApiClient(
      httpClient: mock,
      baseUrl: 'http://test/badbook',
      tokenProvider: () async => 'TOKEN123',
    );

    final data = await client.get('/api/search/hot');

    expect(data, [1, 2]);
    expect(captured.url.toString(), 'http://test/badbook/api/search/hot');
    expect(captured.headers['Authorization'], 'Bearer TOKEN123');
  });

  test('post throws ApiException on error code', () async {
    final mock = MockClient((req) async =>
        http.Response('{"code":2002,"message":"Mật khẩu không đúng"}', 200));
    final client = ApiClient(
      httpClient: mock,
      baseUrl: 'http://test/badbook',
      tokenProvider: () async => null,
    );

    expect(
      () => client.post('/api/auth', body: {'email': 'a', 'password': 'b'}),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 2002)),
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/api_client_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:app_user/services/api_client.dart'`.

- [ ] **Step 3: Write the implementation**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_response.dart';

typedef TokenProvider = Future<String?> Function();

/// Thin REST client over the backend. Injects the bearer token, sets JSON
/// headers, and unwraps the `{code, message, data}` envelope via [ApiResponse].
class ApiClient {
  final http.Client _http;
  final String _baseUrl;
  final TokenProvider _tokenProvider;

  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
    required TokenProvider tokenProvider,
  })  : _http = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _tokenProvider = tokenProvider;

  Future<Map<String, String>> _headers() async {
    final token = await _tokenProvider();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) => Uri.parse(
        '$_baseUrl$path',
      ).replace(
        queryParameters:
            query?.map((k, v) => MapEntry(k, v.toString())),
      );

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final res = await _http.get(_uri(path, query), headers: await _headers());
    return ApiResponse.unwrap(res.body);
  }

  Future<dynamic> post(String path,
      {Object? body, Map<String, dynamic>? query}) async {
    final res = await _http.post(_uri(path, query),
        headers: await _headers(), body: body == null ? null : jsonEncode(body));
    return ApiResponse.unwrap(res.body);
  }

  Future<dynamic> put(String path,
      {Object? body, Map<String, dynamic>? query}) async {
    final res = await _http.put(_uri(path, query),
        headers: await _headers(), body: body == null ? null : jsonEncode(body));
    return ApiResponse.unwrap(res.body);
  }

  Future<dynamic> delete(String path) async {
    final res = await _http.delete(_uri(path), headers: await _headers());
    return ApiResponse.unwrap(res.body);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/api_client_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/services/api_client.dart test/services/api_client_test.dart
git commit -m "feat(app-user): add ApiClient with auth header and envelope unwrap"
```

---

## PHASE 1 — Authentication (FR-USER-02, FR-USER-03)

### Task 6: Auth models

**Files:**
- Create: `apps/app-user/lib/models/auth_models.dart`

- [ ] **Step 1: Write the models**

```dart
/// Body for `POST /api/auth/register`.
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String phone;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      };
}

/// Result of `POST /api/auth` (the envelope `data`).
class AuthResult {
  final String token;
  final bool authenticated;

  AuthResult({required this.token, required this.authenticated});

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        token: json['token'] as String,
        authenticated: json['authenticated'] as bool? ?? false,
      );
}
```

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/models/auth_models.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/models/auth_models.dart
git commit -m "feat(app-user): add auth models"
```

---

### Task 7: Auth repository

**Files:**
- Create: `apps/app-user/lib/repositories/auth_repository.dart`
- Test: `apps/app-user/test/repositories/auth_repository_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:app_user/services/api_client.dart';
import 'package:app_user/services/token_store.dart';
import 'package:app_user/repositories/auth_repository.dart';
import 'package:app_user/models/auth_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('login saves token and returns AuthResult', () async {
    final mock = MockClient((req) async => http.Response(
        '{"code":200,"message":"ok","data":{"token":"JWT","authenticated":true}}',
        200));
    final store = TokenStore();
    final repo = AuthRepository(
      ApiClient(httpClient: mock, baseUrl: 'http://test/badbook',
          tokenProvider: store.read),
      store,
    );

    final result = await repo.login('a@b.com', 'pw');

    expect(result.authenticated, isTrue);
    expect(await store.read(), 'JWT');
  });

  test('verifyOtp returns boolean data', () async {
    final mock = MockClient((req) async =>
        http.Response('{"code":200,"message":"ok","data":true}', 200));
    final repo = AuthRepository(
      ApiClient(httpClient: mock, baseUrl: 'http://test/badbook',
          tokenProvider: () async => null),
      TokenStore(),
    );

    expect(await repo.verifyOtp('a@b.com', '123456'), isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/repositories/auth_repository_test.dart`
Expected: FAIL — `auth_repository.dart` does not exist.

- [ ] **Step 3: Write the implementation**

```dart
import '../services/api_client.dart';
import '../services/token_store.dart';
import '../models/auth_models.dart';

/// Auth flows backed by `/api/auth`, `/api/auth/register`, `/api/otp/*`.
class AuthRepository {
  final ApiClient _api;
  final TokenStore _tokens;

  AuthRepository(this._api, this._tokens);

  Future<void> register(RegisterRequest request) async {
    await _api.post('/api/auth/register', body: request.toJson());
  }

  Future<void> sendOtp(String email) async {
    await _api.post('/api/otp/send', query: {'email': email});
  }

  Future<bool> verifyOtp(String email, String otp) async {
    final data = await _api.get('/api/otp/verify', query: {
      'email': email,
      'otp': otp,
    });
    return data as bool;
  }

  Future<AuthResult> login(String email, String password) async {
    final data = await _api
        .post('/api/auth', body: {'email': email, 'password': password});
    final result = AuthResult.fromJson(data as Map<String, dynamic>);
    await _tokens.save(result.token);
    return result;
  }

  Future<void> logout() async {
    await _api.post('/api/auth/logout');
    await _tokens.clear();
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/repositories/auth_repository_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/repositories/auth_repository.dart test/repositories/auth_repository_test.dart
git commit -m "feat(app-user): add AuthRepository with register/otp/login/logout"
```

---

### Task 8: Expose repositories app-wide

**Files:**
- Modify: `apps/app-user/lib/app_state.dart`
- Modify: `apps/app-user/lib/main.dart:18-26`

Singletons reachable from FlutterFlow page models without rewiring the whole DI graph.

- [ ] **Step 1: Add a service locator to FFAppState**

Add these fields and getters inside `class FFAppState` (after the existing fields in `app_state.dart`):

```dart
  // --- Backend services (added during backend integration) ---
  final TokenStore tokenStore = TokenStore();
  late final ApiClient apiClient =
      ApiClient(tokenProvider: tokenStore.read);
  late final AuthRepository authRepository =
      AuthRepository(apiClient, tokenStore);

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  set isLoggedIn(bool value) => _isLoggedIn = value;
```

Add imports at the top of `app_state.dart`:

```dart
import 'services/api_client.dart';
import 'services/token_store.dart';
import 'repositories/auth_repository.dart';
```

- [ ] **Step 2: Seed login state at startup**

In `main.dart`, replace the `initializePersistedState` call block (around line 23) so the app knows whether a token is present:

```dart
  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();
  appState.isLoggedIn = (await appState.tokenStore.read()) != null;
```

- [ ] **Step 3: Verify**

Run: `flutter analyze lib/app_state.dart lib/main.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/app_state.dart lib/main.dart
git commit -m "feat(app-user): expose backend services via FFAppState"
```

---

### Task 9: Wire the authentication page

**Files:**
- Modify: `apps/app-user/lib/pages/authentication/` (the page's widget/model — locate the login & sign-up button `onPressed` handlers)

- [ ] **Step 1: Locate the action handlers**

Run: `grep -rn "onPressed\|FFButtonWidget\|TextField\|emailController\|passwordController" lib/pages/authentication/`
Expected: the login button, sign-up button, and field controllers in the page widget.

- [ ] **Step 2: Replace the login button handler**

Replace the login button's `onPressed` body with a call into the repository, reading the page's existing email/password controllers (substitute the real controller names found in Step 1):

```dart
onPressed: () async {
  try {
    await FFAppState().authRepository.login(
          _model.emailTextController.text,
          _model.passwordTextController.text,
        );
    FFAppState().update(() => FFAppState().isLoggedIn = true);
    if (context.mounted) context.goNamed('home_dashboard');
  } on ApiException catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.message)));
  }
},
```

Add `import '/services/api_exception.dart';` to the page file.

- [ ] **Step 3: Replace the sign-up button handler**

```dart
onPressed: () async {
  try {
    await FFAppState().authRepository.register(RegisterRequest(
          name: _model.nameTextController.text,
          email: _model.emailTextController.text,
          password: _model.passwordTextController.text,
          phone: _model.phoneTextController.text,
        ));
    await FFAppState().authRepository.sendOtp(_model.emailTextController.text);
    // Trigger the existing OTP BottomSheet/Dialog component here.
  } on ApiException catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.message)));
  }
},
```

Add `import '/models/auth_models.dart';` to the page file.

- [ ] **Step 4: Wire OTP verify**

In the OTP component's confirm handler, call:

```dart
final ok = await FFAppState().authRepository.verifyOtp(email, enteredOtp);
if (ok && context.mounted) context.goNamed('authentication'); // back to login
```

- [ ] **Step 5: Manual smoke test**

Start backend: from repo root `make compose-up && make run`.
Run app: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/badbook`
Expected: registering a new email triggers OTP; logging in with the seeded values navigates to home.

- [ ] **Step 6: Commit**

```bash
git add lib/pages/authentication/
git commit -m "feat(app-user): wire authentication page to AuthRepository"
```

---

## PHASE 2 — Venue browse & search (FR-USER-06, FR-USER-07, FR-USER-08)

### Task 10: Venue & court models

**Files:**
- Create: `apps/app-user/lib/models/venue.dart`
- Create: `apps/app-user/lib/models/court.dart`

- [ ] **Step 1: Write `venue.dart`**

```dart
/// Mirrors backend `VenueResponse`.
class Venue {
  final String id;
  final String name;
  final String address;
  final String? description;
  final double? latitude;
  final double? longitude;
  final String? status;
  final String? openTime;
  final String? closeTime;

  Venue({
    required this.id,
    required this.name,
    required this.address,
    this.description,
    this.latitude,
    this.longitude,
    this.status,
    this.openTime,
    this.closeTime,
  });

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
        id: json['id'].toString(),
        name: json['name'] as String,
        address: json['address'] as String? ?? '',
        description: json['description'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        status: json['status'] as String?,
        openTime: json['openTime'] as String?,
        closeTime: json['closeTime'] as String?,
      );
}
```

- [ ] **Step 2: Write `court.dart`**

```dart
/// Mirrors backend `CourtResponse`.
class Court {
  final String id;
  final String venueId;
  final String name;
  final String? courtType;
  final double pricePerHour;
  final String? status;
  final String? description;

  Court({
    required this.id,
    required this.venueId,
    required this.name,
    this.courtType,
    required this.pricePerHour,
    this.status,
    this.description,
  });

  factory Court.fromJson(Map<String, dynamic> json) => Court(
        id: json['id'].toString(),
        venueId: json['venueId'].toString(),
        name: json['name'] as String,
        courtType: json['courtType'] as String?,
        pricePerHour: (json['pricePerHour'] as num).toDouble(),
        status: json['status'] as String?,
        description: json['description'] as String?,
      );
}
```

- [ ] **Step 3: Verify & commit**

Run: `flutter analyze lib/models/venue.dart lib/models/court.dart`
Expected: `No issues found!`

```bash
git add lib/models/venue.dart lib/models/court.dart
git commit -m "feat(app-user): add venue and court models"
```

---

### Task 11: Venue repository

**Files:**
- Create: `apps/app-user/lib/repositories/venue_repository.dart`
- Test: `apps/app-user/test/repositories/venue_repository_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/repositories/venue_repository_test.dart`
Expected: FAIL — `venue_repository.dart` does not exist.

- [ ] **Step 3: Write the implementation**

```dart
import '../services/api_client.dart';
import '../models/venue.dart';
import '../models/court.dart';

/// Venue browse, detail, courts, and search backed by `/api/venues`,
/// `/api/search`, and `/api/venues/{id}/courts`.
class VenueRepository {
  final ApiClient _api;
  VenueRepository(this._api);

  List<T> _contentOf<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    final list = data is Map<String, dynamic> ? data['content'] : data;
    return (list as List)
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Venue>> getActiveVenues({int page = 0}) async {
    final data = await _api.get('/api/venues', query: {'page': page});
    return _contentOf(data, Venue.fromJson);
  }

  Future<Venue> getVenue(String id) async {
    final data = await _api.get('/api/venues/$id');
    return Venue.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Venue>> search(String keyword, {int page = 0}) async {
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/repositories/venue_repository_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Register the repository on FFAppState**

In `app_state.dart`, add:

```dart
  late final VenueRepository venueRepository = VenueRepository(apiClient);
```

and `import 'repositories/venue_repository.dart';` at the top.

- [ ] **Step 6: Commit**

```bash
git add lib/repositories/venue_repository.dart test/repositories/venue_repository_test.dart lib/app_state.dart
git commit -m "feat(app-user): add VenueRepository with browse/search/courts"
```

---

### Task 12: Wire home dashboard

**Files:**
- Modify: `apps/app-user/lib/pages/home_dashboard/` (page widget + model)

- [ ] **Step 1: Locate the Firestore court query**

Run: `grep -rn "queryCourtsRecord\|CourtsRecord\|StreamBuilder\|FutureBuilder" lib/pages/home_dashboard/`
Expected: a `StreamBuilder`/`FutureBuilder` driving the recommended-courts list from Firestore.

- [ ] **Step 2: Replace the data source with a FutureBuilder over the repository**

```dart
FutureBuilder<List<Venue>>(
  future: FFAppState().venueRepository.getActiveVenues(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    final venues = snapshot.data!;
    return ListView.builder(
      shrinkWrap: true,
      itemCount: venues.length,
      itemBuilder: (context, i) => CourtCardWidget(
        // map venues[i] fields onto the existing CourtCard component
        venueName: venues[i].name,
        address: venues[i].address,
        onBook: () => context.pushNamed(
          'court_details',
          queryParameters: {'venueId': venues[i].id},
        ),
      ),
    );
  },
)
```

Add `import '/models/venue.dart';`. Adjust `CourtCardWidget` parameter names to the existing component's API (found in `lib/components/court_card/`).

- [ ] **Step 3: Manual smoke test**

Run with backend up: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/badbook`
Expected: home lists venues returned by `GET /api/venues` (seed at least one approved venue first via the backend).

- [ ] **Step 4: Commit**

```bash
git add lib/pages/home_dashboard/
git commit -m "feat(app-user): wire home dashboard to VenueRepository"
```

---

### Task 13: Wire court details

**Files:**
- Modify: `apps/app-user/lib/pages/court_details/`

- [ ] **Step 1: Read the venueId route param and load detail + courts**

```dart
@override
void initState() {
  super.initState();
  _venueFuture = FFAppState().venueRepository.getVenue(widget.venueId!);
  _courtsFuture = FFAppState().venueRepository.getCourts(widget.venueId!);
}
```

Add `final String? venueId;` to the page widget constructor and read it from the route (the route is defined in `lib/flutter_flow/nav/nav.dart` — add a `venueId` query param to the `court_details` route).

- [ ] **Step 2: Render with FutureBuilder and route to the matrix**

Drive the existing detail widgets from `_venueFuture`, and make the "Book Court" footer push `time_slot_matrix` with `venueId`:

```dart
context.pushNamed('time_slot_matrix', queryParameters: {'venueId': widget.venueId!});
```

- [ ] **Step 3: Manual smoke test**

Expected: tapping a venue on home opens its detail with real name/description/price.

- [ ] **Step 4: Commit**

```bash
git add lib/pages/court_details/ lib/flutter_flow/nav/nav.dart
git commit -m "feat(app-user): wire court details to VenueRepository"
```

---

## PHASE 3 — Booking flow (FR-USER-09, FR-USER-10, FR-USER-11, FR-USER-13, FR-USER-14)

### Task 14: Booking models

**Files:**
- Create: `apps/app-user/lib/models/booking.dart`

- [ ] **Step 1: Write the models**

```dart
/// Add-on line for a booking (mirrors backend AddProductRequest).
class BookingProductLine {
  final String productId;
  final int quantity;
  BookingProductLine({required this.productId, required this.quantity});
  Map<String, dynamic> toJson() => {'productId': productId, 'quantity': quantity};
}

/// Body for `POST /api/bookings` (mirrors BookingCreateRequest).
class BookingCreateRequest {
  final String courtId;
  final String venueId;
  final String bookingDate; // ISO yyyy-MM-dd
  final String startTime;   // HH:mm:ss
  final String endTime;     // HH:mm:ss
  final String type;        // BookingType, e.g. "HOURLY"
  final String paymentMethod; // PaymentMethod, e.g. "VNPAY"
  final String? notes;
  final List<BookingProductLine> products;

  BookingCreateRequest({
    required this.courtId,
    required this.venueId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.paymentMethod,
    this.notes,
    this.products = const [],
  });

  Map<String, dynamic> toJson() => {
        'courtId': courtId,
        'venueId': venueId,
        'bookingDate': bookingDate,
        'startTime': startTime,
        'endTime': endTime,
        'type': type,
        'paymentMethod': paymentMethod,
        if (notes != null) 'notes': notes,
        'products': products.map((p) => p.toJson()).toList(),
      };
}

/// Mirrors backend `BookingResponse`.
class Booking {
  final String id;
  final String courtName;
  final String venueName;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String status;
  final double totalAmount;

  Booking({
    required this.id,
    required this.courtName,
    required this.venueName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalAmount,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'].toString(),
        courtName: json['courtName'] as String? ?? '',
        venueName: json['venueName'] as String? ?? '',
        bookingDate: json['bookingDate'] as String? ?? '',
        startTime: json['startTime'] as String? ?? '',
        endTime: json['endTime'] as String? ?? '',
        status: json['status'] as String? ?? '',
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      );
}
```

- [ ] **Step 2: Verify & commit**

Run: `flutter analyze lib/models/booking.dart`
Expected: `No issues found!`

```bash
git add lib/models/booking.dart
git commit -m "feat(app-user): add booking models"
```

---

### Task 15: Booking repository

**Files:**
- Create: `apps/app-user/lib/repositories/booking_repository.dart`
- Test: `apps/app-user/test/repositories/booking_repository_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
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
      captured = req as http.Request;
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/repositories/booking_repository_test.dart`
Expected: FAIL — `booking_repository.dart` does not exist.

- [ ] **Step 3: Write the implementation**

```dart
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/repositories/booking_repository_test.dart`
Expected: PASS (1 test).

- [ ] **Step 5: Register on FFAppState & commit**

Add to `app_state.dart`:
```dart
  late final BookingRepository bookingRepository = BookingRepository(apiClient);
```
with `import 'repositories/booking_repository.dart';`.

```bash
git add lib/repositories/booking_repository.dart test/repositories/booking_repository_test.dart lib/app_state.dart
git commit -m "feat(app-user): add BookingRepository"
```

---

### Task 16: Wire time-slot matrix (FR-USER-09)

**Files:**
- Modify: `apps/app-user/lib/pages/time_slot_matrix/`

> **Blocker check first.** The matrix needs court availability per 30-min slot. Confirm a backend endpoint exists (e.g. `GET /api/venues/{venueId}/courts` returning bookable windows, or a dedicated availability endpoint). Run:
> `grep -rn "available\|slot\|Availability" apps/backend/src/main/java/vn/chuongpl/badbook/features/court apps/backend/src/main/java/vn/chuongpl/badbook/features/booking`
> If no availability endpoint exists, **stop and report** — this requirement (FR-USER-09) needs a backend addition before the matrix can be wired. Record it against the roadmap gap list.

- [ ] **Step 1: Load courts for the venue as Y-axis rows**

```dart
_courtsFuture = FFAppState().venueRepository.getCourts(widget.venueId!);
```

- [ ] **Step 2: Build the grid and accumulate selections into FFAppState**

Render time columns (06:00–17:00, 30-min steps) × court rows. On cell tap, toggle a selection stored via the existing `FFAppState().addToSelectedSlots(...)` API, keyed by `{courtId, startTime, endTime}`.

- [ ] **Step 3: Footer routes to review order**

```dart
context.pushNamed('review_order', queryParameters: {'venueId': widget.venueId!});
```

- [ ] **Step 4: Manual smoke test & commit**

Expected: selecting cells highlights them in `#132D77` and "Confirm Selection" carries them forward.

```bash
git add lib/pages/time_slot_matrix/
git commit -m "feat(app-user): wire time-slot matrix to courts API"
```

---

### Task 17: Wire review order → create booking (FR-USER-10, FR-USER-11)

**Files:**
- Modify: `apps/app-user/lib/pages/review_order/`

- [ ] **Step 1: Build the request from FFAppState selections**

```dart
final selected = FFAppState().selectedSlots; // [{courtId,startTime,endTime}, ...]
final addons = FFAppState().cartAddons;       // [{productId,quantity}, ...]
final request = BookingCreateRequest(
  courtId: selected.first['courtId'],
  venueId: widget.venueId!,
  bookingDate: _selectedDateIso, // page's chosen date as yyyy-MM-dd
  startTime: selected.first['startTime'],
  endTime: selected.last['endTime'],
  type: 'HOURLY',
  paymentMethod: 'VNPAY',
  products: addons
      .map((a) => BookingProductLine(
            productId: a['productId'], quantity: a['quantity']))
      .toList(),
);
```

- [ ] **Step 2: "Proceed to Payment" creates the booking then routes to payment**

```dart
onPressed: () async {
  try {
    final booking = await FFAppState().bookingRepository.createBooking(request);
    if (context.mounted) {
      context.pushNamed('q_r_payment',
          queryParameters: {'bookingId': booking.id});
    }
  } on ApiException catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.message)));
  }
},
```

Add imports `'/models/booking.dart'` and `'/services/api_exception.dart'`.

- [ ] **Step 3: Manual smoke test & commit**

Expected: confirming the order creates a booking (visible via `GET /api/bookings/my`) and navigates to payment with the new `bookingId`.

```bash
git add lib/pages/review_order/
git commit -m "feat(app-user): create booking from review order screen"
```

---

## PHASE 4 — Payment (FR-USER-12)

### Task 18: Payment repository

**Files:**
- Create: `apps/app-user/lib/repositories/payment_repository.dart`
- Test: `apps/app-user/test/repositories/payment_repository_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:app_user/services/api_client.dart';
import 'package:app_user/repositories/payment_repository.dart';

void main() {
  test('createVnpayUrl returns the payment URL string', () async {
    final mock = MockClient((req) async => http.Response(
        '{"code":200,"message":"ok","data":"https://sandbox.vnpayment.vn/pay?x=1"}',
        200));
    final repo = PaymentRepository(ApiClient(
        httpClient: mock, baseUrl: 'http://test/badbook',
        tokenProvider: () async => 'T'));

    final url = await repo.createVnpayUrl('b1', 120000);
    expect(url, startsWith('https://sandbox.vnpayment.vn'));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/repositories/payment_repository_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Write the implementation**

```dart
import '../services/api_client.dart';

/// VNPay payment backed by `/api/payments/vnpay/create`.
class PaymentRepository {
  final ApiClient _api;
  PaymentRepository(this._api);

  /// Returns the VNPay redirect URL for [bookingId].
  Future<String> createVnpayUrl(String bookingId, num amount) async {
    final data = await _api.post('/api/payments/vnpay/create',
        query: {'bookingId': bookingId, 'amount': amount});
    return data as String;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/repositories/payment_repository_test.dart`
Expected: PASS (1 test).

- [ ] **Step 5: Register on FFAppState & commit**

Add to `app_state.dart`:
```dart
  late final PaymentRepository paymentRepository = PaymentRepository(apiClient);
```
with `import 'repositories/payment_repository.dart';`.

```bash
git add lib/repositories/payment_repository.dart test/repositories/payment_repository_test.dart lib/app_state.dart
git commit -m "feat(app-user): add PaymentRepository (VNPay)"
```

---

### Task 19: Wire QR / payment screen

**Files:**
- Modify: `apps/app-user/lib/pages/q_r_payment/`

- [ ] **Step 1: On screen load, request the VNPay URL**

```dart
_payUrlFuture = FFAppState().paymentRepository.createVnpayUrl(
      widget.bookingId!, _amount);
```

- [ ] **Step 2: Launch the URL with url_launcher**

`url_launcher` is already a dependency. On "Confirm Payment Completed":

```dart
import 'package:url_launcher/url_launcher.dart';
// ...
final url = await _payUrlFuture;
await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
if (context.mounted) {
  context.pushNamed('booking_confirmation',
      queryParameters: {'bookingId': widget.bookingId!});
}
```

- [ ] **Step 3: Manual smoke test & commit**

Expected: the VNPay sandbox page opens; returning to the app shows the confirmation screen.

```bash
git add lib/pages/q_r_payment/
git commit -m "feat(app-user): wire QR payment to VNPay create endpoint"
```

---

### Task 20: Wire booking confirmation (FR-USER-13)

**Files:**
- Modify: `apps/app-user/lib/pages/booking_confirmation/`

- [ ] **Step 1: Load the booking by id from my-bookings**

```dart
_bookingFuture = FFAppState()
    .bookingRepository
    .myBookings()
    .then((list) => list.firstWhere((b) => b.id == widget.bookingId));
```

- [ ] **Step 2: Render booking id, court/venue/time; "Back to Home" routes home**

Bind the existing confirmation widgets to the loaded `Booking`. Keep the check-in QR placeholder rendering `booking.id`.

- [ ] **Step 3: Manual smoke test & commit**

Expected: confirmation shows the real booking details.

```bash
git add lib/pages/booking_confirmation/
git commit -m "feat(app-user): wire booking confirmation screen"
```

---

## PHASE 5 — Reviews & profile

### Task 21: Review repository + submit review (FR-USER-15)

**Files:**
- Create: `apps/app-user/lib/repositories/review_repository.dart`
- Test: `apps/app-user/test/repositories/review_repository_test.dart`
- Modify: `apps/app-user/lib/pages/court_details/` (review submit action)

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:app_user/services/api_client.dart';
import 'package:app_user/repositories/review_repository.dart';

void main() {
  test('createReview posts rating and comment', () async {
    late http.Request captured;
    final mock = MockClient((req) async {
      captured = req as http.Request;
      return http.Response('{"code":200,"message":"ok","data":{"id":"r1"}}', 200);
    });
    final repo = ReviewRepository(ApiClient(
        httpClient: mock, baseUrl: 'http://test/badbook',
        tokenProvider: () async => 'T'));

    await repo.createReview(venueId: 'v1', rating: 5, comment: 'Great');
    expect(captured.body, contains('"rating":5'));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/repositories/review_repository_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Write the implementation**

```dart
import '../services/api_client.dart';

/// Reviews backed by `/api/reviews`.
class ReviewRepository {
  final ApiClient _api;
  ReviewRepository(this._api);

  Future<void> createReview({
    required String venueId,
    required int rating,
    required String comment,
  }) async {
    await _api.post('/api/reviews', body: {
      'venueId': venueId,
      'rating': rating,
      'comment': comment,
    });
  }
}
```

> Confirm the field names against `apps/backend/.../review/dto` — run `cat apps/backend/src/main/java/vn/chuongpl/badbook/features/review/dto/*.java` and adjust `venueId`/`rating`/`comment`/`target` keys to match the actual `ReviewCreateRequest`.

- [ ] **Step 4: Run test, register on FFAppState, wire the court-details review form, commit**

Run: `flutter test test/repositories/review_repository_test.dart` → PASS.
Add `late final ReviewRepository reviewRepository = ReviewRepository(apiClient);` to `app_state.dart`.
Wire the review submit button in `court_details` to `reviewRepository.createReview(...)`.

```bash
git add lib/repositories/review_repository.dart test/repositories/review_repository_test.dart lib/app_state.dart lib/pages/court_details/
git commit -m "feat(app-user): add ReviewRepository and wire review submission"
```

---

### Task 22: Profile screen (FR-USER-17) — backend gap

**Files:**
- Modify: `apps/app-user/lib/pages/user_profile/`

> **Blocker.** Per `docs/knowledge/roadmap.md`, `UserService` has profile read/update + change-password logic but **no `UserController`** exposes it. Before wiring this screen:
> 1. Run `grep -rn "class .*Controller" apps/backend/src/main/java/vn/chuongpl/badbook/features/user` — confirm a controller is absent.
> 2. If absent, **stop and report**: profile needs a backend `UserController` (`GET /api/users/me`, `PUT /api/users/me`, change-password). This is out of scope for the Flutter integration and must be a separate backend task.

- [ ] **Step 1: Wire the logout action (works today)**

The one profile action that needs no new endpoint:

```dart
onPressed: () async {
  await FFAppState().authRepository.logout();
  FFAppState().update(() => FFAppState().isLoggedIn = false);
  if (context.mounted) context.goNamed('authentication');
},
```

- [ ] **Step 2: Leave profile-edit fields disabled with a note, commit**

Display the current user's email/name from the stored token claims (decode locally) or leave read-only until the backend endpoint lands. Do not call nonexistent endpoints.

```bash
git add lib/pages/user_profile/
git commit -m "feat(app-user): wire profile logout; gate edits on backend gap"
```

---

## PHASE 6 — Remove Firebase

### Task 23: Delete the Firestore data layer

**Files:**
- Delete: `apps/app-user/lib/backend/schema/` (all `*_record.dart`), `lib/backend/backend.dart`, `lib/backend/firebase/`
- Modify: `apps/app-user/lib/main.dart` (remove `initFirebase`), `apps/app-user/pubspec.yaml`

- [ ] **Step 1: Confirm nothing still imports the Firebase layer**

Run: `grep -rn "backend/backend.dart\|cloud_firestore\|firebase_core\|Record\b\|initFirebase" lib/ | grep -v "lib/backend/"`
Expected: **no matches** (all pages now use repositories). If any remain, fix them before deleting.

- [ ] **Step 2: Remove the imports and init call from main.dart**

Delete `import 'backend/firebase/firebase_config.dart';` and the `await initFirebase();` line.

- [ ] **Step 3: Delete the Firebase files**

```bash
git rm -r lib/backend/schema lib/backend/firebase lib/backend/backend.dart
```

- [ ] **Step 4: Drop Firebase/Firestore deps from pubspec.yaml**

Remove these lines from `dependencies:` — `cloud_firestore`, `cloud_firestore_platform_interface`, `cloud_firestore_web`, `firebase_core`, `firebase_core_platform_interface`, `firebase_core_web`.

- [ ] **Step 5: Re-resolve and analyze**

Run: `flutter pub get && flutter analyze`
Expected: `No issues found!` (resolve any leftover references surfaced here).

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "chore(app-user): remove Firebase/Firestore data layer"
```

---

### Task 24: Full test + build gate

- [ ] **Step 1: Run the whole suite**

Run: `flutter test`
Expected: all repository/service tests PASS.

- [ ] **Step 2: Analyze the whole app**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Debug build smoke**

Run: `flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8080/badbook`
Expected: build succeeds.

- [ ] **Step 4: Commit any fixes**

```bash
git add -A
git commit -m "test(app-user): green test + analyze after backend integration"
```

---

## Self-Review Notes

**Spec coverage (FR-USER):** FR-USER-02/03 (Task 7,9), 06 (Task 11,12), 07 (Task 11), 08 (Task 13), 09 (Task 16, gated), 10/11 (Task 17), 12 (Task 18,19), 13 (Task 20), 14 (Task 15 — `cancel`/`myBookings` ready; wire into a my-bookings list when that screen exists), 15 (Task 21), 17 (Task 22, gated), logout (Task 22). **Not covered by design:** FR-USER-01 (static onboarding, no backend), 04 OAuth2, 05 forgot-password, 16 fixed-schedule UI, 18 i18n/theme — all documented as backend gaps or non-network UI in the roadmap; excluded deliberately.

**Backend gaps that block specific tasks** (each task stops and reports rather than inventing behaviour): FR-USER-09 availability endpoint (Task 16), FR-USER-17 `UserController` (Task 22). FR-USER-04/05 have no task — they need backend work first.

**Type consistency:** `ApiClient` verb signatures (`get/post/put/delete` with `query`/`body`) are used uniformly by all repositories. `FFAppState` exposes `apiClient`, `tokenStore`, and one `*Repository` per domain, each registered in the task that introduces it.
