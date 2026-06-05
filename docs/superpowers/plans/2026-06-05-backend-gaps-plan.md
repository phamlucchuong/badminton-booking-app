# Backend Gaps Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close 4 remaining backend gaps — venue operating hours + time-slot availability, UserController + refresh token, password reset, and VM fee invoice read.

**Architecture:** Each gap is an independent vertical slice following the existing feature-sliced pattern (`features/<name>/`). Services use `@RequiredArgsConstructor` + `@FieldDefaults(makeFinal = true)`. Controllers return `ApiResponse.<T>builder().data(...).build()`. Errors throw `new AppException(ErrorCode.X)`.

**Tech Stack:** Spring Boot 3.5, Java 21, Nimbus JOSE (JWT HS512), Spring Security OAuth2 resource server, Redis (token blacklist), PostgreSQL + Flyway, Lombok, MapStruct, JUnit 5 + Mockito + AssertJ.

---

## File Map

### New files
| File | Purpose |
|------|---------|
| `db/migration/V15__create_venue_operating_hours.sql` | Schema for per-day operating hours |
| `features/venue/VenueOperatingHour.java` | JPA entity |
| `features/venue/VenueOperatingHourRepository.java` | JPA repository |
| `features/venue/dto/request/VenueOperatingHourRequest.java` | PUT body item |
| `features/venue/dto/response/VenueOperatingHourResponse.java` | Operating hours response item |
| `features/venue/dto/response/VenueAvailabilityResponse.java` | Top-level availability response |
| `features/venue/dto/response/CourtSlotResponse.java` | Per-court slot list |
| `features/venue/dto/response/SlotResponse.java` | Single 30-min slot |
| `features/user/UserController.java` | Profile + change-password endpoints |
| `features/user/dto/request/UserProfileUpdateRequest.java` | PUT /api/users/me body |
| `features/user/dto/request/ChangePasswordRequest.java` | PUT /api/users/me/password body |
| `features/auth/dto/request/RefreshTokenRequest.java` | POST /api/auth/refresh body |
| `features/auth/dto/request/ResetPasswordRequest.java` | POST /api/auth/reset-password body |
| `features/auth/dto/request/LogoutRequest.java` | POST /api/auth/logout body (adds refreshToken) |
| `features/finance/FinanceController.java` | GET /api/finance/my-invoices |
| `test/.../features/user/UserServiceTest.java` | Tests for changePassword + resetPassword |

### Modified files
| File | Change |
|------|--------|
| `common/enums/ErrorCode.java` | Add INVALID_PASSWORD (2005), INVALID_TOKEN (2006) |
| `features/venue/VenueService.java` | Add 3 new deps + operating hours + availability methods |
| `features/booking/BookingRepository.java` | Add findActiveBookingsForCourtOnDate query |
| `features/venue/VenueController.java` | Add 3 new endpoints |
| `features/user/UserService.java` | Add changePassword, resetPassword, updateUserProfile |
| `features/admin/AdminController.java` | Add user management endpoints |
| `features/auth/dto/response/AuthResponse.java` | Add refreshToken field |
| `features/auth/AuthService.java` | Refactor generatedToken + add refreshAccessToken + update logout |
| `features/auth/AuthController.java` | Add /refresh, /reset-password; update /logout |
| `configuration/SecurityConfig.java` | Whitelist new public endpoints |

---

## Task 1: Add ErrorCode entries

**Files:**
- Modify: `apps/backend/src/main/java/vn/chuongpl/badbook/common/enums/ErrorCode.java`

- [ ] **Step 1: Add two new error codes to the Auth/User group**

In `ErrorCode.java`, after `OTP_INVALID(2004, ...)` add:

```java
    INVALID_PASSWORD(2005, "Mật khẩu hiện tại không đúng"),
    INVALID_TOKEN(2006, "Token không hợp lệ hoặc đã hết hạn"),
```

The file snippet to edit (after `OTP_INVALID` line):
```java
    // Auth / User
    ACCOUNT_NOT_FOUND(2001, "Tài khoản không tồn tại"),
    AUTHENTICATION_FAILED(2002, "Mật khẩu không đúng"),
    EMAIL_EXISTED(2003, "Email đã tồn tại"),
    OTP_INVALID(2004, "Mã OTP không hợp lệ hoặc đã hết hạn"),
    INVALID_PASSWORD(2005, "Mật khẩu hiện tại không đúng"),
    INVALID_TOKEN(2006, "Token không hợp lệ hoặc đã hết hạn"),
```

- [ ] **Step 2: Build to verify compilation**

```bash
./apps/backend/mvnw -f apps/backend/pom.xml compile -q
```
Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add apps/backend/src/main/java/vn/chuongpl/badbook/common/enums/ErrorCode.java
git commit -m "feat(backend): add INVALID_PASSWORD and INVALID_TOKEN error codes"
```

---

## Task 2: Flyway migration V15 + VenueOperatingHour entity & repository

**Files:**
- Create: `apps/backend/src/main/resources/db/migration/V15__create_venue_operating_hours.sql`
- Create: `apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/VenueOperatingHour.java`
- Create: `apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/VenueOperatingHourRepository.java`

- [ ] **Step 1: Write the migration SQL**

Create `apps/backend/src/main/resources/db/migration/V15__create_venue_operating_hours.sql`:

```sql
CREATE TABLE venue_operating_hours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venue_id UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
    day_of_week VARCHAR(10) NOT NULL,
    open_time TIME,
    close_time TIME,
    is_closed BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE (venue_id, day_of_week)
);
```

Note: `open_time` and `close_time` are nullable because `is_closed = true` rows don't need them.

- [ ] **Step 2: Apply the migration**

```bash
make migrate
```
Expected: Successfully applied 1 migration (V15).

- [ ] **Step 3: Create VenueOperatingHour entity**

Create `apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/VenueOperatingHour.java`:

```java
package vn.chuongpl.badbook.features.venue;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.DayOfWeek;
import java.time.LocalTime;
import java.util.UUID;

@Entity
@Table(name = "venue_operating_hours")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class VenueOperatingHour {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "venue_id", nullable = false)
    Venue venue;

    @Enumerated(EnumType.STRING)
    @Column(name = "day_of_week", nullable = false, length = 10)
    DayOfWeek dayOfWeek;

    @Column(name = "open_time")
    LocalTime openTime;

    @Column(name = "close_time")
    LocalTime closeTime;

    @Column(name = "is_closed", nullable = false)
    @Builder.Default
    boolean closed = false;
}
```

- [ ] **Step 4: Create VenueOperatingHourRepository**

Create `apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/VenueOperatingHourRepository.java`:

```java
package vn.chuongpl.badbook.features.venue;

