/// Resolves the backend base URL.
///
/// Override per run with:
///   flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8080/badbook
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080/badbook
///
/// The default targets localhost on the device runtime. For Android devices
/// and emulators, pair this with `adb reverse tcp:8080 tcp:8080` so the app
/// can reach the backend running on the development machine.
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080/badbook',
  );
}
