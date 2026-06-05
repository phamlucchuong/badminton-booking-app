/// Resolves the backend base URL.
///
/// Override per run with:
///   flutter run --dart-define=API_BASE_URL=http://localhost:8080/badbook
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080/badbook
///
/// When no override is supplied, default to the Android emulator host loopback
/// at `/badbook`.
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/badbook',
  );
}