import org.springframework.data.jpa.repository.JpaRepository;

import java.time.DayOfWeek;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface VenueOperatingHourRepository extends JpaRepository<VenueOperatingHour, UUID> {
    List<VenueOperatingHour> findByVenue(Venue venue);
    Optional<VenueOperatingHour> findByVenueAndDayOfWeek(Venue venue, DayOfWeek dayOfWeek);
}
```

- [ ] **Step 5: Build to verify JPA schema validation passes**

```bash
make compose-up   # ensure DB is running
make run &        # start app briefly; JPA validate mode will fail if schema mismatch
# watch for "HibernateException: Missing table" or similar — should not appear
# Ctrl+C after "Started" log
```

Expected: Application starts without schema validation errors.

- [ ] **Step 6: Commit**

```bash
git add apps/backend/src/main/resources/db/migration/V15__create_venue_operating_hours.sql \
        apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/VenueOperatingHour.java \
        apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/VenueOperatingHourRepository.java
git commit -m "feat(backend): add venue_operating_hours table, entity and repository"
```

---

## Task 3: Operating hours DTOs + VenueService methods + tests

**Files:**
- Create: `apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/dto/request/VenueOperatingHourRequest.java`
- Create: `apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/dto/response/VenueOperatingHourResponse.java`
- Modify: `apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/VenueService.java`
- Modify: `apps/backend/src/test/java/vn/chuongpl/badbook/features/venue/VenueServiceTest.java`

- [ ] **Step 1: Create VenueOperatingHourRequest DTO**

Create `apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/dto/request/VenueOperatingHourRequest.java`:

```java
package vn.chuongpl.badbook.features.venue.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.DayOfWeek;
import java.time.LocalTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VenueOperatingHourRequest {
    DayOfWeek dayOfWeek;
    LocalTime openTime;
    LocalTime closeTime;
    boolean closed;
}
```

- [ ] **Step 2: Create VenueOperatingHourResponse DTO**

Create `apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/dto/response/VenueOperatingHourResponse.java`:

```java
package vn.chuongpl.badbook.features.venue.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.DayOfWeek;
import java.time.LocalTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VenueOperatingHourResponse {
    DayOfWeek dayOfWeek;
    LocalTime openTime;
    LocalTime closeTime;
    boolean closed;
}
```

- [ ] **Step 3: Write the failing tests for operating hours methods**

Add to `apps/backend/src/test/java/vn/chuongpl/badbook/features/venue/VenueServiceTest.java` — add these test methods and any missing imports/mocks:

```java
// Add to existing @Mock declarations:
@Mock VenueOperatingHourRepository operatingHourRepository;
@Mock CourtRepository courtRepository;
@Mock BookingRepository bookingRepository;

// New test methods:

@Test
void getOperatingHours_returnsListForVenue() {
    UUID venueId = UUID.randomUUID();
    Venue venue = Venue.builder().id(venueId).build();
    VenueOperatingHour mon = VenueOperatingHour.builder()
        .dayOfWeek(DayOfWeek.MONDAY)
        .openTime(LocalTime.of(7, 0))
        .closeTime(LocalTime.of(22, 0))
        .closed(false)
        .build();

    when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
    when(operatingHourRepository.findByVenue(venue)).thenReturn(List.of(mon));

    List<VenueOperatingHourResponse> result = venueService.getOperatingHours(venueId.toString());

    assertThat(result).hasSize(1);
    assertThat(result.get(0).getDayOfWeek()).isEqualTo(DayOfWeek.MONDAY);
    assertThat(result.get(0).getOpenTime()).isEqualTo(LocalTime.of(7, 0));
}

@Test
void updateOperatingHours_upsertsSingleDay() {
    UUID venueId = UUID.randomUUID();
    UUID ownerId = UUID.randomUUID();
    User owner = User.builder().id(ownerId).build();
    Venue venue = Venue.builder().id(venueId).owner(owner).build();

    VenueOperatingHourRequest req = VenueOperatingHourRequest.builder()
        .dayOfWeek(DayOfWeek.TUESDAY)
        .openTime(LocalTime.of(8, 0))
        .closeTime(LocalTime.of(21, 0))
        .closed(false)
        .build();

    when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
    when(operatingHourRepository.findByVenueAndDayOfWeek(venue, DayOfWeek.TUESDAY))
        .thenReturn(Optional.empty());
    when(operatingHourRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
    when(operatingHourRepository.findByVenue(venue)).thenReturn(List.of(
        VenueOperatingHour.builder().dayOfWeek(DayOfWeek.TUESDAY)
            .openTime(LocalTime.of(8, 0)).closeTime(LocalTime.of(21, 0)).closed(false).build()
    ));

    List<VenueOperatingHourResponse> result =
        venueService.updateOperatingHours(venueId.toString(), ownerId.toString(), List.of(req));

    verify(operatingHourRepository).save(any(VenueOperatingHour.class));
    assertThat(result).hasSize(1);
}

@Test
void updateOperatingHours_throwsUnauthorized_whenNotOwner() {
    UUID venueId = UUID.randomUUID();
    User owner = User.builder().id(UUID.randomUUID()).build();
    Venue venue = Venue.builder().id(venueId).owner(owner).build();

    when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));

    assertThatThrownBy(() ->
        venueService.updateOperatingHours(venueId.toString(), UUID.randomUUID().toString(), List.of()))
        .isInstanceOf(AppException.class)
        .extracting("errorCode").isEqualTo(ErrorCode.VENUE_NOT_OWNED_BY_USER);
}
```

- [ ] **Step 4: Run tests to verify they fail**

```bash
./apps/backend/mvnw -f apps/backend/pom.xml test -Dtest=VenueServiceTest -pl apps/backend 2>&1 | tail -20
```
Expected: FAIL — method `getOperatingHours` not found on VenueService.

- [ ] **Step 5: Add operating hours fields and methods to VenueService**

In `VenueService.java`, add the new dependencies after `VenueMapper venueMapper;`:

```java
    VenueOperatingHourRepository operatingHourRepository;
    CourtRepository courtRepository;
    BookingRepository bookingRepository;
