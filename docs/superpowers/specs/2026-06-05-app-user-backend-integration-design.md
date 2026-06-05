# App User — Backend Integration Design

**Date:** 2026-06-05  
**Goal:** Make the Flutter app user interact with the Spring Boot backend for all core features, with a complete booking flow end-to-end.

---

## Problem Statement

The Flutter app (`apps/app-user`) has a service layer (ApiClient, repositories) and some wired pages (auth, home, court details), but several pages show hardcoded data and the core booking flow is not functional. Tests on a physical device show no API calls being made because:

1. **Wrong base URL** — `10.0.2.2:8080` is the Android emulator loopback; physical devices need the host machine's real LAN IP.
2. **Silent network errors** — `http` package throws `SocketException` on connection failure; the pages only catch `ApiException`, so errors disappear silently.
3. **Unconnected pages** — TimeSlotMatrix, BookingConfirmation, QRPayment, and ReviewOrder do not call any backend APIs.

---

## Scope

This spec covers **Option A: Full booking path**, which delivers a complete, working booking flow end-to-end on a physical Android/iOS device.

Out of scope (future work): user profile data from backend, review submission, fixed schedule management.

---

## Architecture

### Existing layers (unchanged)

```
FFAppState (singleton)
  ├── ApiClient          → wraps http.Client, injects JWT, unwraps envelope
  ├── TokenStore         → SharedPreferences-backed JWT store
  ├── AuthRepository     → /api/auth, /api/otp
  ├── VenueRepository    → /api/venues, /api/search
  ├── BookingRepository  → /api/bookings
  ├── PaymentRepository  → /api/payments/vnpay/create
  └── ReviewRepository   → /api/reviews
```

### New state added to FFAppState

```dart
PendingBooking? pendingBooking;
```

`PendingBooking` holds everything needed to display and create a booking:

```dart
class PendingBooking {
  final String venueId;
  final String venueName;
  final String courtId;
  final String courtName;
  final String date;       // yyyy-MM-dd
  final String startTime;  // HH:mm:ss
  final String endTime;    // HH:mm:ss
  final double pricePerHour;
}
```

---

## Changes by layer

### 1. Network layer — `services/api_client.dart`

Wrap every `_http.get/post/put/delete` call in `try-catch`. Convert raw network exceptions into `ApiException`:

```dart
try {
  final res = await _http.get(...);
  return ApiResponse.unwrap(...);
} on ApiException {
  rethrow;
} catch (e) {
  throw ApiException(0, 'Không thể kết nối đến máy chủ');
}
```

This ensures all pages' `on ApiException catch (e)` blocks work for network failures too.

### 2. URL configuration — `services/api_config.dart`

No code change needed. Instruction for physical device use:

```
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8080/badbook
```

Add this to `apps/app-user/README.md` and `CLAUDE.md`.

---

### 3. Backend — new availability endpoint

**File:** `apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/VenueController.java`

Add:

```
GET /api/venues/{venueId}/availability?date=YYYY-MM-DD
```

- **Auth:** Public (no authentication required)
- **Response:** `List<CourtAvailability>`

```json
[
  {
    "courtId": "1",
    "courtName": "Court A",
    "pricePerHour": 80000,
    "bookedSlots": [
      { "startTime": "08:00:00", "endTime": "09:00:00" },
      { "startTime": "10:00:00", "endTime": "12:00:00" }
    ]
  }
]
```

**Implementation:**
- `VenueService.getAvailability(venueId, date)` queries courts for the venue and bookings on that date (status = PENDING or CONFIRMED), groups booked time ranges by court.
- New DTO: `CourtAvailability { courtId, courtName, pricePerHour, bookedSlots: List<TimeRange> }` and `TimeRange { startTime, endTime }`.
- Add to `PUBLIC_GET_ENDPOINT` in `SecurityConfig`.

### 4. Flutter — `VenueRepository`

Add method:

```dart
Future<List<CourtAvailability>> getAvailability(String venueId, String date) async {
  final data = await _api.get('/api/venues/$venueId/availability', query: {'date': date});
  return (data as List).map((e) => CourtAvailability.fromJson(e)).toList();
}
```

New model: `lib/models/court_availability.dart`

```dart
class TimeRange { final String startTime; final String endTime; }
class CourtAvailability {
  final String courtId;
  final String courtName;
  final double pricePerHour;
  final List<TimeRange> bookedSlots;
}
```

---

### 5. `TimeSlotMatrixWidget` — full rewrite

**Current state:** 100% static (10 hardcoded CourtHeaders × 10 hardcoded TimeHeaders × 100 GridSlotModels).

**New design:**

