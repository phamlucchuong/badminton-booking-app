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