```

Also add the required imports:
```java
import vn.chuongpl.badbook.features.venue.dto.request.VenueOperatingHourRequest;
import vn.chuongpl.badbook.features.venue.dto.response.VenueOperatingHourResponse;
import java.time.DayOfWeek;
import java.util.stream.Collectors;
```

Add the following public methods to VenueService (before the `private` helpers):

```java
    public List<VenueOperatingHourResponse> getOperatingHours(String venueId) {
        Venue venue = findVenue(venueId);
        return operatingHourRepository.findByVenue(venue).stream()
                .map(h -> VenueOperatingHourResponse.builder()
                        .dayOfWeek(h.getDayOfWeek())
                        .openTime(h.getOpenTime())
                        .closeTime(h.getCloseTime())
                        .closed(h.isClosed())
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional
    public List<VenueOperatingHourResponse> updateOperatingHours(String venueId, String ownerId,
                                                                   List<VenueOperatingHourRequest> requests) {
        Venue venue = findVenue(venueId);
        if (!venue.getOwner().getId().toString().equals(ownerId))
            throw new AppException(ErrorCode.VENUE_NOT_OWNED_BY_USER);
        for (VenueOperatingHourRequest req : requests) {
            VenueOperatingHour hour = operatingHourRepository
                    .findByVenueAndDayOfWeek(venue, req.getDayOfWeek())
                    .orElse(VenueOperatingHour.builder().venue(venue).dayOfWeek(req.getDayOfWeek()).build());
            hour.setOpenTime(req.getOpenTime());
            hour.setCloseTime(req.getCloseTime());
            hour.setClosed(req.isClosed());
            operatingHourRepository.save(hour);
        }
        return getOperatingHours(venueId);
    }
```

- [ ] **Step 6: Run tests to verify they pass**

```bash
./apps/backend/mvnw -f apps/backend/pom.xml test -Dtest=VenueServiceTest -pl apps/backend 2>&1 | tail -20
```
Expected: Tests pass for `getOperatingHours_*` and `updateOperatingHours_*`.

- [ ] **Step 7: Commit**

```bash
git add apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/dto/ \
        apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/VenueService.java \
        apps/backend/src/test/java/vn/chuongpl/badbook/features/venue/VenueServiceTest.java
git commit -m "feat(backend): add venue operating hours DTOs, service methods and tests"
```

---

## Task 4: Availability response DTOs + BookingRepository query + VenueService availability + tests

**Files:**
- Create: `apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/dto/response/VenueAvailabilityResponse.java`
- Create: `apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/dto/response/CourtSlotResponse.java`
- Create: `apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/dto/response/SlotResponse.java`
- Modify: `apps/backend/src/main/java/vn/chuongpl/badbook/features/booking/BookingRepository.java`
- Modify: `apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/VenueService.java`
- Modify: `apps/backend/src/test/java/vn/chuongpl/badbook/features/venue/VenueServiceTest.java`

- [ ] **Step 1: Create SlotResponse DTO**

Create `apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/dto/response/SlotResponse.java`:

```java
package vn.chuongpl.badbook.features.venue.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SlotResponse {
    LocalTime startTime;
    LocalTime endTime;
    boolean available;
}
```

- [ ] **Step 2: Create CourtSlotResponse DTO**

Create `apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/dto/response/CourtSlotResponse.java`:

```java
package vn.chuongpl.badbook.features.venue.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CourtSlotResponse {
    String courtId;
    String courtName;
    List<SlotResponse> slots;
}
```

- [ ] **Step 3: Create VenueAvailabilityResponse DTO**

Create `apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/dto/response/VenueAvailabilityResponse.java`:

```java
package vn.chuongpl.badbook.features.venue.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VenueAvailabilityResponse {
    LocalDate date;
    LocalTime openTime;
    LocalTime closeTime;
    List<CourtSlotResponse> courts;
}
```

- [ ] **Step 4: Add findActiveBookingsForCourtOnDate to BookingRepository**

In `apps/backend/src/main/java/vn/chuongpl/badbook/features/booking/BookingRepository.java`, add after the existing `findByVenueAndStatusAndBookingDate` method:

```java
    @Query("""
        SELECT b FROM Booking b
        WHERE b.court = :court
        AND b.bookingDate = :date
        AND b.status IN ('PENDING', 'CONFIRMED')
    """)
    List<Booking> findActiveBookingsForCourtOnDate(@Param("court") Court court,
                                                    @Param("date") LocalDate date);
```

- [ ] **Step 5: Write failing availability tests**

Add to `VenueServiceTest.java`:

```java
@Test
void getAvailability_marksSlotOccupied_whenBookingOverlaps() {
    UUID venueId = UUID.randomUUID();
    LocalDate date = LocalDate.of(2026, 6, 10); // WEDNESDAY
    Venue venue = Venue.builder().id(venueId).build();
    UUID courtId = UUID.randomUUID();
    Court court = Court.builder().id(courtId).name("Sân 1").status(CourtStatus.ACTIVE).build();

    VenueOperatingHour hours = VenueOperatingHour.builder()
            .dayOfWeek(DayOfWeek.WEDNESDAY)
            .openTime(LocalTime.of(7, 0))
            .closeTime(LocalTime.of(9, 0))
            .closed(false)
            .build();

    Booking booking = Booking.builder()
            .court(court)
            .startTime(LocalTime.of(7, 0))
            .endTime(LocalTime.of(8, 0))
            .build();

    when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
    when(operatingHourRepository.findByVenueAndDayOfWeek(venue, DayOfWeek.WEDNESDAY))
            .thenReturn(Optional.of(hours));
    when(courtRepository.findByVenueAndStatus(venue, CourtStatus.ACTIVE))
            .thenReturn(List.of(court));
    when(bookingRepository.findActiveBookingsForCourtOnDate(court, date))
            .thenReturn(List.of(booking));

    VenueAvailabilityResponse response = venueService.getAvailability(venueId.toString(), date);

    assertThat(response.getCourts()).hasSize(1);
    List<SlotResponse> slots = response.getCourts().get(0).getSlots();
    assertThat(slots).hasSize(4); // 07:00-07:30, 07:30-08:00, 08:00-08:30, 08:30-09:00
    assertThat(slots.get(0).isAvailable()).isFalse(); // 07:00-07:30 occupied
    assertThat(slots.get(1).isAvailable()).isFalse(); // 07:30-08:00 occupied
    assertThat(slots.get(2).isAvailable()).isTrue();  // 08:00-08:30 free
    assertThat(slots.get(3).isAvailable()).isTrue();  // 08:30-09:00 free
}

@Test
void getAvailability_returnsEmptyCourts_whenVenueClosedOnDay() {
    UUID venueId = UUID.randomUUID();
    LocalDate date = LocalDate.of(2026, 6, 14); // SUNDAY
    Venue venue = Venue.builder().id(venueId).build();

    VenueOperatingHour hours = VenueOperatingHour.builder()
            .dayOfWeek(DayOfWeek.SUNDAY)
            .closed(true)
            .build();

    when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
    when(operatingHourRepository.findByVenueAndDayOfWeek(venue, DayOfWeek.SUNDAY))
            .thenReturn(Optional.of(hours));

    VenueAvailabilityResponse response = venueService.getAvailability(venueId.toString(), date);

    assertThat(response.getCourts()).isEmpty();
}

@Test
void getAvailability_returnsEmptyCourts_whenNoOperatingHoursConfigured() {
    UUID venueId = UUID.randomUUID();
    LocalDate date = LocalDate.of(2026, 6, 10); // WEDNESDAY
    Venue venue = Venue.builder().id(venueId).build();

    when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
    when(operatingHourRepository.findByVenueAndDayOfWeek(venue, DayOfWeek.WEDNESDAY))
            .thenReturn(Optional.empty());

    VenueAvailabilityResponse response = venueService.getAvailability(venueId.toString(), date);

    assertThat(response.getCourts()).isEmpty();
}
```

Add missing imports at the top of the test file:
```java
import vn.chuongpl.badbook.features.venue.dto.response.*;
import vn.chuongpl.badbook.common.enums.CourtStatus;
import vn.chuongpl.badbook.features.court.Court;
import vn.chuongpl.badbook.features.booking.Booking;
import java.time.DayOfWeek;
```

- [ ] **Step 6: Run tests to verify they fail**

```bash
./apps/backend/mvnw -f apps/backend/pom.xml test -Dtest=VenueServiceTest -pl apps/backend 2>&1 | tail -20
```
Expected: FAIL — method `getAvailability` not found on VenueService.

- [ ] **Step 7: Implement getAvailability in VenueService**

Add the following methods to `VenueService.java` (before the private helpers). Also add required imports: `java.time.LocalDate`, `java.util.ArrayList`, `vn.chuongpl.badbook.features.venue.dto.response.*`, `vn.chuongpl.badbook.common.enums.CourtStatus`, `vn.chuongpl.badbook.features.court.Court`, `vn.chuongpl.badbook.features.booking.Booking`.

```java
    public VenueAvailabilityResponse getAvailability(String venueId, LocalDate date) {
        Venue venue = findVenue(venueId);
        DayOfWeek dayOfWeek = date.getDayOfWeek();

        Optional<VenueOperatingHour> hoursOpt =
                operatingHourRepository.findByVenueAndDayOfWeek(venue, dayOfWeek);
        if (hoursOpt.isEmpty() || hoursOpt.get().isClosed()) {
            return VenueAvailabilityResponse.builder()
                    .date(date)
                    .courts(List.of())
                    .build();
        }

        VenueOperatingHour hours = hoursOpt.get();
        List<Court> courts = courtRepository.findByVenueAndStatus(venue, CourtStatus.ACTIVE);

        List<CourtSlotResponse> courtSlots = courts.stream().map(court -> {
            List<Booking> bookings = bookingRepository.findActiveBookingsForCourtOnDate(court, date);
            return CourtSlotResponse.builder()
                    .courtId(court.getId().toString())
                    .courtName(court.getName())
                    .slots(buildSlots(hours.getOpenTime(), hours.getCloseTime(), bookings))
                    .build();
        }).collect(Collectors.toList());

        return VenueAvailabilityResponse.builder()
                .date(date)
                .openTime(hours.getOpenTime())
                .closeTime(hours.getCloseTime())
                .courts(courtSlots)
                .build();
    }

    private List<SlotResponse> buildSlots(LocalTime open, LocalTime close, List<Booking> bookings) {
        List<SlotResponse> slots = new ArrayList<>();
        LocalTime current = open;
        while (current.isBefore(close)) {
            LocalTime next = current.plusMinutes(30);
            final LocalTime slotStart = current;
            final LocalTime slotEnd = next;
            boolean occupied = bookings.stream().anyMatch(b ->
                    b.getStartTime().isBefore(slotEnd) && b.getEndTime().isAfter(slotStart));
            slots.add(SlotResponse.builder()
                    .startTime(slotStart)
                    .endTime(slotEnd)
                    .available(!occupied)
                    .build());
            current = next;
        }
        return slots;
    }
```

- [ ] **Step 8: Run tests to verify they pass**

```bash
./apps/backend/mvnw -f apps/backend/pom.xml test -Dtest=VenueServiceTest -pl apps/backend 2>&1 | tail -20
```
Expected: All VenueServiceTest tests PASS.

- [ ] **Step 9: Commit**

```bash
git add apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/dto/response/ \
        apps/backend/src/main/java/vn/chuongpl/badbook/features/booking/BookingRepository.java \
        apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/VenueService.java \
        apps/backend/src/test/java/vn/chuongpl/badbook/features/venue/VenueServiceTest.java
git commit -m "feat(backend): add time-slot availability logic and tests"
```

---

## Task 5: VenueController operating hours + availability endpoints + SecurityConfig

**Files:**
- Modify: `apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/VenueController.java`
- Modify: `apps/backend/src/main/java/vn/chuongpl/badbook/configuration/SecurityConfig.java`

- [ ] **Step 1: Add three endpoints to VenueController**

In `VenueController.java`, add these methods after the existing `getPending` method, and add the import:
```java
import vn.chuongpl.badbook.features.venue.dto.request.VenueOperatingHourRequest;
import vn.chuongpl.badbook.features.venue.dto.response.VenueOperatingHourResponse;
import vn.chuongpl.badbook.features.venue.dto.response.VenueAvailabilityResponse;
import java.time.LocalDate;
import java.util.List;
```

```java
    @GetMapping("/{venueId}/operating-hours")
    public ApiResponse<List<VenueOperatingHourResponse>> getOperatingHours(@PathVariable String venueId) {
        return ApiResponse.<List<VenueOperatingHourResponse>>builder()
                .data(venueService.getOperatingHours(venueId)).build();
    }

    @PutMapping("/{venueId}/operating-hours")
    @PreAuthorize("hasRole('VENUE_MANAGER')")
    public ApiResponse<List<VenueOperatingHourResponse>> updateOperatingHours(
            @PathVariable String venueId,
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody List<VenueOperatingHourRequest> requests) {
        return ApiResponse.<List<VenueOperatingHourResponse>>builder()
                .data(venueService.updateOperatingHours(venueId, jwt.getSubject(), requests)).build();
    }

    @GetMapping("/{venueId}/availability")
    public ApiResponse<VenueAvailabilityResponse> getAvailability(
            @PathVariable String venueId,
            @RequestParam String date) {
        return ApiResponse.<VenueAvailabilityResponse>builder()
                .data(venueService.getAvailability(venueId, LocalDate.parse(date))).build();
    }
```

- [ ] **Step 2: Whitelist the availability and operating-hours GET endpoints in SecurityConfig**

In `SecurityConfig.java`, add two entries to `PUBLIC_GET_ENDPOINT`:

```java
    private final String[] PUBLIC_GET_ENDPOINT = {
            "api/users/verify-email/{email}",
            "api/otp/verify",
            "api/location/reverse-geocode",
            "api/venues/*/operating-hours",
            "api/venues/*/availability",
            "/actuator/health",
            "/v3/api-docs/**",
            "/swagger-ui/**",
            "/swagger-ui.html"
    };
```

- [ ] **Step 3: Build and run backend to smoke test**

```bash
make build
```
Expected: BUILD SUCCESS

- [ ] **Step 4: Test availability endpoint manually**

Start the app (`make run`) and call:
```bash
curl "http://localhost:8080/badbook/api/venues/<any-venue-id>/availability?date=2026-06-10"
```
Expected: `{"code":0,"message":null,"data":{"date":"2026-06-10","openTime":null,"closeTime":null,"courts":[]}}` (empty courts because no operating hours configured yet, or venue not found error).

- [ ] **Step 5: Commit**

```bash
git add apps/backend/src/main/java/vn/chuongpl/badbook/features/venue/VenueController.java \
        apps/backend/src/main/java/vn/chuongpl/badbook/configuration/SecurityConfig.java
git commit -m "feat(backend): expose operating hours and availability endpoints"
```

---

## Task 6: UserService changePassword, resetPassword, updateUserProfile + DTOs + tests

**Files:**
- Create: `apps/backend/src/main/java/vn/chuongpl/badbook/features/user/dto/request/UserProfileUpdateRequest.java`
- Create: `apps/backend/src/main/java/vn/chuongpl/badbook/features/user/dto/request/ChangePasswordRequest.java`
- Modify: `apps/backend/src/main/java/vn/chuongpl/badbook/features/user/UserService.java`
- Create: `apps/backend/src/test/java/vn/chuongpl/badbook/features/user/UserServiceTest.java`

- [ ] **Step 1: Create UserProfileUpdateRequest DTO**

Create `apps/backend/src/main/java/vn/chuongpl/badbook/features/user/dto/request/UserProfileUpdateRequest.java`:

```java
package vn.chuongpl.badbook.features.user.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserProfileUpdateRequest {
    String name;
    String phone;
}
```

- [ ] **Step 2: Create ChangePasswordRequest DTO**

Create `apps/backend/src/main/java/vn/chuongpl/badbook/features/user/dto/request/ChangePasswordRequest.java`:

```java
package vn.chuongpl.badbook.features.user.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChangePasswordRequest {
    String currentPassword;
    String newPassword;
}
```

- [ ] **Step 3: Write failing tests for the three new service methods**

Create `apps/backend/src/test/java/vn/chuongpl/badbook/features/user/UserServiceTest.java`:

```java
package vn.chuongpl.badbook.features.user;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.role.RoleRepository;
import vn.chuongpl.badbook.features.user.dto.request.ChangePasswordRequest;
import vn.chuongpl.badbook.features.user.dto.request.UserProfileUpdateRequest;
import vn.chuongpl.badbook.features.user.dto.response.UserResponse;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock UserRepository userRepository;
    @Mock PasswordEncoder passwordEncoder;
    @Mock UserMapper userMapper;
    @Mock RoleRepository roleRepository;
    @InjectMocks UserService userService;

    // --- changePassword ---

    @Test
    void changePassword_throwsInvalidPassword_whenCurrentPasswordIsWrong() {
        String userId = UUID.randomUUID().toString();
        User user = User.builder().id(UUID.fromString(userId)).password("encoded").build();
        ChangePasswordRequest request = new ChangePasswordRequest("wrong", "newPass123");

        when(userRepository.findById(any(UUID.class))).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("wrong", "encoded")).thenReturn(false);

        assertThatThrownBy(() -> userService.changePassword(userId, request))
                .isInstanceOf(AppException.class)
                .extracting("errorCode").isEqualTo(ErrorCode.INVALID_PASSWORD);
    }

    @Test
    void changePassword_encodesAndSavesNewPassword_whenCurrentPasswordIsCorrect() {
        String userId = UUID.randomUUID().toString();
        User user = User.builder().id(UUID.fromString(userId)).password("encoded").build();
        ChangePasswordRequest request = new ChangePasswordRequest("correct", "newPass123");

        when(userRepository.findById(any(UUID.class))).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("correct", "encoded")).thenReturn(true);
        when(passwordEncoder.encode("newPass123")).thenReturn("newEncoded");
        when(userRepository.save(any(User.class))).thenReturn(user);

        userService.changePassword(userId, request);

        verify(passwordEncoder).encode("newPass123");
        verify(userRepository).save(argThat(u -> "newEncoded".equals(u.getPassword())));
    }

    // --- resetPassword ---

    @Test
    void resetPassword_encodesAndSavesNewPassword() {
        String email = "user@example.com";
        User user = User.builder().email(email).password("old-encoded").build();

        when(userRepository.findByEmailAndDeletedFalse(email)).thenReturn(Optional.of(user));
        when(passwordEncoder.encode("newPass123")).thenReturn("new-encoded");
        when(userRepository.save(any(User.class))).thenReturn(user);

        userService.resetPassword(email, "newPass123");

        verify(passwordEncoder).encode("newPass123");
        verify(userRepository).save(argThat(u -> "new-encoded".equals(u.getPassword())));
    }

    @Test
    void resetPassword_throwsAccountNotFound_whenEmailDoesNotExist() {
        when(userRepository.findByEmailAndDeletedFalse("missing@example.com"))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> userService.resetPassword("missing@example.com", "newPass"))
                .isInstanceOf(AppException.class)
                .extracting("errorCode").isEqualTo(ErrorCode.ACCOUNT_NOT_FOUND);
    }

    // --- updateUserProfile ---

    @Test
    void updateUserProfile_updatesNameAndPhone() {
        String userId = UUID.randomUUID().toString();
        User user = User.builder().id(UUID.fromString(userId)).name("Old").phone("000").build();
        UserProfileUpdateRequest request = new UserProfileUpdateRequest("New Name", "111");
        UserResponse response = UserResponse.builder().name("New Name").build();

        when(userRepository.findById(any(UUID.class))).thenReturn(Optional.of(user));
        when(userRepository.save(any(User.class))).thenReturn(user);
        when(userMapper.toUserResponse(any(User.class))).thenReturn(response);

        UserResponse result = userService.updateUserProfile(userId, request);

        verify(userRepository).save(argThat(u -> "New Name".equals(u.getName()) && "111".equals(u.getPhone())));
        assertThat(result.getName()).isEqualTo("New Name");
    }
}
```

- [ ] **Step 4: Run tests to verify they fail**

```bash
./apps/backend/mvnw -f apps/backend/pom.xml test -Dtest=UserServiceTest -pl apps/backend 2>&1 | tail -20
```
Expected: FAIL — methods not found on UserService.

- [ ] **Step 5: Add the three methods to UserService**

In `UserService.java`, add after `getUserResponseById`:

```java
    public UserResponse updateUserProfile(String userId, UserProfileUpdateRequest request) {
        User user = userRepository.findById(parseUuid(userId))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        if (request.getName() != null) user.setName(request.getName());
        if (request.getPhone() != null) user.setPhone(request.getPhone());
        return userMapper.toUserResponse(userRepository.save(user));
    }

    public void changePassword(String userId, ChangePasswordRequest request) {
        User user = userRepository.findById(parseUuid(userId))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword()))
            throw new AppException(ErrorCode.INVALID_PASSWORD);
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    public void resetPassword(String email, String newPassword) {
        User user = userRepository.findByEmailAndDeletedFalse(email)
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }
```

Add imports at the top of `UserService.java`:
```java
import vn.chuongpl.badbook.features.user.dto.request.ChangePasswordRequest;
import vn.chuongpl.badbook.features.user.dto.request.UserProfileUpdateRequest;
import vn.chuongpl.badbook.common.enums.ErrorCode;
```

- [ ] **Step 6: Run tests to verify they pass**

```bash
./apps/backend/mvnw -f apps/backend/pom.xml test -Dtest=UserServiceTest -pl apps/backend 2>&1 | tail -20
```
Expected: All 5 UserServiceTest tests PASS.

- [ ] **Step 7: Commit**

```bash
git add apps/backend/src/main/java/vn/chuongpl/badbook/features/user/dto/request/UserProfileUpdateRequest.java \
        apps/backend/src/main/java/vn/chuongpl/badbook/features/user/dto/request/ChangePasswordRequest.java \
        apps/backend/src/main/java/vn/chuongpl/badbook/features/user/UserService.java \
        apps/backend/src/test/java/vn/chuongpl/badbook/features/user/UserServiceTest.java
