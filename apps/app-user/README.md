# App User

Flutter user app using the transferred shuttle-booking design system and screen flow.

## Getting Started

FlutterFlow projects are built to run on the Flutter _stable_ release.

## Backend connectivity

The app expects the Spring backend at `http://127.0.0.1:8080/badbook` by default.

Start local services and the backend from the repository root:

```bash
make compose-up
make run-backend
```

For Android development, forward the host port into the device before running
the app:

```bash
make adb-fix
make run-app-user
```

If you run Flutter manually, the equivalent is:

```bash
adb reverse tcp:8080 tcp:8080
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8080/badbook
```

If `adb reverse` is not available, use your machine LAN IP instead:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8080/badbook
```
