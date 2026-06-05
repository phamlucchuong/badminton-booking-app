# Backend Gaps Design — Missing Features

**Date:** 2026-06-05
**Tracks:** [`functional_requirements.md`](../../knowledge/functional_requirements.md), [`roadmap.md`](../../knowledge/roadmap.md)

This spec covers the 4 remaining backend gaps identified after the M1 audit. OAuth2 social login (FR-USER-04) is deferred. Implementation order matches priority for M2 (user app integration).

---

## Scope

| Gap | FR | Priority |
|-----|----|----------|
| Time-slot availability + venue operating hours | FR-USER-09 | 1 — M2 critical |
| UserController + refresh token | FR-USER-17, FR-ADM-06 | 2 — M2 critical |
| Password reset flow | FR-USER-05 | 3 — M2 |
| VM fee invoice read | FR-VM-09 | 4 — M4 prep |

---

## 1. Time-slot Availability + Venue Operating Hours

### 1.1 Model: `VenueOperatingHour`

New table `venue_operating_hours` (new Flyway migration `V14__venue_operating_hours.sql`):

| Column | Type | Notes |
|--------|------|-------|
| `id` | UUID PK | |
| `venue_id` | UUID FK → `venues` | |
| `day_of_week` | ENUM `MON,TUE,WED,THU,FRI,SAT,SUN` | |
| `open_time` | TIME | e.g. `07:00` |
| `close_time` | TIME | e.g. `22:00` |
| `is_closed` | BOOLEAN | venue closed on this day |

Constraint: `UNIQUE (venue_id, day_of_week)`.

JPA entity `VenueOperatingHour` in `features/venue/` (or `features/schedule/` — use `features/venue/` to keep venue config co-located). `Venue` has `@OneToMany List<VenueOperatingHour> operatingHours`.

### 1.2 VENUE_MANAGER Endpoints

Added to `VenueController`:

| Method | Path | Role | Description |
|--------|------|------|-------------|
| `GET` | `/api/venues/{venueId}/operating-hours` | Public | Return operating hours for all 7 days |
| `PUT` | `/api/venues/{venueId}/operating-hours` | `VENUE_MANAGER` | Replace all 7 days at once (upsert) |

`PUT` request body — list of 1–7 entries (upsert per day; days not included in the list are left unchanged):
```json
[
  { "dayOfWeek": "MON", "openTime": "07:00", "closeTime": "22:00", "closed": false },
  { "dayOfWeek": "SUN", "openTime": "08:00", "closeTime": "20:00", "closed": false }
]
```

Authorization: VENUE_MANAGER must own the venue (check `venue.manager.id == jwt.subject`), throw `ErrorCode.UNAUTHORIZED` otherwise.

### 1.3 Availability Endpoint

`GET /api/venues/{venueId}/availability?date=YYYY-MM-DD` — **public**, no auth required.

**Logic:**
1. Parse `date` → derive `dayOfWeek`.
2. Lookup `VenueOperatingHour` for that `dayOfWeek`. If `is_closed = true` or no record found → return empty `courts` list.
3. Load all courts of venue with status `AVAILABLE`.
4. For each court, generate 30-min slots from `openTime` to `closeTime`.
5. Query `BookingRepository` for all bookings of that court on that date with status `PENDING` or `CONFIRMED`.
6. For each slot, mark `available = false` if any booking overlaps `[slotStart, slotEnd)`.

**Response:**
```json
{
  "date": "2026-06-10",
  "openTime": "07:00",
  "closeTime": "22:00",
  "courts": [
    {
      "courtId": "...",
      "courtName": "Sân 1",
      "slots": [
        { "startTime": "07:00", "endTime": "07:30", "available": true },
        { "startTime": "07:30", "endTime": "08:00", "available": false }
      ]
    }
  ]
}
```

**Placement:** New method in `VenueController`, delegated to a new `VenueAvailabilityService` (or inline in `VenueService` if logic is short). Calls `BookingRepository` — add a query method `findActiveBookingsForCourtOnDate(courtId, date)`.

**Test:** Unit test — mock operating hours + existing bookings, assert slot availability is correct for overlap edge cases (start-on-boundary, end-on-boundary, full overlap).

---

## 2. UserController + Refresh Token

### 2.1 UserController

New file: `features/user/UserController.java`

**User-facing endpoints** (role: `USER`):

| Method | Path | Description | Delegates to |
|--------|------|-------------|-------------|
| `GET` | `/api/users/me` | Get own profile | `userService.getUserResponseById(jwt.subject)` |
| `PUT` | `/api/users/me` | Update name / phone | `userService.updateUser(id, request)` |
| `PUT` | `/api/users/me/password` | Change password (logged-in) | `userService.changePassword(id, request)` |

`changePassword(id, ChangePasswordRequest)` is a **new method** in `UserService`:
- `ChangePasswordRequest`: `{ currentPassword, newPassword }`.
- Verify `currentPassword` against stored hash using `BCryptPasswordEncoder.matches()`.
- Throw `ErrorCode.INVALID_PASSWORD` if wrong.
- Encode and save `newPassword`.

**Admin endpoints** — added to existing `AdminController` (keeps all `/api/admin/*` co-located):

| Method | Path | Description | Delegates to |
|--------|------|-------------|-------------|
| `GET` | `/api/admin/users?page=` | List all users (paginated) | `userService.getAllUser(page)` |
| `POST` | `/api/admin/users` | Create user | `userService.createUser(request)` |
| `DELETE` | `/api/admin/users/{id}` | Delete user | `userService.deleteUser(id)` |