git commit -m "feat(backend): add UserService changePassword, resetPassword, updateUserProfile and tests"
```

---

## Task 7: UserController (new file)

**Files:**
- Create: `apps/backend/src/main/java/vn/chuongpl/badbook/features/user/UserController.java`

- [ ] **Step 1: Create UserController**

Create `apps/backend/src/main/java/vn/chuongpl/badbook/features/user/UserController.java`:

```java
package vn.chuongpl.badbook.features.user;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.features.user.dto.request.ChangePasswordRequest;
import vn.chuongpl.badbook.features.user.dto.request.UserProfileUpdateRequest;
import vn.chuongpl.badbook.features.user.dto.response.UserResponse;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<UserResponse> getMyProfile(@AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.<UserResponse>builder()
                .data(userService.getUserResponseById(jwt.getSubject())).build();
    }

    @PutMapping("/me")
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<UserResponse> updateMyProfile(@AuthenticationPrincipal Jwt jwt,
                                                      @RequestBody UserProfileUpdateRequest request) {
        return ApiResponse.<UserResponse>builder()
                .data(userService.updateUserProfile(jwt.getSubject(), request)).build();
    }

    @PutMapping("/me/password")
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<Void> changePassword(@AuthenticationPrincipal Jwt jwt,
                                             @RequestBody ChangePasswordRequest request) {
        userService.changePassword(jwt.getSubject(), request);
        return ApiResponse.<Void>builder().build();
    }
}
```

- [ ] **Step 2: Build**

```bash
make build
```
Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add apps/backend/src/main/java/vn/chuongpl/badbook/features/user/UserController.java
git commit -m "feat(backend): add UserController with profile and change-password endpoints"
```