- Receives `venueId` as parameter. The constructor field and route parameter are renamed from `courtId` to `venueId` (update router entry in `lib/index.dart`).
- State: `DateTime selectedDate` (default today), `List<String> selectedSlotKeys` (key = `"$courtId|$slotIndex"`).
- On load / date change: call `venueRepository.getAvailability(venueId, dateStr)` via `FutureBuilder`.
- Time slots: hourly from `06:00` to `22:00` = 16 slots.
- Grid: horizontal scroll = courts (columns), vertical scroll = time slots (rows).
- GridSlot tap: if slot is `booked` → no-op; if `available` → toggle selected; user can select only one court at a time (selecting a slot in court B clears court A's selection).
- Date picker: tapping the calendar icon opens `showDatePicker`.
- Bottom button: `"Book N slot(s) — VND X,xxx"` → sets `FFAppState().pendingBooking` and navigates to `BookingConfirmation`.

**Model simplification:** Remove 50 static GridSlotModels and 20 static CourtHeader/TimeHeaderModels. Model only keeps `buttonModel`.

---

### 6. `CourtDetailsWidget` — fix navigation

Current bug: navigates to TimeSlotMatrix passing `'route.court_id'` (a literal string).

Fix: pass the actual `widget.courtId` (which is the venueId passed from HomeDashboard):

```dart
context.goNamed(
  TimeSlotMatrixWidget.routeName,
  queryParameters: {
    'courtId': serializeParam(widget.courtId, ParamType.String),
  }.withoutNulls,
);
```

---

### 7. `BookingConfirmationWidget` — rewrite

**Current state:** Hardcoded "Florida Court - Court 3", "$40.00", "Grand Central Badminton Hub".

**New design:**

- Read `FFAppState().pendingBooking` in `build()`.
- Show real venue name, court name, date, start time, end time, price.
- "Confirm & Pay" button (async):
  1. `await bookingRepository.createBooking(BookingCreateRequest(...))` — returns `Booking`.
  2. `await paymentRepository.createVnpayUrl(booking.id)` — returns VNPay URL.
  3. `launchUrl(Uri.parse(vnpayUrl), mode: LaunchMode.externalApplication)` via `url_launcher`.
  4. Show `SnackBar('Đang mở cổng thanh toán...')`.
  5. Clear `FFAppState().pendingBooking`.
  6. Show post-payment UI: Lottie animation + "Thanh toán đang xử lý" message + "Xem đặt sân của tôi" button that navigates to `HomeDashboard`. (VNPay server callback handles booking status update server-side.)
- `BookingCreateRequest` fields: `type = "HOURLY"`, `paymentMethod = "VNPAY"`, `products = []`.
- Error handling: catch `ApiException`, show SnackBar with message.

**Package:** Add `url_launcher: ^6.3.1` to `pubspec.yaml`.

---

### 8. Data flow summary

```
HomeDashboard
  → getActiveVenues() → show venues
  → tap venue → CourtDetails(venueId)

CourtDetails
  → getVenue(venueId) → show venue info
  → "Check Availability" → TimeSlotMatrix(venueId)

TimeSlotMatrix
  → getCourts(venueId) + getAvailability(venueId, date) → show grid
  → user selects court + slots
  → "Book" → FFAppState.pendingBooking = ... → BookingConfirmation

BookingConfirmation
  → read pendingBooking → show details
  → "Confirm & Pay" → POST /api/bookings → POST /api/payments/vnpay/create → open browser

Browser (VNPay)
  → user completes payment → VNPay callback hits backend
  → user returns to app manually
```

---

## Error handling

All async operations in widgets follow this pattern:
```dart
try {
  // API call
} on ApiException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
}
```

The ApiClient fix ensures `SocketException` also surfaces as `ApiException(0, 'Không thể kết nối đến máy chủ')`.

---

## Files to change

| File | Change type |
|------|-------------|
| `apps/app-user/lib/services/api_client.dart` | Add try-catch around all HTTP calls |
| `apps/app-user/lib/models/court_availability.dart` | New model file |
| `apps/app-user/lib/repositories/venue_repository.dart` | Add `getAvailability()` |
| `apps/app-user/lib/app_state.dart` | Add `pendingBooking` field + `PendingBooking` class |
| `apps/app-user/lib/pages/time_slot_matrix/time_slot_matrix_widget.dart` | Full rewrite |
| `apps/app-user/lib/pages/time_slot_matrix/time_slot_matrix_model.dart` | Simplify model |
| `apps/app-user/lib/pages/booking_confirmation/booking_confirmation_widget.dart` | Rewrite to use real data |
| `apps/app-user/lib/pages/court_details/court_details_widget.dart` | Fix navigation parameter |
| `apps/app-user/pubspec.yaml` | Add `url_launcher` |
| `apps/backend/.../venue/VenueController.java` | Add `GET /api/venues/{id}/availability` |
| `apps/backend/.../venue/VenueService.java` | Add `getAvailability()` |
| `apps/backend/.../venue/dto/response/CourtAvailabilityResponse.java` | New DTO |
| `apps/backend/.../configuration/SecurityConfig.java` | Add endpoint to public whitelist |
| `apps/app-user/README.md` | Document `API_BASE_URL` dart-define |

---

## Testing checklist

- [ ] Backend running, `make compose-up` + `make run`
- [ ] Flutter app with `flutter run --dart-define=API_BASE_URL=http://<host-ip>:8080/badbook`
- [ ] Register new user → OTP received → verify → login
- [ ] Home dashboard loads real venues
- [ ] Tap venue → court details loads real data
- [ ] "Check Availability" → TimeSlotMatrix loads real courts and slots
- [ ] Select slots → tap "Book" → BookingConfirmation shows real data
- [ ] Tap "Confirm & Pay" → booking created → VNPay URL opens in browser
- [ ] Backend error while offline → app shows "Không thể kết nối đến máy chủ"