**Test:** Unit test `UserService.changePassword()` — correct password succeeds, wrong password throws, new password is encoded.

### 2.2 Refresh Token

**Current state:** access token only, 1-hour TTL, HMAC-SHA512 symmetric key.

**Changes:**

| | Access Token | Refresh Token |
|--|--|--|
| TTL | **30 minutes** (reduced from 1h) | **7 days** |
| Custom claim | `tokenType: "access"` | `tokenType: "refresh"` |
| Blacklist on logout | Yes (Redis, existing) | Yes (Redis, existing) |

**`AuthResponse` DTO** — add field `refreshToken: String`.

**`AuthService` changes:**
- `generateToken()` receives a `tokenType` parameter.
- On login: generate both tokens and return both in `AuthResponse`.
- New method `generateAccessFromRefresh(refreshToken)`: decode → verify `tokenType == "refresh"` → verify not blacklisted → issue new access token.

**New endpoint:** `POST /api/auth/refresh` (public)
```json
Request:  { "refreshToken": "..." }
Response: { "token": "new-access-token", "authenticated": true }
```
Errors: `ErrorCode.INVALID_TOKEN` if malformed/expired/wrong type/blacklisted.

**Logout change:** `POST /api/auth/logout` currently blacklists only the access token. Client must send both tokens; logout blacklists both. Request body: `{ "refreshToken": "..." }` (access token still via `@AuthenticationPrincipal Jwt`).

---

## 3. Password Reset Flow

Reuses existing OTP infrastructure (`POST /api/otp/send`, `GET /api/otp/verify`).

**Client-side flow (3 steps):**
1. `POST /api/otp/send?email=...` — send OTP email (existing endpoint).
2. `GET /api/otp/verify?email=...&otp=...` — verify OTP; returns `true/false` (existing endpoint).
3. `POST /api/auth/reset-password` — submit new password.

**New endpoint:** `POST /api/auth/reset-password` (public, no auth)

```json
Request:  { "email": "user@example.com", "otp": "123456", "newPassword": "..." }
Response: ApiResponse<Void>
```

**Logic in `AuthController`:**
1. Call `OtpService.verifyOtp(email, otp)` → throw `ErrorCode.INVALID_OTP` if false.
2. Call `UserService.resetPassword(email, newPassword)` — **new method**: lookup user by email, encode and save new password. OTP is consumed/invalidated by `OtpService.verifyOtp()` (already invalidates on verify).

**Distinction from change-password:**
- `PUT /api/users/me/password` — authenticated, requires current password.
- `POST /api/auth/reset-password` — unauthenticated, verified by OTP.

**Test:** Unit test `AuthService` / `UserService.resetPassword()` — wrong OTP throws, expired OTP throws, success encodes password.

---

## 4. VM Fee Invoice Read (FinanceController)

**New file:** `features/finance/FinanceController.java`

`FinanceService.getVenueInvoices(venueId)` already exists — just needs HTTP exposure.

| Method | Path | Role | Description |
|--------|------|------|-------------|
| `GET` | `/api/finance/my-invoices` | `VENUE_MANAGER` | List own venue's platform-fee invoices |

**Logic:**
1. Get user id from `jwt.subject`.
2. Lookup venue where `manager.id == userId` → throw `ErrorCode.VENUE_NOT_FOUND` if none.
3. Call `financeService.getVenueInvoices(venue.id)`.

**Test:** No new service logic → no new unit test needed. Existing `FinanceService` is already tested.

---

## New Flyway Migration

`V14__venue_operating_hours.sql`:
```sql
CREATE TYPE day_of_week AS ENUM ('MON','TUE','WED','THU','FRI','SAT','SUN');

CREATE TABLE venue_operating_hours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venue_id UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
    day_of_week day_of_week NOT NULL,
    open_time TIME NOT NULL,
    close_time TIME NOT NULL,
    is_closed BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE (venue_id, day_of_week)
);
```

---

## Error Codes to Add

| Code | Domain | Message |
|------|--------|---------|
| `INVALID_PASSWORD` | user | "Mật khẩu hiện tại không đúng" |
| `INVALID_TOKEN` | auth | "Token không hợp lệ hoặc đã hết hạn" |

(Add to `ErrorCode` enum, grouped by domain, with next available numeric codes.)

---

## Summary of New Files / Changes

| File | Change |
|------|--------|
| `V14__venue_operating_hours.sql` | New migration |
| `VenueOperatingHour.java` | New JPA entity |
| `VenueOperatingHourRepository.java` | New repository |
| `VenueOperatingHourRequest.java` | New DTO |
| `VenueOperatingHourResponse.java` | New DTO |
| `VenueController.java` | Add operating-hours + availability endpoints |
| `VenueService.java` | Add operating-hours logic + availability logic |
| `BookingRepository.java` | Add `findActiveBookingsForCourtOnDate()` query |
| `UserController.java` | **New file** |
| `UserService.java` | Add `changePassword()`, `resetPassword()` |
| `ChangePasswordRequest.java` | New DTO |
| `AdminController.java` | Add user management endpoints |
| `AuthController.java` | Add `/refresh`, update `/logout`, add `/reset-password` |
| `AuthService.java` | Add refresh token generation + validation |
| `AuthResponse.java` | Add `refreshToken` field |
| `ResetPasswordRequest.java` | New DTO |
| `RefreshTokenRequest.java` | New DTO |
| `FinanceController.java` | **New file** |
| `ErrorCode.java` | Add `INVALID_PASSWORD`, `INVALID_TOKEN` |