---

## Task 8: AdminController user management endpoints

**Files:**
- Modify: `apps/backend/src/main/java/vn/chuongpl/badbook/features/admin/AdminController.java`

- [ ] **Step 1: Inject UserService into AdminController**

In `AdminController.java`, add these imports at the top of the file (after existing imports):

```java
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.features.user.UserService;
import vn.chuongpl.badbook.features.user.dto.request.UserCreateRequest;
import vn.chuongpl.badbook.features.user.dto.response.UserResponse;
```

The `AdminController` uses `@Autowired` (not constructor injection). Add the field and three methods:

```java
    @Autowired
    private UserService userService;

    @GetMapping("/users")
    public ApiResponse<PageResponse<UserResponse>> getUsers(
            @RequestParam(defaultValue = "1") Integer page) {
        return ApiResponse.<PageResponse<UserResponse>>builder()
                .data(userService.getAllUser(page)).build();
    }

    @PostMapping("/users")
    public ApiResponse<UserResponse> createUser(@RequestBody UserCreateRequest request) {
        return ApiResponse.<UserResponse>builder()
                .data(userService.createUser(request)).build();
    }

    @DeleteMapping("/users/{id}")
    public ApiResponse<Void> deleteUser(@PathVariable String id) {
        userService.deleteUser(id);
        return ApiResponse.<Void>builder().build();
    }
```

- [ ] **Step 2: Build**

```bash
make build
```
Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add apps/backend/src/main/java/vn/chuongpl/badbook/features/admin/AdminController.java
git commit -m "feat(backend): add admin user management endpoints (list, create, delete)"
```

---

## Task 9: AuthResponse + Auth DTOs + AuthService refresh token

**Files:**
- Modify: `apps/backend/src/main/java/vn/chuongpl/badbook/features/auth/dto/response/AuthResponse.java`
- Create: `apps/backend/src/main/java/vn/chuongpl/badbook/features/auth/dto/request/RefreshTokenRequest.java`
- Create: `apps/backend/src/main/java/vn/chuongpl/badbook/features/auth/dto/request/ResetPasswordRequest.java`
- Create: `apps/backend/src/main/java/vn/chuongpl/badbook/features/auth/dto/request/LogoutRequest.java`
- Modify: `apps/backend/src/main/java/vn/chuongpl/badbook/features/auth/AuthService.java`

- [ ] **Step 1: Add refreshToken to AuthResponse**

In `AuthResponse.java`, add the field:

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuthResponse {
    private String token;
    private String refreshToken;
    private boolean authenticated;
}
```

- [ ] **Step 2: Create RefreshTokenRequest DTO**

Create `apps/backend/src/main/java/vn/chuongpl/badbook/features/auth/dto/request/RefreshTokenRequest.java`:

```java
package vn.chuongpl.badbook.features.auth.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RefreshTokenRequest {
    private String refreshToken;
}
```

- [ ] **Step 3: Create ResetPasswordRequest DTO**

Create `apps/backend/src/main/java/vn/chuongpl/badbook/features/auth/dto/request/ResetPasswordRequest.java`:

```java
package vn.chuongpl.badbook.features.auth.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ResetPasswordRequest {
    private String email;
    private String otp;
    private String newPassword;
}
```

- [ ] **Step 4: Create LogoutRequest DTO**

Create `apps/backend/src/main/java/vn/chuongpl/badbook/features/auth/dto/request/LogoutRequest.java`:

```java
package vn.chuongpl.badbook.features.auth.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LogoutRequest {
    private String refreshToken;
}
```

- [ ] **Step 5: Refactor AuthService — generatedToken + login + refresh + logout**

Replace `AuthService.java` with the following (preserve all existing imports and add new ones):

New imports needed:
```java
import vn.chuongpl.badbook.features.auth.dto.request.RefreshTokenRequest;
import java.time.temporal.ChronoUnit;
```

**Updated `generatedToken` method** (rename parameter to include tokenType and ttl):

```java
    private String generatedToken(User user, String tokenType, long ttlMinutes) {
        JWSHeader jwsHeader = new JWSHeader(JWSAlgorithm.HS512);
        JWTClaimsSet jwtClaimsSet = new JWTClaimsSet.Builder()
                .subject(user.getId().toString())
                .issuer(user.getName())
                .issueTime(new Date())
                .expirationTime(new Date(
                        Instant.now().plus(ttlMinutes, ChronoUnit.MINUTES).toEpochMilli()
                ))
                .jwtID(UUID.randomUUID().toString())
                .claim("scope", buildScope(user))
                .claim("tokenType", tokenType)
                .build();
        Payload payload = new Payload(jwtClaimsSet.toJSONObject());
        JWSObject jwsObject = new JWSObject(jwsHeader, payload);
        try {
            jwsObject.sign(new MACSigner(SIGN_KEY));
        } catch (Exception e) {
            log.debug("Không thể tạo token với lỗi = " + e.getMessage());
            throw new RuntimeException(e);
        }
        return jwsObject.serialize();
    }
```

**Updated `authenticated` method** (issues both tokens):

```java
    public AuthResponse authenticated(LoginRequest request) {
        PasswordEncoder passwordEncoder = new BCryptPasswordEncoder(10);
        var user = userRepository.findByEmailAndDeletedFalse(request.getEmail())
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        boolean authenticated = passwordEncoder.matches(request.getPassword(), user.getPassword());
        if (!authenticated) {
            throw new AppException(ErrorCode.AUTHENTICATION_FAILED);
        }
        String accessToken = generatedToken(user, "access", 30);
        String refreshToken = generatedToken(user, "refresh", 7 * 24 * 60L);
        return AuthResponse.builder()
                .token(accessToken)
                .refreshToken(refreshToken)
                .authenticated(true)
                .build();
    }
```

**Updated `logout` method** (blacklists both tokens):

```java
    public void logout(String accessToken, String refreshToken) throws JOSEException, ParseException {
        var signAccess = verifySignedJWT(accessToken);
        var expiryAccess = signAccess.getJWTClaimsSet().getExpirationTime();
        long accessDiff = (expiryAccess.getTime() - System.currentTimeMillis()) / 1000;
        if (accessDiff > 0) jwtBlacklistService.addTokenToBlacklist(accessToken, accessDiff);

        if (refreshToken != null && !refreshToken.isBlank()) {
            try {
                var signRefresh = verifySignedJWT(refreshToken);
                var expiryRefresh = signRefresh.getJWTClaimsSet().getExpirationTime();
                long refreshDiff = (expiryRefresh.getTime() - System.currentTimeMillis()) / 1000;
                if (refreshDiff > 0) jwtBlacklistService.addTokenToBlacklist(refreshToken, refreshDiff);
            } catch (Exception e) {
                log.warn("Could not blacklist refresh token: {}", e.getMessage());
            }
        }
    }
```

**New `refreshAccessToken` method**:

```java
    public AuthResponse refreshAccessToken(String refreshToken) throws JOSEException, ParseException {
        SignedJWT signedJWT = verifySignedJWT(refreshToken);
        String tokenType = (String) signedJWT.getJWTClaimsSet().getClaim("tokenType");
        if (!"refresh".equals(tokenType)) throw new AppException(ErrorCode.INVALID_TOKEN);
        if (jwtBlacklistService.isBlacklisted(refreshToken)) throw new AppException(ErrorCode.INVALID_TOKEN);
        String userId = signedJWT.getJWTClaimsSet().getSubject();
        User user = userRepository.findById(UUID.fromString(userId))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        return AuthResponse.builder()
                .token(generatedToken(user, "access", 30))
                .authenticated(true)
                .build();
    }
```

- [ ] **Step 6: Build to verify compilation**

```bash
make build
```
Expected: BUILD SUCCESS (note: AuthController still calls old `logout(String)` so will fail — that's fixed in Task 10).

- [ ] **Step 7: Commit**

```bash
git add apps/backend/src/main/java/vn/chuongpl/badbook/features/auth/dto/ \
        apps/backend/src/main/java/vn/chuongpl/badbook/features/auth/AuthService.java
git commit -m "feat(backend): add refresh token support to AuthService and DTOs"
```

---

## Task 10: AuthController /refresh + /reset-password + update /logout + SecurityConfig

**Files:**
- Modify: `apps/backend/src/main/java/vn/chuongpl/badbook/features/auth/AuthController.java`
- Modify: `apps/backend/src/main/java/vn/chuongpl/badbook/configuration/SecurityConfig.java`

- [ ] **Step 1: Update AuthController**

Replace `AuthController.java` with the following (keeps all existing endpoints, updates logout, adds 2 new endpoints):

```java
package vn.chuongpl.badbook.features.auth;

import java.text.ParseException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.nimbusds.jose.JOSEException;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.auth.dto.request.LoginRequest;
import vn.chuongpl.badbook.features.auth.dto.request.LogoutRequest;
import vn.chuongpl.badbook.features.auth.dto.request.RefreshTokenRequest;
import vn.chuongpl.badbook.features.auth.dto.request.RegisterRequest;
import vn.chuongpl.badbook.features.auth.dto.request.ResetPasswordRequest;
import vn.chuongpl.badbook.features.auth.dto.response.AuthResponse;
import vn.chuongpl.badbook.features.otp.OtpService;
import vn.chuongpl.badbook.features.user.UserService;
import vn.chuongpl.badbook.features.user.dto.response.UserResponse;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired AuthService authService;
    @Autowired UserService userService;
    @Autowired OtpService otpService;

    @PostMapping
    public ApiResponse<AuthResponse> authenticated(@RequestBody LoginRequest request) {
        return ApiResponse.<AuthResponse>builder()
                .data(authService.authenticated(request))
                .build();
    }

    @PostMapping("/register")
    public ApiResponse<UserResponse> register(@RequestBody RegisterRequest request) {
        return ApiResponse.<UserResponse>builder()
                .data(userService.register(request))
                .message("Đăng ký thành công")
                .build();
    }

    @PostMapping("/logout")
    public ApiResponse<Void> logout(@AuthenticationPrincipal Jwt jwt,
                                     @RequestBody LogoutRequest request)
            throws ParseException, JOSEException {
        authService.logout(jwt.getTokenValue(),
                request != null ? request.getRefreshToken() : null);
        return ApiResponse.<Void>builder()
                .message("Logout successfully")
                .build();
    }

    @PostMapping("/refresh")
    public ApiResponse<AuthResponse> refresh(@RequestBody RefreshTokenRequest request)
            throws ParseException, JOSEException {
        return ApiResponse.<AuthResponse>builder()
                .data(authService.refreshAccessToken(request.getRefreshToken()))
                .build();
    }

    @PostMapping("/reset-password")
    public ApiResponse<Void> resetPassword(@RequestBody ResetPasswordRequest request) {
        boolean valid = otpService.validateOtp(request.getEmail(), request.getOtp());
        if (!valid) throw new AppException(ErrorCode.OTP_INVALID);
        userService.resetPassword(request.getEmail(), request.getNewPassword());
        return ApiResponse.<Void>builder()
                .message("Đặt lại mật khẩu thành công")
                .build();
    }
}
```

- [ ] **Step 2: Whitelist /refresh and /reset-password in SecurityConfig**

In `SecurityConfig.java`, add to `PUBLIC_POST_ENDPOINT`:

```java
    private final String[] PUBLIC_POST_ENDPOINT = {
            "api/auth",
            "api/auth/register",
            "api/auth/refresh",
            "api/auth/reset-password",
            "api/otp/send",
            "api/location/geocode",
            "api/media"
    };
```

- [ ] **Step 3: Build**

```bash
make build
```
Expected: BUILD SUCCESS

- [ ] **Step 4: Run all backend tests**

```bash
make test 2>&1 | tail -30
```
Expected: All tests pass.

- [ ] **Step 5: Smoke test the refresh endpoint**

```bash
# First login to get tokens
curl -s -X POST http://localhost:8080/badbook/api/auth \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@gmail.com","password":"admin123"}' | python3 -m json.tool
# Copy the refreshToken from response, then:
curl -s -X POST http://localhost:8080/badbook/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refreshToken":"<paste-token>"}' | python3 -m json.tool
```
Expected: Response contains new `token` field.

- [ ] **Step 6: Commit**

```bash
git add apps/backend/src/main/java/vn/chuongpl/badbook/features/auth/AuthController.java \
        apps/backend/src/main/java/vn/chuongpl/badbook/configuration/SecurityConfig.java
git commit -m "feat(backend): add /auth/refresh and /auth/reset-password endpoints, update logout"
```

---

## Task 11: FinanceController (VM invoice read)

**Files:**
- Create: `apps/backend/src/main/java/vn/chuongpl/badbook/features/finance/FinanceController.java`

- [ ] **Step 1: Create FinanceController**

Create `apps/backend/src/main/java/vn/chuongpl/badbook/features/finance/FinanceController.java`:

```java
package vn.chuongpl.badbook.features.finance;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.Venue;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.util.List;

@RestController
@RequestMapping("/api/finance")
@RequiredArgsConstructor
public class FinanceController {

    private final FinanceService financeService;
    private final VenueRepository venueRepository;
    private final UserRepository userRepository;

    @GetMapping("/my-invoices")
    @PreAuthorize("hasRole('VENUE_MANAGER')")
    public ApiResponse<List<PlatformFeeInvoice>> getMyInvoices(@AuthenticationPrincipal Jwt jwt) {
        User user = userRepository.findById(java.util.UUID.fromString(jwt.getSubject()))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        Venue venue = venueRepository.findByOwner(user)
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));
        return ApiResponse.<List<PlatformFeeInvoice>>builder()
                .data(financeService.getVenueInvoices(venue.getId().toString()))
                .build();
    }
}
```

- [ ] **Step 2: Build**

```bash
make build
```
Expected: BUILD SUCCESS

- [ ] **Step 3: Run all backend tests**

```bash
make test 2>&1 | tail -20
```
Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
git add apps/backend/src/main/java/vn/chuongpl/badbook/features/finance/FinanceController.java
git commit -m "feat(backend): add FinanceController for VENUE_MANAGER invoice read (FR-VM-09)"
```

---

## Verification Checklist

After all tasks are complete, verify each FR is served:

| FR | Endpoint | Verify |
|----|----------|--------|
| FR-USER-09 | `GET /api/venues/{id}/availability?date=YYYY-MM-DD` | Returns slot grid |
| FR-USER-17 | `GET /api/users/me` | Returns profile |
| FR-USER-17 | `PUT /api/users/me` | Updates name/phone |
| FR-USER-17 | `PUT /api/users/me/password` | Changes password |
| FR-USER-05 | `POST /api/auth/reset-password` | Resets password via OTP |
| FR-ADM-06 | `GET /api/admin/users` | Lists users (ADMIN) |
| FR-ADM-06 | `POST /api/admin/users` | Creates user (ADMIN) |
| FR-ADM-06 | `DELETE /api/admin/users/{id}` | Deletes user (ADMIN) |
| FR-VM-09 | `GET /api/finance/my-invoices` | Lists own invoices |
| — | `POST /api/auth/refresh` | Returns new access token |
| — | `PUT /api/venues/{id}/operating-hours` | Upserts venue hours |

Run final test suite:
```bash
make test
```
Expected: All tests pass.
