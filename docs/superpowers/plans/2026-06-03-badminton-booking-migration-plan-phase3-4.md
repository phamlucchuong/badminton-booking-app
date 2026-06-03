# Badminton Booking BE — Migration Implementation Plan (Phase 3 & 4)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax for tracking.
> **Prerequisite:** Phase 1 & 2 plan must be complete first.

> **Cross-package visibility fix:** `CourtService.findCourt()`, `BookingService.findBooking()`, and `ProductService.findProduct()` must be declared `public` (not package-private) because they are called from other feature packages (e.g. VNPayService, BookingService). When writing these methods, add `public` modifier.

**Goal:** Build booking system with conflict detection + VNPay payment + finance tracking, then reviews, search, and admin dashboard.

**Architecture:** Same feature-based module pattern as Phase 1 & 2.

---

## PHASE 3 — Booking + Payment + Finance

### Task 14: Add Phase 3 enums

**Files:**
- Create: `src/main/java/vn/chuongpl/badbook/common/enums/BookingStatus.java`
- Create: `src/main/java/vn/chuongpl/badbook/common/enums/BookingType.java`
- Create: `src/main/java/vn/chuongpl/badbook/common/enums/PaymentStatus.java`
- Create: `src/main/java/vn/chuongpl/badbook/common/enums/PaymentMethod.java`
- Create: `src/main/java/vn/chuongpl/badbook/common/enums/PlatformFeeStatus.java`

- [ ] **Step 1: Create all Phase 3 enums**

`src/main/java/vn/chuongpl/badbook/common/enums/BookingStatus.java`:
```java
package vn.chuongpl.badbook.common.enums;

public enum BookingStatus {
    PENDING, CONFIRMED, IN_PROGRESS, COMPLETED, CANCELLED
}
```

`src/main/java/vn/chuongpl/badbook/common/enums/BookingType.java`:
```java
package vn.chuongpl.badbook.common.enums;

public enum BookingType {
    HOURLY, FIXED
}
```

`src/main/java/vn/chuongpl/badbook/common/enums/PaymentStatus.java`:
```java
package vn.chuongpl.badbook.common.enums;

public enum PaymentStatus {
    PENDING, SUCCESS, FAILED, REFUNDED
}
```

`src/main/java/vn/chuongpl/badbook/common/enums/PaymentMethod.java`:
```java
package vn.chuongpl.badbook.common.enums;

public enum PaymentMethod {
    VNPAY, CASH
}
```

`src/main/java/vn/chuongpl/badbook/common/enums/PlatformFeeStatus.java`:
```java
package vn.chuongpl.badbook.common.enums;

public enum PlatformFeeStatus {
    PENDING, PAID, OVERDUE
}
```

- [ ] **Step 2: Commit**
```bash
git add src/main/java/vn/chuongpl/badbook/common/enums/
git commit -m "feat: add Phase 3 enums (BookingStatus, BookingType, PaymentStatus, PaymentMethod, PlatformFeeStatus)"
```

---

### Task 15: Booking + BookingProduct entities + Flyway V7, V8

**Files:**
- Create: `src/main/resources/db/migration/V7__create_bookings_table.sql`
- Create: `src/main/resources/db/migration/V8__create_booking_products_table.sql`
- Create: `src/main/java/vn/chuongpl/badbook/features/booking/Booking.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/booking/BookingProduct.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/booking/BookingRepository.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/booking/BookingProductRepository.java`

- [ ] **Step 1: Create V7 migration**

`src/main/resources/db/migration/V7__create_bookings_table.sql`:
```sql
CREATE TABLE bookings (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID NOT NULL REFERENCES users(id),
    court_id     UUID NOT NULL REFERENCES courts(id),
    venue_id     UUID NOT NULL REFERENCES venues(id),
    booking_date DATE NOT NULL,
    start_time   TIME NOT NULL,
    end_time     TIME NOT NULL,
    type         VARCHAR(10) NOT NULL DEFAULT 'HOURLY' CHECK (type IN ('HOURLY','FIXED')),
    status       VARCHAR(15) NOT NULL DEFAULT 'PENDING'
                     CHECK (status IN ('PENDING','CONFIRMED','IN_PROGRESS','COMPLETED','CANCELLED')),
    total_amount DECIMAL(14,2) NOT NULL CHECK (total_amount >= 0),
    notes        TEXT,
    cancel_reason TEXT,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP
);

CREATE INDEX idx_bookings_user ON bookings(user_id);
CREATE INDEX idx_bookings_court_date ON bookings(court_id, booking_date);
CREATE INDEX idx_bookings_venue ON bookings(venue_id);
CREATE INDEX idx_bookings_status ON bookings(status);
```

- [ ] **Step 2: Create V8 migration**

`src/main/resources/db/migration/V8__create_booking_products_table.sql`:
```sql
CREATE TABLE booking_products (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id   UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    product_id   UUID REFERENCES products(id),
    product_name VARCHAR(255) NOT NULL,
    quantity     INT NOT NULL CHECK (quantity > 0),
    unit_price   DECIMAL(12,2) NOT NULL CHECK (unit_price >= 0),
    total_price  DECIMAL(14,2) NOT NULL CHECK (total_price >= 0)
);

CREATE INDEX idx_booking_products_booking ON booking_products(booking_id);
```

- [ ] **Step 3: Create Booking entity**

`src/main/java/vn/chuongpl/badbook/features/booking/Booking.java`:
```java
package vn.chuongpl.badbook.features.booking;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.BookingStatus;
import vn.chuongpl.badbook.common.enums.BookingType;
import vn.chuongpl.badbook.features.court.Court;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.venue.Venue;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity @Table(name = "bookings")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Booking {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false) User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "court_id", nullable = false) Court court;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "venue_id", nullable = false) Venue venue;

    @Column(name = "booking_date", nullable = false) LocalDate bookingDate;
    @Column(name = "start_time", nullable = false) LocalTime startTime;
    @Column(name = "end_time", nullable = false) LocalTime endTime;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    @Builder.Default BookingType type = BookingType.HOURLY;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 15)
    @Builder.Default BookingStatus status = BookingStatus.PENDING;

    @Column(name = "total_amount", nullable = false, precision = 14, scale = 2)
    BigDecimal totalAmount;

    @Column(columnDefinition = "TEXT") String notes;
    @Column(name = "cancel_reason", columnDefinition = "TEXT") String cancelReason;

    @Column(name = "created_at", updatable = false) LocalDateTime createdAt;
    @Column(name = "updated_at") LocalDateTime updatedAt;

    @OneToMany(mappedBy = "booking", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default List<BookingProduct> products = new ArrayList<>();

    @PrePersist void prePersist() { this.createdAt = LocalDateTime.now(); }
    @PreUpdate void preUpdate() { this.updatedAt = LocalDateTime.now(); }
}
```

- [ ] **Step 4: Create BookingProduct entity**

`src/main/java/vn/chuongpl/badbook/features/booking/BookingProduct.java`:
```java
package vn.chuongpl.badbook.features.booking;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.features.product.Product;

import java.math.BigDecimal;
import java.util.UUID;

@Entity @Table(name = "booking_products")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class BookingProduct {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", nullable = false) Booking booking;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id") Product product;

    @Column(name = "product_name", nullable = false) String productName;
    @Column(nullable = false) int quantity;
    @Column(name = "unit_price", nullable = false, precision = 12, scale = 2) BigDecimal unitPrice;
    @Column(name = "total_price", nullable = false, precision = 14, scale = 2) BigDecimal totalPrice;
}
```

- [ ] **Step 5: Create repositories**

`src/main/java/vn/chuongpl/badbook/features/booking/BookingRepository.java`:
```java
package vn.chuongpl.badbook.features.booking;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.chuongpl.badbook.common.enums.BookingStatus;
import vn.chuongpl.badbook.features.court.Court;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.venue.Venue;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

public interface BookingRepository extends JpaRepository<Booking, UUID> {

    @Query("""
        SELECT COUNT(b) > 0 FROM Booking b
        WHERE b.court = :court
        AND b.bookingDate = :date
        AND b.status IN ('CONFIRMED', 'IN_PROGRESS')
        AND b.startTime < :endTime
        AND b.endTime > :startTime
    """)
    boolean existsConflict(@Param("court") Court court,
                           @Param("date") LocalDate date,
                           @Param("startTime") LocalTime startTime,
                           @Param("endTime") LocalTime endTime);

    Page<Booking> findByUser(User user, Pageable pageable);
    Page<Booking> findByVenue(Venue venue, Pageable pageable);
    List<Booking> findByVenueAndStatusAndBookingDate(Venue venue, BookingStatus status, LocalDate date);
}
```

`src/main/java/vn/chuongpl/badbook/features/booking/BookingProductRepository.java`:
```java
package vn.chuongpl.badbook.features.booking;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface BookingProductRepository extends JpaRepository<BookingProduct, UUID> {}
```

- [ ] **Step 6: Commit**
```bash
git add src/main/resources/db/migration/V7__create_bookings_table.sql
git add src/main/resources/db/migration/V8__create_booking_products_table.sql
git add src/main/java/vn/chuongpl/badbook/features/booking/
git commit -m "feat: add Booking and BookingProduct entities (V7, V8 migrations)"
```

---

### Task 16: Booking DTOs, Mapper, Service with conflict detection

**Files:**
- Create: `src/main/java/vn/chuongpl/badbook/features/booking/dto/request/BookingCreateRequest.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/booking/dto/request/AddProductRequest.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/booking/dto/response/BookingResponse.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/booking/BookingMapper.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/booking/BookingService.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/booking/BookingController.java`
- Create: `src/test/java/vn/chuongpl/badbook/features/booking/BookingServiceTest.java`

- [ ] **Step 1: Create DTOs**

`src/main/java/vn/chuongpl/badbook/features/booking/dto/request/BookingCreateRequest.java`:
```java
package vn.chuongpl.badbook.features.booking.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.BookingType;
import vn.chuongpl.badbook.common.enums.PaymentMethod;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class BookingCreateRequest {
    String courtId;
    String venueId;
    LocalDate bookingDate;
    LocalTime startTime;
    LocalTime endTime;
    BookingType type;
    PaymentMethod paymentMethod;
    String notes;
    List<AddProductRequest> products;
}
```

`src/main/java/vn/chuongpl/badbook/features/booking/dto/request/AddProductRequest.java`:
```java
package vn.chuongpl.badbook.features.booking.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class AddProductRequest {
    String productId;
    int quantity;
}
```

`src/main/java/vn/chuongpl/badbook/features/booking/dto/response/BookingResponse.java`:
```java
package vn.chuongpl.badbook.features.booking.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.BookingStatus;
import vn.chuongpl.badbook.common.enums.BookingType;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class BookingResponse {
    UUID id;
    String userName;
    String courtName;
    String venueName;
    LocalDate bookingDate;
    LocalTime startTime;
    LocalTime endTime;
    BookingType type;
    BookingStatus status;
    BigDecimal totalAmount;
    String notes;
    String cancelReason;
    LocalDateTime createdAt;
    List<BookingProductResponse> products;

    @Data @Builder @NoArgsConstructor @AllArgsConstructor
    public static class BookingProductResponse {
        String productName;
        int quantity;
        BigDecimal unitPrice;
        BigDecimal totalPrice;
    }
}
```

- [ ] **Step 2: Create BookingMapper**

`src/main/java/vn/chuongpl/badbook/features/booking/BookingMapper.java`:
```java
package vn.chuongpl.badbook.features.booking;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import vn.chuongpl.badbook.features.booking.dto.response.BookingResponse;

@Mapper(componentModel = "spring")
public interface BookingMapper {

    @Mapping(source = "user.name", target = "userName")
    @Mapping(source = "court.name", target = "courtName")
    @Mapping(source = "venue.name", target = "venueName")
    @Mapping(source = "products", target = "products")
    BookingResponse toResponse(Booking booking);

    @Mapping(source = "productName", target = "productName")
    BookingResponse.BookingProductResponse toProductResponse(BookingProduct bp);
}
```

- [ ] **Step 3: Write failing test for conflict detection**

`src/test/java/vn/chuongpl/badbook/features/booking/BookingServiceTest.java`:
```java
package vn.chuongpl.badbook.features.booking;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import vn.chuongpl.badbook.common.enums.*;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.booking.dto.request.BookingCreateRequest;
import vn.chuongpl.badbook.features.booking.dto.response.BookingResponse;
import vn.chuongpl.badbook.features.court.Court;
import vn.chuongpl.badbook.features.court.CourtService;
import vn.chuongpl.badbook.features.product.ProductService;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.Venue;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class BookingServiceTest {

    @Mock BookingRepository bookingRepository;
    @Mock BookingProductRepository bookingProductRepository;
    @Mock UserRepository userRepository;
    @Mock VenueRepository venueRepository;
    @Mock CourtService courtService;
    @Mock ProductService productService;
    @Mock BookingMapper bookingMapper;
    @InjectMocks BookingService bookingService;

    @Test
    void createBooking_throwsOnConflict() {
        UUID userId = UUID.randomUUID(), courtId = UUID.randomUUID(), venueId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        Venue venue = Venue.builder().id(venueId).status(VenueStatus.ACTIVE)
                .platformFeeRate(new BigDecimal("0.1")).build();
        Court court = Court.builder().id(courtId).venue(venue)
                .status(CourtStatus.ACTIVE).pricePerHour(new BigDecimal("80000")).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
        when(courtService.findCourt(courtId.toString())).thenReturn(court);
        when(bookingRepository.existsConflict(eq(court), any(), any(), any())).thenReturn(true);

        BookingCreateRequest req = BookingCreateRequest.builder()
                .courtId(courtId.toString()).venueId(venueId.toString())
                .bookingDate(LocalDate.now().plusDays(1))
                .startTime(LocalTime.of(8, 0)).endTime(LocalTime.of(10, 0))
                .type(BookingType.HOURLY).paymentMethod(PaymentMethod.CASH)
                .products(List.of()).build();

        assertThatThrownBy(() -> bookingService.createBooking(userId.toString(), req))
                .isInstanceOf(AppException.class)
                .extracting(e -> ((AppException) e).getErrorCode())
                .isEqualTo(ErrorCode.BOOKING_CONFLICT);
    }

    @Test
    void createBooking_calculatesTotalFromCourtHoursAndProducts() {
        UUID userId = UUID.randomUUID(), courtId = UUID.randomUUID(), venueId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        Venue venue = Venue.builder().id(venueId).status(VenueStatus.ACTIVE)
                .platformFeeRate(new BigDecimal("0.1")).build();
        Court court = Court.builder().id(courtId).venue(venue)
                .status(CourtStatus.ACTIVE).pricePerHour(new BigDecimal("80000")).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
        when(courtService.findCourt(courtId.toString())).thenReturn(court);
        when(bookingRepository.existsConflict(any(), any(), any(), any())).thenReturn(false);
        when(bookingRepository.save(any())).thenAnswer(i -> {
            Booking b = i.getArgument(0);
            b.setId(UUID.randomUUID());
            return b;
        });
        when(bookingMapper.toResponse(any())).thenReturn(
                BookingResponse.builder().totalAmount(new BigDecimal("160000")).build());

        BookingCreateRequest req = BookingCreateRequest.builder()
                .courtId(courtId.toString()).venueId(venueId.toString())
                .bookingDate(LocalDate.now().plusDays(1))
                .startTime(LocalTime.of(8, 0)).endTime(LocalTime.of(10, 0)) // 2 hours
                .type(BookingType.HOURLY).paymentMethod(PaymentMethod.CASH)
                .products(List.of()).build();

        BookingResponse result = bookingService.createBooking(userId.toString(), req);
        assertThat(result.getTotalAmount()).isEqualByComparingTo(new BigDecimal("160000"));
    }

    @Test
    void cancelBooking_throwsWhenAlreadyCompleted() {
        UUID bookingId = UUID.randomUUID(), userId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        Booking booking = Booking.builder().id(bookingId).user(user).status(BookingStatus.COMPLETED).build();

        when(bookingRepository.findById(bookingId)).thenReturn(Optional.of(booking));
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));

        assertThatThrownBy(() -> bookingService.cancelBooking(bookingId.toString(), userId.toString(), "test"))
                .isInstanceOf(AppException.class)
                .extracting(e -> ((AppException) e).getErrorCode())
                .isEqualTo(ErrorCode.BOOKING_CANNOT_CANCEL);
    }
}
```

- [ ] **Step 4: Run test — expect FAIL**
```bash
mvn test -Dtest=BookingServiceTest -q 2>&1 | tail -5
```

- [ ] **Step 5: Create BookingService**

`src/main/java/vn/chuongpl/badbook/features/booking/BookingService.java`:
```java
package vn.chuongpl.badbook.features.booking;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.common.enums.*;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.booking.dto.request.AddProductRequest;
import vn.chuongpl.badbook.features.booking.dto.request.BookingCreateRequest;
import vn.chuongpl.badbook.features.booking.dto.response.BookingResponse;
import vn.chuongpl.badbook.features.court.Court;
import vn.chuongpl.badbook.features.court.CourtService;
import vn.chuongpl.badbook.features.product.Product;
import vn.chuongpl.badbook.features.product.ProductService;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.Venue;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.math.BigDecimal;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class BookingService {

    BookingRepository bookingRepository;
    BookingProductRepository bookingProductRepository;
    UserRepository userRepository;
    VenueRepository venueRepository;
    CourtService courtService;
    ProductService productService;
    BookingMapper bookingMapper;

    @Transactional
    public BookingResponse createBooking(String userId, BookingCreateRequest request) {
        User user = findUser(userId);
        Venue venue = findVenue(request.getVenueId());
        Court court = courtService.findCourt(request.getCourtId());

        if (court.getStatus() != CourtStatus.ACTIVE) throw new AppException(ErrorCode.COURT_NOT_AVAILABLE);
        if (venue.getStatus() != VenueStatus.ACTIVE) throw new AppException(ErrorCode.VENUE_NOT_APPROVED);
        if (!court.getVenue().getId().equals(venue.getId())) throw new AppException(ErrorCode.COURT_NOT_IN_VENUE);

        if (bookingRepository.existsConflict(court, request.getBookingDate(),
                request.getStartTime(), request.getEndTime())) {
            throw new AppException(ErrorCode.BOOKING_CONFLICT);
        }

        long hours = Duration.between(request.getStartTime(), request.getEndTime()).toHours();
        BigDecimal courtAmount = court.getPricePerHour().multiply(BigDecimal.valueOf(hours));

        List<BookingProduct> bookingProducts = new ArrayList<>();
        BigDecimal productsTotal = BigDecimal.ZERO;

        if (request.getProducts() != null) {
            for (AddProductRequest pr : request.getProducts()) {
                Product product = productService.findProduct(pr.getProductId());
                if (!product.getVenue().getId().equals(venue.getId()))
                    throw new AppException(ErrorCode.PRODUCT_NOT_IN_VENUE);
                if (product.getStock() < pr.getQuantity())
                    throw new AppException(ErrorCode.PRODUCT_OUT_OF_STOCK);

                BigDecimal lineTotal = product.getPrice().multiply(BigDecimal.valueOf(pr.getQuantity()));
                productsTotal = productsTotal.add(lineTotal);
                bookingProducts.add(BookingProduct.builder()
                        .product(product).productName(product.getName())
                        .quantity(pr.getQuantity()).unitPrice(product.getPrice()).totalPrice(lineTotal)
                        .build());
                productService.decreaseStock(venue.getId().toString(), pr.getProductId(), pr.getQuantity());
            }
        }

        Booking booking = bookingRepository.save(Booking.builder()
                .user(user).court(court).venue(venue)
                .bookingDate(request.getBookingDate())
                .startTime(request.getStartTime()).endTime(request.getEndTime())
                .type(request.getType() != null ? request.getType() : BookingType.HOURLY)
                .status(BookingStatus.PENDING)
                .totalAmount(courtAmount.add(productsTotal))
                .notes(request.getNotes())
                .build());

        bookingProducts.forEach(bp -> bp.setBooking(booking));
        bookingProductRepository.saveAll(bookingProducts);
        booking.setProducts(bookingProducts);

        return bookingMapper.toResponse(booking);
    }

    @Transactional
    public BookingResponse confirmBooking(String bookingId, String venueManagerId) {
        Booking booking = findBooking(bookingId);
        User manager = findUser(venueManagerId);
        if (!booking.getVenue().getOwner().getId().equals(manager.getId()))
            throw new AppException(ErrorCode.UNAUTHORIZED);
        if (booking.getStatus() != BookingStatus.PENDING)
            throw new AppException(ErrorCode.BOOKING_CANNOT_CANCEL);
        booking.setStatus(BookingStatus.CONFIRMED);
        return bookingMapper.toResponse(bookingRepository.save(booking));
    }

    @Transactional
    public BookingResponse cancelBooking(String bookingId, String userId, String reason) {
        Booking booking = findBooking(bookingId);
        User user = findUser(userId);
        boolean isOwner = booking.getUser().getId().equals(user.getId());
        boolean isManager = booking.getVenue().getOwner().getId().equals(user.getId());
        if (!isOwner && !isManager) throw new AppException(ErrorCode.UNAUTHORIZED);
        if (booking.getStatus() == BookingStatus.COMPLETED
                || booking.getStatus() == BookingStatus.IN_PROGRESS
                || booking.getStatus() == BookingStatus.CANCELLED) {
            throw new AppException(ErrorCode.BOOKING_CANNOT_CANCEL);
        }
        booking.setStatus(BookingStatus.CANCELLED);
        booking.setCancelReason(reason);
        return bookingMapper.toResponse(bookingRepository.save(booking));
    }

    @Transactional
    public BookingResponse completeBooking(String bookingId) {
        Booking booking = findBooking(bookingId);
        if (booking.getStatus() != BookingStatus.CONFIRMED && booking.getStatus() != BookingStatus.IN_PROGRESS)
            throw new AppException(ErrorCode.BOOKING_CANNOT_CANCEL);
        booking.setStatus(BookingStatus.COMPLETED);
        return bookingMapper.toResponse(bookingRepository.save(booking));
    }

    public PageResponse<BookingResponse> getUserBookings(String userId, int page, int size) {
        User user = findUser(userId);
        Page<Booking> result = bookingRepository.findByUser(user,
                PageRequest.of(page - 1, size, Sort.by("createdAt").descending()));
        return buildPage(result, page, size);
    }

    public PageResponse<BookingResponse> getVenueBookings(String venueId, int page, int size) {
        Venue venue = findVenue(venueId);
        Page<Booking> result = bookingRepository.findByVenue(venue,
                PageRequest.of(page - 1, size, Sort.by("createdAt").descending()));
        return buildPage(result, page, size);
    }

    Booking findBooking(String bookingId) {
        try {
            return bookingRepository.findById(UUID.fromString(bookingId))
                    .orElseThrow(() -> new AppException(ErrorCode.BOOKING_NOT_FOUND));
        } catch (IllegalArgumentException e) { throw new AppException(ErrorCode.ID_INVALID); }
    }

    private Venue findVenue(String venueId) {
        return venueRepository.findById(UUID.fromString(venueId))
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));
    }

    private User findUser(String userId) {
        return userRepository.findById(UUID.fromString(userId))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
    }

    private PageResponse<BookingResponse> buildPage(Page<Booking> page, int pageNum, int size) {
        return PageResponse.<BookingResponse>builder()
                .items(page.getContent().stream().map(bookingMapper::toResponse).toList())
                .total(page.getTotalElements()).page(pageNum).pageSize(size).totalPages(page.getTotalPages())
                .build();
    }
}
```

- [ ] **Step 6: Create BookingController**

`src/main/java/vn/chuongpl/badbook/features/booking/BookingController.java`:
```java
package vn.chuongpl.badbook.features.booking;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.features.booking.dto.request.BookingCreateRequest;
import vn.chuongpl.badbook.features.booking.dto.response.BookingResponse;

@RestController
@RequestMapping("/api/bookings")
@RequiredArgsConstructor
public class BookingController {

    private final BookingService bookingService;

    @PostMapping
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<BookingResponse> createBooking(@AuthenticationPrincipal Jwt jwt,
                                                       @RequestBody BookingCreateRequest request) {
        return ApiResponse.<BookingResponse>builder()
                .data(bookingService.createBooking(jwt.getSubject(), request)).build();
    }

    @PutMapping("/{id}/confirm")
    @PreAuthorize("hasRole('VENUE_MANAGER')")
    public ApiResponse<BookingResponse> confirmBooking(@AuthenticationPrincipal Jwt jwt,
                                                        @PathVariable String id) {
        return ApiResponse.<BookingResponse>builder()
                .data(bookingService.confirmBooking(id, jwt.getSubject())).build();
    }

    @PutMapping("/{id}/cancel")
    public ApiResponse<BookingResponse> cancelBooking(@AuthenticationPrincipal Jwt jwt,
                                                       @PathVariable String id,
                                                       @RequestParam(required = false) String reason) {
        return ApiResponse.<BookingResponse>builder()
                .data(bookingService.cancelBooking(id, jwt.getSubject(), reason)).build();
    }

    @PutMapping("/{id}/complete")
    @PreAuthorize("hasRole('VENUE_MANAGER') or hasRole('ADMIN')")
    public ApiResponse<BookingResponse> completeBooking(@PathVariable String id) {
        return ApiResponse.<BookingResponse>builder()
                .data(bookingService.completeBooking(id)).build();
    }

    @GetMapping("/my")
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<PageResponse<BookingResponse>> getMyBookings(@AuthenticationPrincipal Jwt jwt,
                                                                     @RequestParam(defaultValue = "1") int page,
                                                                     @RequestParam(defaultValue = "10") int size) {
        return ApiResponse.<PageResponse<BookingResponse>>builder()
                .data(bookingService.getUserBookings(jwt.getSubject(), page, size)).build();
    }

    @GetMapping("/venue/{venueId}")
    @PreAuthorize("hasRole('VENUE_MANAGER') or hasRole('ADMIN')")
    public ApiResponse<PageResponse<BookingResponse>> getVenueBookings(@PathVariable String venueId,
                                                                        @RequestParam(defaultValue = "1") int page,
                                                                        @RequestParam(defaultValue = "10") int size) {
        return ApiResponse.<PageResponse<BookingResponse>>builder()
                .data(bookingService.getVenueBookings(venueId, page, size)).build();
    }
}
```

- [ ] **Step 7: Run tests — expect PASS**
```bash
mvn test -Dtest=BookingServiceTest -q 2>&1 | tail -5
```

- [ ] **Step 8: Commit**
```bash
git add src/main/java/vn/chuongpl/badbook/features/booking/
git add src/test/java/vn/chuongpl/badbook/features/booking/
git commit -m "feat: add Booking service with conflict detection and status flow"
```

---

### Task 17: FixedSchedule entity + Flyway V9

**Files:**
- Create: `src/main/resources/db/migration/V9__create_fixed_schedules_table.sql`
- Create: `src/main/java/vn/chuongpl/badbook/features/schedule/FixedSchedule.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/schedule/FixedScheduleRepository.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/schedule/ScheduleService.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/schedule/ScheduleController.java`

- [ ] **Step 1: Create V9 migration**

`src/main/resources/db/migration/V9__create_fixed_schedules_table.sql`:
```sql
CREATE TABLE fixed_schedules (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id),
    court_id    UUID NOT NULL REFERENCES courts(id),
    venue_id    UUID NOT NULL REFERENCES venues(id),
    days_of_week VARCHAR(30) NOT NULL,
    start_time  TIME NOT NULL,
    end_time    TIME NOT NULL,
    start_date  DATE NOT NULL,
    end_date    DATE NOT NULL,
    status      VARCHAR(10) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','CANCELLED')),
    notes       TEXT,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_fixed_schedules_user ON fixed_schedules(user_id);
CREATE INDEX idx_fixed_schedules_court ON fixed_schedules(court_id);
```

- [ ] **Step 2: Create FixedSchedule entity**

`src/main/java/vn/chuongpl/badbook/features/schedule/FixedSchedule.java`:
```java
package vn.chuongpl.badbook.features.schedule;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.features.court.Court;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.venue.Venue;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

@Entity @Table(name = "fixed_schedules")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class FixedSchedule {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false) User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "court_id", nullable = false) Court court;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "venue_id", nullable = false) Venue venue;

    // Stored as comma-separated: "MON,WED,FRI"
    @Column(name = "days_of_week", nullable = false, length = 30) String daysOfWeek;
    @Column(name = "start_time", nullable = false) LocalTime startTime;
    @Column(name = "end_time", nullable = false) LocalTime endTime;
    @Column(name = "start_date", nullable = false) LocalDate startDate;
    @Column(name = "end_date", nullable = false) LocalDate endDate;

    @Column(nullable = false, length = 10) @Builder.Default String status = "ACTIVE";
    @Column(columnDefinition = "TEXT") String notes;

    @Column(name = "created_at", updatable = false) LocalDateTime createdAt;
    @PrePersist void prePersist() { this.createdAt = LocalDateTime.now(); }
}
```

- [ ] **Step 3: Create FixedScheduleRepository**

`src/main/java/vn/chuongpl/badbook/features/schedule/FixedScheduleRepository.java`:
```java
package vn.chuongpl.badbook.features.schedule;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.chuongpl.badbook.features.user.User;

import java.util.List;
import java.util.UUID;

public interface FixedScheduleRepository extends JpaRepository<FixedSchedule, UUID> {
    List<FixedSchedule> findByUserAndStatus(User user, String status);
    List<FixedSchedule> findByStatus(String status);
}
```

- [ ] **Step 4: Create ScheduleService with @Scheduled booking generator**

`src/main/java/vn/chuongpl/badbook/features/schedule/ScheduleService.java`:
```java
package vn.chuongpl.badbook.features.schedule;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.chuongpl.badbook.common.enums.*;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.booking.Booking;
import vn.chuongpl.badbook.features.booking.BookingRepository;
import vn.chuongpl.badbook.features.court.Court;
import vn.chuongpl.badbook.features.court.CourtService;
import vn.chuongpl.badbook.features.schedule.dto.FixedScheduleCreateRequest;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.Venue;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.math.BigDecimal;
import java.time.*;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class ScheduleService {

    FixedScheduleRepository scheduleRepository;
    BookingRepository bookingRepository;
    UserRepository userRepository;
    VenueRepository venueRepository;
    CourtService courtService;

    @Transactional
    public FixedSchedule createSchedule(String userId, FixedScheduleCreateRequest request) {
        User user = userRepository.findById(UUID.fromString(userId))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        Venue venue = venueRepository.findById(UUID.fromString(request.getVenueId()))
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));
        Court court = courtService.findCourt(request.getCourtId());

        if (!court.getVenue().getId().equals(venue.getId()))
            throw new AppException(ErrorCode.COURT_NOT_IN_VENUE);

        FixedSchedule schedule = FixedSchedule.builder()
                .user(user).court(court).venue(venue)
                .daysOfWeek(String.join(",", request.getDaysOfWeek()))
                .startTime(request.getStartTime()).endTime(request.getEndTime())
                .startDate(request.getStartDate()).endDate(request.getEndDate())
                .notes(request.getNotes()).status("ACTIVE").build();
        return scheduleRepository.save(schedule);
    }

    // Runs every Monday at 06:00 to generate next 7-day bookings
    @Scheduled(cron = "0 0 6 * * MON")
    @Transactional
    public void generateWeeklyBookings() {
        log.info("Generating weekly bookings from fixed schedules");
        LocalDate weekStart = LocalDate.now();
        generateBookingsForWeek(weekStart);
    }

    @Transactional
    public void generateBookingsForWeek(LocalDate weekStart) {
        List<FixedSchedule> active = scheduleRepository.findByStatus("ACTIVE");
        LocalDate weekEnd = weekStart.plusDays(6);

        for (FixedSchedule schedule : active) {
            if (schedule.getEndDate().isBefore(weekStart)) continue;

            List<String> days = Arrays.asList(schedule.getDaysOfWeek().split(","));
            for (LocalDate date = weekStart; !date.isAfter(weekEnd); date = date.plusDays(1)) {
                if (!days.contains(date.getDayOfWeek().toString().substring(0, 3))) continue;
                if (date.isBefore(schedule.getStartDate()) || date.isAfter(schedule.getEndDate())) continue;

                boolean conflict = bookingRepository.existsConflict(
                        schedule.getCourt(), date, schedule.getStartTime(), schedule.getEndTime());
                if (conflict) { log.warn("Conflict on {} for schedule {}", date, schedule.getId()); continue; }

                long hours = Duration.between(schedule.getStartTime(), schedule.getEndTime()).toHours();
                BigDecimal total = schedule.getCourt().getPricePerHour().multiply(BigDecimal.valueOf(hours));

                bookingRepository.save(Booking.builder()
                        .user(schedule.getUser()).court(schedule.getCourt()).venue(schedule.getVenue())
                        .bookingDate(date).startTime(schedule.getStartTime()).endTime(schedule.getEndTime())
                        .type(BookingType.FIXED).status(BookingStatus.CONFIRMED)
                        .totalAmount(total).notes("Lịch cố định: " + schedule.getId()).build());
            }
        }
    }

    public List<FixedSchedule> getUserSchedules(String userId) {
        User user = userRepository.findById(UUID.fromString(userId))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        return scheduleRepository.findByUserAndStatus(user, "ACTIVE");
    }

    @Transactional
    public void cancelSchedule(String scheduleId, String userId) {
        FixedSchedule schedule = scheduleRepository.findById(UUID.fromString(scheduleId))
                .orElseThrow(() -> new AppException(ErrorCode.SCHEDULE_NOT_FOUND));
        if (!schedule.getUser().getId().toString().equals(userId))
            throw new AppException(ErrorCode.UNAUTHORIZED);
        schedule.setStatus("CANCELLED");
        scheduleRepository.save(schedule);
    }
}
```

- [ ] **Step 5: Enable @Scheduled in main application class**

Add `@EnableScheduling` to `src/main/java/vn/chuongpl/badbook/BadbookApplication.java`:
```java
package vn.chuongpl.badbook;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class BadbookApplication {
    public static void main(String[] args) {
        SpringApplication.run(BadbookApplication.class, args);
    }
}
```

- [ ] **Step 6: Create FixedScheduleCreateRequest DTO**

`src/main/java/vn/chuongpl/badbook/features/schedule/dto/FixedScheduleCreateRequest.java`:
```java
package vn.chuongpl.badbook.features.schedule.dto;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class FixedScheduleCreateRequest {
    String courtId;
    String venueId;
    List<String> daysOfWeek; // ["MON", "WED", "FRI"]
    LocalTime startTime;
    LocalTime endTime;
    LocalDate startDate;
    LocalDate endDate;
    String notes;
}
```

- [ ] **Step 7: Create ScheduleController**

`src/main/java/vn/chuongpl/badbook/features/schedule/ScheduleController.java`:
```java
package vn.chuongpl.badbook.features.schedule;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.features.schedule.dto.FixedScheduleCreateRequest;

import java.util.List;

@RestController
@RequestMapping("/api/schedules")
@RequiredArgsConstructor
public class ScheduleController {

    private final ScheduleService scheduleService;

    @PostMapping
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<FixedSchedule> createSchedule(@AuthenticationPrincipal Jwt jwt,
                                                      @RequestBody FixedScheduleCreateRequest request) {
        return ApiResponse.<FixedSchedule>builder()
                .data(scheduleService.createSchedule(jwt.getSubject(), request)).build();
    }

    @GetMapping("/my")
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<List<FixedSchedule>> getMySchedules(@AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.<List<FixedSchedule>>builder()
                .data(scheduleService.getUserSchedules(jwt.getSubject())).build();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<Void> cancelSchedule(@AuthenticationPrincipal Jwt jwt, @PathVariable String id) {
        scheduleService.cancelSchedule(id, jwt.getSubject());
        return ApiResponse.<Void>builder().message("Đã hủy lịch cố định").build();
    }
}
```

- [ ] **Step 8: Build verify**
```bash
mvn compile -q && echo "OK"
```

- [ ] **Step 9: Commit**
```bash
git add src/main/resources/db/migration/V9__create_fixed_schedules_table.sql
git add src/main/java/vn/chuongpl/badbook/features/schedule/
git add src/main/java/vn/chuongpl/badbook/BadbookApplication.java
git commit -m "feat: add FixedSchedule with weekly @Scheduled booking generator (V9 migration)"
```

---

### Task 18: Payment + Finance entities + Flyway V10, V11

**Files:**
- Create: `src/main/resources/db/migration/V10__create_payments_table.sql`
- Create: `src/main/resources/db/migration/V11__create_finances_table.sql`
- Create: `src/main/java/vn/chuongpl/badbook/features/payment/Payment.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/payment/PaymentRepository.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/payment/VNPayService.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/payment/PaymentController.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/finance/Finance.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/finance/PlatformFeeInvoice.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/finance/FinanceRepository.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/finance/InvoiceRepository.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/finance/FinanceService.java`
- Create: `src/test/java/vn/chuongpl/badbook/features/finance/FinanceServiceTest.java`

- [ ] **Step 1: Create V10 and V11 migrations**

`src/main/resources/db/migration/V10__create_payments_table.sql`:
```sql
CREATE TABLE payments (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id      UUID NOT NULL REFERENCES bookings(id),
    amount          DECIMAL(14,2) NOT NULL CHECK (amount >= 0),
    method          VARCHAR(10) NOT NULL CHECK (method IN ('VNPAY','CASH')),
    transaction_id  VARCHAR(255),
    status          VARCHAR(10) NOT NULL DEFAULT 'PENDING'
                        CHECK (status IN ('PENDING','SUCCESS','FAILED','REFUNDED')),
    paid_at         TIMESTAMP
);

CREATE INDEX idx_payments_booking ON payments(booking_id);
```

`src/main/resources/db/migration/V11__create_finances_table.sql`:
```sql
CREATE TABLE finances (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id          UUID NOT NULL UNIQUE REFERENCES bookings(id),
    total_amount        DECIMAL(14,2) NOT NULL,
    platform_fee_amount DECIMAL(14,2) NOT NULL,
    venue_revenue       DECIMAL(14,2) NOT NULL,
    status              VARCHAR(10) NOT NULL DEFAULT 'PENDING'
                            CHECK (status IN ('PENDING','COMPLETED','FAILED'))
);

CREATE TABLE platform_fee_invoices (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venue_id        UUID NOT NULL REFERENCES venues(id),
    period          CHAR(7) NOT NULL,
    total_bookings  INT NOT NULL DEFAULT 0,
    total_revenue   DECIMAL(14,2) NOT NULL DEFAULT 0,
    fee_amount      DECIMAL(14,2) NOT NULL DEFAULT 0,
    status          VARCHAR(10) NOT NULL DEFAULT 'PENDING'
                        CHECK (status IN ('PENDING','PAID','OVERDUE')),
    due_date        DATE NOT NULL,
    paid_at         TIMESTAMP,
    UNIQUE (venue_id, period)
);

CREATE INDEX idx_finances_booking ON finances(booking_id);
CREATE INDEX idx_invoices_venue ON platform_fee_invoices(venue_id);
```

- [ ] **Step 2: Create Payment entity**

`src/main/java/vn/chuongpl/badbook/features/payment/Payment.java`:
```java
package vn.chuongpl.badbook.features.payment;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.PaymentMethod;
import vn.chuongpl.badbook.common.enums.PaymentStatus;
import vn.chuongpl.badbook.features.booking.Booking;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity @Table(name = "payments")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Payment {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", nullable = false) Booking booking;

    @Column(nullable = false, precision = 14, scale = 2) BigDecimal amount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10) PaymentMethod method;

    @Column(name = "transaction_id") String transactionId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    @Builder.Default PaymentStatus status = PaymentStatus.PENDING;

    @Column(name = "paid_at") LocalDateTime paidAt;
}
```

- [ ] **Step 3: Create Finance and PlatformFeeInvoice entities**

`src/main/java/vn/chuongpl/badbook/features/finance/Finance.java`:
```java
package vn.chuongpl.badbook.features.finance;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.features.booking.Booking;

import java.math.BigDecimal;
import java.util.UUID;

@Entity @Table(name = "finances")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Finance {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", nullable = false, unique = true) Booking booking;

    @Column(name = "total_amount", nullable = false, precision = 14, scale = 2) BigDecimal totalAmount;
    @Column(name = "platform_fee_amount", nullable = false, precision = 14, scale = 2) BigDecimal platformFeeAmount;
    @Column(name = "venue_revenue", nullable = false, precision = 14, scale = 2) BigDecimal venueRevenue;

    @Column(nullable = false, length = 10) @Builder.Default String status = "PENDING";
}
```

`src/main/java/vn/chuongpl/badbook/features/finance/PlatformFeeInvoice.java`:
```java
package vn.chuongpl.badbook.features.finance;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.PlatformFeeStatus;
import vn.chuongpl.badbook.features.venue.Venue;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity @Table(name = "platform_fee_invoices")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class PlatformFeeInvoice {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "venue_id", nullable = false) Venue venue;

    @Column(nullable = false, length = 7) String period; // "2026-06"
    @Column(name = "total_bookings") int totalBookings;
    @Column(name = "total_revenue", precision = 14, scale = 2) BigDecimal totalRevenue;
    @Column(name = "fee_amount", precision = 14, scale = 2) BigDecimal feeAmount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    @Builder.Default PlatformFeeStatus status = PlatformFeeStatus.PENDING;

    @Column(name = "due_date", nullable = false) LocalDate dueDate;
    @Column(name = "paid_at") LocalDateTime paidAt;
}
```

- [ ] **Step 4: Create repositories**

`src/main/java/vn/chuongpl/badbook/features/payment/PaymentRepository.java`:
```java
package vn.chuongpl.badbook.features.payment;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.chuongpl.badbook.features.booking.Booking;

import java.util.Optional;
import java.util.UUID;

public interface PaymentRepository extends JpaRepository<Payment, UUID> {
    Optional<Payment> findByBooking(Booking booking);
}
```

`src/main/java/vn/chuongpl/badbook/features/finance/FinanceRepository.java`:
```java
package vn.chuongpl.badbook.features.finance;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.chuongpl.badbook.features.venue.Venue;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface FinanceRepository extends JpaRepository<Finance, UUID> {
    Optional<Finance> findByBookingId(UUID bookingId);

    @Query("""
        SELECT f FROM Finance f
        WHERE f.booking.venue = :venue
        AND FUNCTION('TO_CHAR', CAST(f.booking.createdAt AS date), 'YYYY-MM') = :period
    """)
    List<Finance> findByVenueAndPeriod(@Param("venue") Venue venue, @Param("period") String period);
}
```

`src/main/java/vn/chuongpl/badbook/features/finance/InvoiceRepository.java`:
```java
package vn.chuongpl.badbook.features.finance;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.chuongpl.badbook.common.enums.PlatformFeeStatus;
import vn.chuongpl.badbook.features.venue.Venue;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface InvoiceRepository extends JpaRepository<PlatformFeeInvoice, UUID> {
    Optional<PlatformFeeInvoice> findByVenueAndPeriod(Venue venue, String period);
    List<PlatformFeeInvoice> findByStatus(PlatformFeeStatus status);
    List<PlatformFeeInvoice> findByVenue(Venue venue);
}
```

- [ ] **Step 5: Write failing test**

`src/test/java/vn/chuongpl/badbook/features/finance/FinanceServiceTest.java`:
```java
package vn.chuongpl.badbook.features.finance;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import vn.chuongpl.badbook.features.booking.Booking;
import vn.chuongpl.badbook.features.venue.Venue;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class FinanceServiceTest {

    @Mock FinanceRepository financeRepository;
    @Mock InvoiceRepository invoiceRepository;
    @InjectMocks FinanceService financeService;

    @Test
    void createFinanceRecord_splitsPlatformFeeCorrectly() {
        Venue venue = Venue.builder().id(UUID.randomUUID())
                .platformFeeRate(new BigDecimal("0.10")).build();
        Booking booking = Booking.builder().id(UUID.randomUUID())
                .venue(venue).totalAmount(new BigDecimal("200000")).build();

        when(financeRepository.findByBookingId(booking.getId())).thenReturn(Optional.empty());
        when(financeRepository.save(any())).thenAnswer(i -> i.getArgument(0));

        Finance result = financeService.createFinanceRecord(booking);

        assertThat(result.getPlatformFeeAmount()).isEqualByComparingTo(new BigDecimal("20000.00"));
        assertThat(result.getVenueRevenue()).isEqualByComparingTo(new BigDecimal("180000.00"));
        assertThat(result.getTotalAmount()).isEqualByComparingTo(new BigDecimal("200000"));
    }
}
```

- [ ] **Step 6: Run test — expect FAIL**
```bash
mvn test -Dtest=FinanceServiceTest -q 2>&1 | tail -5
```

- [ ] **Step 7: Create FinanceService**

`src/main/java/vn/chuongpl/badbook/features/finance/FinanceService.java`:
```java
package vn.chuongpl.badbook.features.finance;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.enums.PlatformFeeStatus;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.booking.Booking;
import vn.chuongpl.badbook.features.venue.Venue;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class FinanceService {

    FinanceRepository financeRepository;
    InvoiceRepository invoiceRepository;
    VenueRepository venueRepository;

    @Transactional
    public Finance createFinanceRecord(Booking booking) {
        if (financeRepository.findByBookingId(booking.getId()).isPresent()) {
            log.warn("Finance record already exists for booking {}", booking.getId());
            return financeRepository.findByBookingId(booking.getId()).get();
        }
        BigDecimal total = booking.getTotalAmount();
        BigDecimal feeRate = booking.getVenue().getPlatformFeeRate();
        BigDecimal platformFee = total.multiply(feeRate).setScale(2, RoundingMode.HALF_UP);
        BigDecimal venueRevenue = total.subtract(platformFee);

        return financeRepository.save(Finance.builder()
                .booking(booking).totalAmount(total)
                .platformFeeAmount(platformFee).venueRevenue(venueRevenue)
                .status("COMPLETED").build());
    }

    @Transactional
    public PlatformFeeInvoice generateMonthlyInvoice(String venueId, String period) {
        Venue venue = venueRepository.findById(UUID.fromString(venueId))
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));

        if (invoiceRepository.findByVenueAndPeriod(venue, period).isPresent()) {
            throw new AppException(ErrorCode.PLATFORM_FEE_ALREADY_PAID);
        }

        List<Finance> records = financeRepository.findByVenueAndPeriod(venue, period);
        BigDecimal totalRevenue = records.stream().map(Finance::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal totalFee = records.stream().map(Finance::getPlatformFeeAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        YearMonth ym = YearMonth.parse(period);
        LocalDate dueDate = ym.plusMonths(1).atDay(15);

        return invoiceRepository.save(PlatformFeeInvoice.builder()
                .venue(venue).period(period)
                .totalBookings(records.size()).totalRevenue(totalRevenue)
                .feeAmount(totalFee).status(PlatformFeeStatus.PENDING).dueDate(dueDate).build());
    }

    @Transactional
    public PlatformFeeInvoice markInvoicePaid(String invoiceId) {
        PlatformFeeInvoice invoice = invoiceRepository.findById(UUID.fromString(invoiceId))
                .orElseThrow(() -> new AppException(ErrorCode.INVOICE_NOT_FOUND));
        if (invoice.getStatus() == PlatformFeeStatus.PAID)
            throw new AppException(ErrorCode.PLATFORM_FEE_ALREADY_PAID);
        invoice.setStatus(PlatformFeeStatus.PAID);
        invoice.setPaidAt(java.time.LocalDateTime.now());
        return invoiceRepository.save(invoice);
    }

    public List<PlatformFeeInvoice> getVenueInvoices(String venueId) {
        Venue venue = venueRepository.findById(UUID.fromString(venueId))
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));
        return invoiceRepository.findByVenue(venue);
    }

    public List<PlatformFeeInvoice> getPendingInvoices() {
        return invoiceRepository.findByStatus(PlatformFeeStatus.PENDING);
    }
}
```

- [ ] **Step 8: Wire Finance creation into BookingService.completeBooking**

In `src/main/java/vn/chuongpl/badbook/features/booking/BookingService.java`, add `FinanceService` field and call in `completeBooking`:
```java
// Add field (add to constructor via @RequiredArgsConstructor):
private final FinanceService financeService;

// Update completeBooking method:
@Transactional
public BookingResponse completeBooking(String bookingId) {
    Booking booking = findBooking(bookingId);
    if (booking.getStatus() != BookingStatus.CONFIRMED && booking.getStatus() != BookingStatus.IN_PROGRESS)
        throw new AppException(ErrorCode.BOOKING_CANNOT_CANCEL);
    booking.setStatus(BookingStatus.COMPLETED);
    Booking saved = bookingRepository.save(booking);
    financeService.createFinanceRecord(saved);  // auto-create finance record
    return bookingMapper.toResponse(saved);
}
```

- [ ] **Step 9: Create VNPayService (payment initiation)**

`src/main/java/vn/chuongpl/badbook/features/payment/VNPayService.java`:
```java
package vn.chuongpl.badbook.features.payment;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.chuongpl.badbook.common.enums.BookingStatus;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.enums.PaymentMethod;
import vn.chuongpl.badbook.common.enums.PaymentStatus;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.booking.Booking;
import vn.chuongpl.badbook.features.booking.BookingRepository;
import vn.chuongpl.badbook.features.booking.BookingService;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class VNPayService {

    PaymentRepository paymentRepository;
    BookingRepository bookingRepository;
    BookingService bookingService;

    @Value("${vnpay.tmnCode:TESTCODE}") String tmnCode;
    @Value("${vnpay.secretKey:testsecretkey12345678901234567890}") String secretKey;
    @Value("${vnpay.payUrl}") String payUrl;
    @Value("${vnpay.returnUrl}") String returnUrl;

    public String createPaymentUrl(String bookingId, String ipAddress) {
        Booking booking = bookingService.findBooking(bookingId);
        if (booking.getStatus() != BookingStatus.PENDING)
            throw new AppException(ErrorCode.PAYMENT_ALREADY_PROCESSED);

        long amount = booking.getTotalAmount().longValue() * 100; // VNPay requires * 100
        String txnRef = bookingId.replace("-", "").substring(0, 16);
        String createDate = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());

        Map<String, String> params = new TreeMap<>();
        params.put("vnp_Version", "2.1.0");
        params.put("vnp_Command", "pay");
        params.put("vnp_TmnCode", tmnCode);
        params.put("vnp_Amount", String.valueOf(amount));
        params.put("vnp_CurrCode", "VND");
        params.put("vnp_TxnRef", txnRef);
        params.put("vnp_OrderInfo", "Thanh toan dat san " + bookingId);
        params.put("vnp_OrderType", "other");
        params.put("vnp_Locale", "vn");
        params.put("vnp_ReturnUrl", returnUrl + "?bookingId=" + bookingId);
        params.put("vnp_IpAddr", ipAddress);
        params.put("vnp_CreateDate", createDate);

        StringBuilder query = new StringBuilder();
        StringBuilder hashData = new StringBuilder();
        for (Map.Entry<String, String> e : params.entrySet()) {
            String enc = URLEncoder.encode(e.getValue(), StandardCharsets.US_ASCII);
            query.append(URLEncoder.encode(e.getKey(), StandardCharsets.US_ASCII)).append("=").append(enc).append("&");
            hashData.append(e.getKey()).append("=").append(e.getValue()).append("&");
        }
        String hash = hmacSHA512(secretKey, hashData.substring(0, hashData.length() - 1));
        return payUrl + "?" + query + "vnp_SecureHash=" + hash;
    }

    @Transactional
    public Payment handleCallback(String bookingId, String transactionId, String responseCode) {
        Booking booking = bookingService.findBooking(bookingId);
        if (paymentRepository.findByBooking(booking).isPresent())
            throw new AppException(ErrorCode.PAYMENT_ALREADY_PROCESSED);

        boolean success = "00".equals(responseCode);
        Payment payment = paymentRepository.save(Payment.builder()
                .booking(booking).amount(booking.getTotalAmount())
                .method(PaymentMethod.VNPAY).transactionId(transactionId)
                .status(success ? PaymentStatus.SUCCESS : PaymentStatus.FAILED)
                .paidAt(success ? java.time.LocalDateTime.now() : null).build());

        if (success) {
            booking.setStatus(BookingStatus.CONFIRMED);
            bookingRepository.save(booking);
        }
        return payment;
    }

    private String hmacSHA512(String key, String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA512");
            mac.init(new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512"));
            byte[] bytes = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) { throw new RuntimeException(e); }
    }
}
```

- [ ] **Step 10: Add VNPay keys to application.yaml**

Add to `src/main/resources/application.yaml`:
```yaml
vnpay:
  payUrl: "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html"
  returnUrl: "${APP_URL:http://localhost:8080}/badbook/api/payments/vnpay-callback"
  tmnCode: ${VNPAY_TMN_CODE:TESTCODE}
  secretKey: ${VNPAY_SECRET_KEY:testsecretkey12345678901234567890}
```

- [ ] **Step 11: Create PaymentController**

`src/main/java/vn/chuongpl/badbook/features/payment/PaymentController.java`:
```java
package vn.chuongpl.badbook.features.payment;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final VNPayService vnPayService;

    @PostMapping("/vnpay/create")
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<String> createPayment(@RequestParam String bookingId,
                                              HttpServletRequest request) {
        String ip = request.getRemoteAddr();
        return ApiResponse.<String>builder()
                .data(vnPayService.createPaymentUrl(bookingId, ip)).build();
    }

    @GetMapping("/vnpay-callback")
    public ApiResponse<Payment> vnpayCallback(@RequestParam String bookingId,
                                               @RequestParam String vnp_TxnRef,
                                               @RequestParam String vnp_ResponseCode) {
        return ApiResponse.<Payment>builder()
                .data(vnPayService.handleCallback(bookingId, vnp_TxnRef, vnp_ResponseCode)).build();
    }
}
```

- [ ] **Step 12: Run tests — expect PASS**
```bash
mvn test -Dtest=FinanceServiceTest -q 2>&1 | tail -5
```

- [ ] **Step 13: Full test suite**
```bash
mvn test -q 2>&1 | tail -10
```
Expected: BUILD SUCCESS

- [ ] **Step 14: Commit Phase 3**
```bash
git add src/main/resources/db/migration/V10__create_payments_table.sql
git add src/main/resources/db/migration/V11__create_finances_table.sql
git add src/main/java/vn/chuongpl/badbook/features/payment/
git add src/main/java/vn/chuongpl/badbook/features/finance/
git add src/main/java/vn/chuongpl/badbook/features/booking/BookingService.java
git add src/main/resources/application.yaml
git add src/test/java/vn/chuongpl/badbook/features/finance/
git commit -m "feat: add Payment (VNPay) and Finance auto-calculation on booking completion (V10, V11)"
git tag phase-3-complete
```

---

## PHASE 4 — Extended Services

### Task 19: Review entity + Flyway V12

**Files:**
- Create: `src/main/resources/db/migration/V12__create_reviews_table.sql`
- Create: `src/main/java/vn/chuongpl/badbook/common/enums/ReviewTarget.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/review/Review.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/review/ReviewRepository.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/review/dto/ReviewCreateRequest.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/review/dto/ReviewResponse.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/review/ReviewService.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/review/ReviewController.java`
- Create: `src/test/java/vn/chuongpl/badbook/features/review/ReviewServiceTest.java`

- [ ] **Step 1: Create ReviewTarget enum and V12 migration**

`src/main/java/vn/chuongpl/badbook/common/enums/ReviewTarget.java`:
```java
package vn.chuongpl.badbook.common.enums;

public enum ReviewTarget {
    VENUE, COURT
}
```

`src/main/resources/db/migration/V12__create_reviews_table.sql`:
```sql
CREATE TABLE reviews (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id),
    booking_id  UUID NOT NULL REFERENCES bookings(id),
    target_type VARCHAR(10) NOT NULL CHECK (target_type IN ('VENUE','COURT')),
    target_id   UUID NOT NULL,
    rating      INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    content     TEXT,
    reply_text  TEXT,
    reply_at    TIMESTAMP,
    is_deleted  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, booking_id, target_type)
);

CREATE INDEX idx_reviews_target ON reviews(target_type, target_id);
CREATE INDEX idx_reviews_booking ON reviews(booking_id);
```

- [ ] **Step 2: Create Review entity**

`src/main/java/vn/chuongpl/badbook/features/review/Review.java`:
```java
package vn.chuongpl.badbook.features.review;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.ReviewTarget;
import vn.chuongpl.badbook.features.booking.Booking;
import vn.chuongpl.badbook.features.user.User;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity @Table(name = "reviews")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Review {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false) User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", nullable = false) Booking booking;

    @Enumerated(EnumType.STRING)
    @Column(name = "target_type", nullable = false, length = 10) ReviewTarget targetType;

    @Column(name = "target_id", nullable = false, columnDefinition = "uuid") UUID targetId;

    @Column(nullable = false) int rating;
    @Column(columnDefinition = "TEXT") String content;
    @Column(name = "reply_text", columnDefinition = "TEXT") String replyText;
    @Column(name = "reply_at") LocalDateTime replyAt;
    @Column(name = "is_deleted") @Builder.Default boolean deleted = false;

    @Column(name = "created_at", updatable = false) LocalDateTime createdAt;
    @PrePersist void prePersist() { this.createdAt = LocalDateTime.now(); }
}
```

- [ ] **Step 3: Create ReviewRepository**

`src/main/java/vn/chuongpl/badbook/features/review/ReviewRepository.java`:
```java
package vn.chuongpl.badbook.features.review;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import vn.chuongpl.badbook.common.enums.ReviewTarget;
import vn.chuongpl.badbook.features.booking.Booking;
import vn.chuongpl.badbook.features.user.User;

import java.util.Optional;
import java.util.UUID;

public interface ReviewRepository extends JpaRepository<Review, UUID> {
    boolean existsByUserAndBookingAndTargetType(User user, Booking booking, ReviewTarget targetType);
    Page<Review> findByTargetTypeAndTargetIdAndDeletedFalse(ReviewTarget type, UUID targetId, Pageable pageable);
    Optional<Review> findByIdAndDeletedFalse(UUID id);
}
```

- [ ] **Step 4: Write failing test**

`src/test/java/vn/chuongpl/badbook/features/review/ReviewServiceTest.java`:
```java
package vn.chuongpl.badbook.features.review;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import vn.chuongpl.badbook.common.enums.BookingStatus;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.enums.ReviewTarget;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.booking.Booking;
import vn.chuongpl.badbook.features.booking.BookingRepository;
import vn.chuongpl.badbook.features.review.dto.ReviewCreateRequest;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ReviewServiceTest {

    @Mock ReviewRepository reviewRepository;
    @Mock BookingRepository bookingRepository;
    @Mock UserRepository userRepository;
    @InjectMocks ReviewService reviewService;

    @Test
    void createReview_throwsWhenBookingNotCompleted() {
        UUID userId = UUID.randomUUID(), bookingId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        Booking booking = Booking.builder().id(bookingId).user(user).status(BookingStatus.CONFIRMED).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(bookingRepository.findById(bookingId)).thenReturn(Optional.of(booking));

        ReviewCreateRequest req = ReviewCreateRequest.builder()
                .bookingId(bookingId.toString()).targetType(ReviewTarget.VENUE)
                .targetId(UUID.randomUUID().toString()).rating(5).content("Tốt").build();

        assertThatThrownBy(() -> reviewService.createReview(userId.toString(), req))
                .isInstanceOf(AppException.class)
                .extracting(e -> ((AppException) e).getErrorCode())
                .isEqualTo(ErrorCode.REVIEW_ONLY_AFTER_COMPLETION);
    }

    @Test
    void createReview_throwsWhenAlreadyReviewed() {
        UUID userId = UUID.randomUUID(), bookingId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        Booking booking = Booking.builder().id(bookingId).user(user).status(BookingStatus.COMPLETED).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(bookingRepository.findById(bookingId)).thenReturn(Optional.of(booking));
        when(reviewRepository.existsByUserAndBookingAndTargetType(any(), any(), any())).thenReturn(true);

        ReviewCreateRequest req = ReviewCreateRequest.builder()
                .bookingId(bookingId.toString()).targetType(ReviewTarget.VENUE)
                .targetId(UUID.randomUUID().toString()).rating(5).content("Tốt").build();

        assertThatThrownBy(() -> reviewService.createReview(userId.toString(), req))
                .isInstanceOf(AppException.class)
                .extracting(e -> ((AppException) e).getErrorCode())
                .isEqualTo(ErrorCode.REVIEW_ALREADY_SUBMITTED);
    }

    @Test
    void createReview_successAfterCompletedBooking() {
        UUID userId = UUID.randomUUID(), bookingId = UUID.randomUUID(), targetId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        Booking booking = Booking.builder().id(bookingId).user(user).status(BookingStatus.COMPLETED).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(bookingRepository.findById(bookingId)).thenReturn(Optional.of(booking));
        when(reviewRepository.existsByUserAndBookingAndTargetType(any(), any(), any())).thenReturn(false);
        when(reviewRepository.save(any())).thenAnswer(i -> {
            Review r = i.getArgument(0);
            r.setId(UUID.randomUUID());
            return r;
        });

        ReviewCreateRequest req = ReviewCreateRequest.builder()
                .bookingId(bookingId.toString()).targetType(ReviewTarget.VENUE)
                .targetId(targetId.toString()).rating(5).content("Rất tốt!").build();

        Review result = reviewService.createReview(userId.toString(), req);
        assertThat(result.getRating()).isEqualTo(5);
        assertThat(result.getContent()).isEqualTo("Rất tốt!");
    }
}
```

- [ ] **Step 5: Run test — expect FAIL**
```bash
mvn test -Dtest=ReviewServiceTest -q 2>&1 | tail -5
```

- [ ] **Step 6: Create DTOs and ReviewService**

`src/main/java/vn/chuongpl/badbook/features/review/dto/ReviewCreateRequest.java`:
```java
package vn.chuongpl.badbook.features.review.dto;

import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.ReviewTarget;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ReviewCreateRequest {
    String bookingId;
    ReviewTarget targetType;
    String targetId;
    int rating;
    String content;
}
```

`src/main/java/vn/chuongpl/badbook/features/review/ReviewService.java`:
```java
package vn.chuongpl.badbook.features.review;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.common.enums.BookingStatus;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.enums.ReviewTarget;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.booking.Booking;
import vn.chuongpl.badbook.features.booking.BookingRepository;
import vn.chuongpl.badbook.features.review.dto.ReviewCreateRequest;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class ReviewService {

    ReviewRepository reviewRepository;
    BookingRepository bookingRepository;
    UserRepository userRepository;

    @Transactional
    public Review createReview(String userId, ReviewCreateRequest request) {
        User user = userRepository.findById(UUID.fromString(userId))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        Booking booking = bookingRepository.findById(UUID.fromString(request.getBookingId()))
                .orElseThrow(() -> new AppException(ErrorCode.BOOKING_NOT_FOUND));

        if (!booking.getUser().getId().equals(user.getId()))
            throw new AppException(ErrorCode.UNAUTHORIZED);
        if (booking.getStatus() != BookingStatus.COMPLETED)
            throw new AppException(ErrorCode.REVIEW_ONLY_AFTER_COMPLETION);
        if (reviewRepository.existsByUserAndBookingAndTargetType(user, booking, request.getTargetType()))
            throw new AppException(ErrorCode.REVIEW_ALREADY_SUBMITTED);

        return reviewRepository.save(Review.builder()
                .user(user).booking(booking)
                .targetType(request.getTargetType())
                .targetId(UUID.fromString(request.getTargetId()))
                .rating(request.getRating()).content(request.getContent()).build());
    }

    @Transactional
    public Review replyToReview(String reviewId, String venueManagerId, String replyText) {
        Review review = reviewRepository.findByIdAndDeletedFalse(UUID.fromString(reviewId))
                .orElseThrow(() -> new AppException(ErrorCode.REVIEW_NOT_FOUND));
        if (review.getReplyText() != null) throw new AppException(ErrorCode.REVIEW_ALREADY_REPLIED);
        review.setReplyText(replyText);
        review.setReplyAt(LocalDateTime.now());
        return reviewRepository.save(review);
    }

    @Transactional
    public void deleteReview(String reviewId) {
        Review review = reviewRepository.findByIdAndDeletedFalse(UUID.fromString(reviewId))
                .orElseThrow(() -> new AppException(ErrorCode.REVIEW_NOT_FOUND));
        review.setDeleted(true);
        reviewRepository.save(review);
    }

    public PageResponse<Review> getReviews(ReviewTarget targetType, String targetId, int page, int size) {
        Page<Review> result = reviewRepository.findByTargetTypeAndTargetIdAndDeletedFalse(
                targetType, UUID.fromString(targetId),
                PageRequest.of(page - 1, size, Sort.by("createdAt").descending()));
        return PageResponse.<Review>builder()
                .items(result.getContent()).total(result.getTotalElements())
                .page(page).pageSize(size).totalPages(result.getTotalPages()).build();
    }
}
```

- [ ] **Step 7: Create ReviewController**

`src/main/java/vn/chuongpl/badbook/features/review/ReviewController.java`:
```java
package vn.chuongpl.badbook.features.review;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.common.enums.ReviewTarget;
import vn.chuongpl.badbook.features.review.dto.ReviewCreateRequest;

@RestController
@RequestMapping("/api/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    @PostMapping
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<Review> createReview(@AuthenticationPrincipal Jwt jwt,
                                             @RequestBody ReviewCreateRequest request) {
        return ApiResponse.<Review>builder()
                .data(reviewService.createReview(jwt.getSubject(), request)).build();
    }

    @PutMapping("/{id}/reply")
    @PreAuthorize("hasRole('VENUE_MANAGER')")
    public ApiResponse<Review> reply(@AuthenticationPrincipal Jwt jwt,
                                      @PathVariable String id,
                                      @RequestParam String replyText) {
        return ApiResponse.<Review>builder()
                .data(reviewService.replyToReview(id, jwt.getSubject(), replyText)).build();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Void> deleteReview(@PathVariable String id) {
        reviewService.deleteReview(id);
        return ApiResponse.<Void>builder().message("Đã xóa đánh giá").build();
    }

    @GetMapping
    public ApiResponse<PageResponse<Review>> getReviews(
            @RequestParam ReviewTarget targetType,
            @RequestParam String targetId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ApiResponse.<PageResponse<Review>>builder()
                .data(reviewService.getReviews(targetType, targetId, page, size)).build();
    }
}
```

- [ ] **Step 8: Run tests — expect PASS**
```bash
mvn test -Dtest=ReviewServiceTest -q 2>&1 | tail -5
```

- [ ] **Step 9: Commit**
```bash
git add src/main/resources/db/migration/V12__create_reviews_table.sql
git add src/main/java/vn/chuongpl/badbook/common/enums/ReviewTarget.java
git add src/main/java/vn/chuongpl/badbook/features/review/
git add src/test/java/vn/chuongpl/badbook/features/review/
git commit -m "feat: add Review system — post-completion only, venue reply, admin delete (V12)"
```

---

### Task 20: SearchHistory + Flyway V13 + Venue search

**Files:**
- Create: `src/main/resources/db/migration/V13__create_search_history_table.sql`
- Create: `src/main/java/vn/chuongpl/badbook/features/search/SearchHistory.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/search/SearchHistoryRepository.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/search/SearchService.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/search/SearchController.java`

- [ ] **Step 1: Create V13 migration**

`src/main/resources/db/migration/V13__create_search_history_table.sql`:
```sql
CREATE TABLE search_history (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID REFERENCES users(id) ON DELETE SET NULL,
    keyword         VARCHAR(255) NOT NULL,
    count           INT NOT NULL DEFAULT 1,
    last_searched_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_search_history_keyword ON search_history(keyword);
CREATE UNIQUE INDEX idx_search_history_user_keyword ON search_history(user_id, keyword)
    WHERE user_id IS NOT NULL;
```

- [ ] **Step 2: Create SearchHistory entity**

`src/main/java/vn/chuongpl/badbook/features/search/SearchHistory.java`:
```java
package vn.chuongpl.badbook.features.search;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.features.user.User;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity @Table(name = "search_history")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class SearchHistory {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id") User user;

    @Column(nullable = false) String keyword;
    @Column(nullable = false) @Builder.Default int count = 1;

    @Column(name = "last_searched_at", nullable = false)
    @Builder.Default LocalDateTime lastSearchedAt = LocalDateTime.now();
}
```

- [ ] **Step 3: Create SearchHistoryRepository**

`src/main/java/vn/chuongpl/badbook/features/search/SearchHistoryRepository.java`:
```java
package vn.chuongpl.badbook.features.search;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import vn.chuongpl.badbook.features.user.User;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface SearchHistoryRepository extends JpaRepository<SearchHistory, UUID> {
    Optional<SearchHistory> findByUserAndKeyword(User user, String keyword);

    @Query("SELECT s FROM SearchHistory s ORDER BY s.count DESC")
    List<SearchHistory> findHotKeywords(Pageable pageable);

    List<SearchHistory> findByUserOrderByLastSearchedAtDesc(User user);
}
```

- [ ] **Step 4: Create SearchService**

`src/main/java/vn/chuongpl/badbook/features/search/SearchService.java`:
```java
package vn.chuongpl.badbook.features.search;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.common.enums.VenueStatus;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.Venue;
import vn.chuongpl.badbook.features.venue.VenueRepository;
import vn.chuongpl.badbook.features.venue.dto.response.VenueResponse;
import vn.chuongpl.badbook.features.venue.VenueMapper;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class SearchService {

    SearchHistoryRepository searchHistoryRepository;
    VenueRepository venueRepository;
    UserRepository userRepository;
    VenueMapper venueMapper;

    @Transactional
    public PageResponse<VenueResponse> searchVenues(String keyword, String userId, int page, int size) {
        if (keyword != null && !keyword.isBlank()) {
            saveSearchHistory(keyword, userId);
        }
        var pageable = PageRequest.of(page - 1, size);
        var result = (keyword != null && !keyword.isBlank())
                ? venueRepository.findByNameContainingIgnoreCaseAndStatus(keyword, VenueStatus.ACTIVE, pageable)
                : venueRepository.findByStatus(VenueStatus.ACTIVE, pageable);

        return PageResponse.<VenueResponse>builder()
                .items(result.getContent().stream().map(venueMapper::toResponse).toList())
                .total(result.getTotalElements()).page(page).pageSize(size).totalPages(result.getTotalPages())
                .build();
    }

    public List<String> getHotKeywords(int limit) {
        return searchHistoryRepository.findHotKeywords(PageRequest.of(0, limit))
                .stream().map(SearchHistory::getKeyword).toList();
    }

    public List<String> getUserSearchHistory(String userId) {
        Optional<User> user = userRepository.findById(UUID.fromString(userId));
        if (user.isEmpty()) return List.of();
        return searchHistoryRepository.findByUserOrderByLastSearchedAtDesc(user.get())
                .stream().map(SearchHistory::getKeyword).toList();
    }

    private void saveSearchHistory(String keyword, String userId) {
        User user = (userId != null)
                ? userRepository.findById(UUID.fromString(userId)).orElse(null) : null;

        if (user != null) {
            searchHistoryRepository.findByUserAndKeyword(user, keyword).ifPresentOrElse(
                    h -> { h.setCount(h.getCount() + 1); h.setLastSearchedAt(LocalDateTime.now());
                           searchHistoryRepository.save(h); },
                    () -> searchHistoryRepository.save(
                            SearchHistory.builder().user(user).keyword(keyword).build()));
        }
    }
}
```

- [ ] **Step 5: Create SearchController**

`src/main/java/vn/chuongpl/badbook/features/search/SearchController.java`:
```java
package vn.chuongpl.badbook.features.search;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.features.venue.dto.response.VenueResponse;

import java.util.List;

@RestController
@RequestMapping("/api/search")
@RequiredArgsConstructor
public class SearchController {

    private final SearchService searchService;

    @GetMapping
    public ApiResponse<PageResponse<VenueResponse>> search(
            @RequestParam(required = false) String keyword,
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        String userId = jwt != null ? jwt.getSubject() : null;
        return ApiResponse.<PageResponse<VenueResponse>>builder()
                .data(searchService.searchVenues(keyword, userId, page, size)).build();
    }

    @GetMapping("/hot")
    public ApiResponse<List<String>> getHotKeywords(@RequestParam(defaultValue = "10") int limit) {
        return ApiResponse.<List<String>>builder()
                .data(searchService.getHotKeywords(limit)).build();
    }

    @GetMapping("/history")
    public ApiResponse<List<String>> getMyHistory(@AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.<List<String>>builder()
                .data(searchService.getUserSearchHistory(jwt.getSubject())).build();
    }
}
```

- [ ] **Step 6: Commit**
```bash
git add src/main/resources/db/migration/V13__create_search_history_table.sql
git add src/main/java/vn/chuongpl/badbook/features/search/
git commit -m "feat: add Venue search with keyword history tracking (V13 migration)"
```

---

### Task 21: Admin dashboard API

**Files:**
- Create: `src/main/java/vn/chuongpl/badbook/features/admin/AdminService.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/admin/AdminController.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/admin/dto/SystemStatsResponse.java`

- [ ] **Step 1: Create SystemStatsResponse DTO**

`src/main/java/vn/chuongpl/badbook/features/admin/dto/SystemStatsResponse.java`:
```java
package vn.chuongpl.badbook.features.admin.dto;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.math.BigDecimal;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class SystemStatsResponse {
    long totalUsers;
    long totalVenues;
    long activeVenues;
    long pendingVenues;
    long totalBookings;
    long completedBookings;
    BigDecimal totalPlatformRevenue;
    long pendingInvoices;
}
```

- [ ] **Step 2: Create AdminService**

`src/main/java/vn/chuongpl/badbook/features/admin/AdminService.java`:
```java
package vn.chuongpl.badbook.features.admin;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.stereotype.Service;
import vn.chuongpl.badbook.common.enums.BookingStatus;
import vn.chuongpl.badbook.common.enums.PlatformFeeStatus;
import vn.chuongpl.badbook.common.enums.VenueStatus;
import vn.chuongpl.badbook.features.admin.dto.SystemStatsResponse;
import vn.chuongpl.badbook.features.booking.BookingRepository;
import vn.chuongpl.badbook.features.finance.Finance;
import vn.chuongpl.badbook.features.finance.FinanceRepository;
import vn.chuongpl.badbook.features.finance.FinanceService;
import vn.chuongpl.badbook.features.finance.InvoiceRepository;
import vn.chuongpl.badbook.features.finance.PlatformFeeInvoice;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AdminService {

    UserRepository userRepository;
    VenueRepository venueRepository;
    BookingRepository bookingRepository;
    FinanceRepository financeRepository;
    InvoiceRepository invoiceRepository;
    FinanceService financeService;

    public SystemStatsResponse getSystemStats() {
        BigDecimal totalRevenue = financeRepository.findAll().stream()
                .map(Finance::getPlatformFeeAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return SystemStatsResponse.builder()
                .totalUsers(userRepository.count())
                .totalVenues(venueRepository.count())
                .activeVenues(venueRepository.findByStatus(VenueStatus.ACTIVE,
                        org.springframework.data.domain.Pageable.unpaged()).getTotalElements())
                .pendingVenues(venueRepository.findByStatus(VenueStatus.PENDING,
                        org.springframework.data.domain.Pageable.unpaged()).getTotalElements())
                .totalBookings(bookingRepository.count())
                .completedBookings(bookingRepository.findAll().stream()
                        .filter(b -> b.getStatus() == BookingStatus.COMPLETED).count())
                .totalPlatformRevenue(totalRevenue)
                .pendingInvoices(invoiceRepository.findByStatus(PlatformFeeStatus.PENDING).size())
                .build();
    }

    public List<PlatformFeeInvoice> getPendingInvoices() {
        return financeService.getPendingInvoices();
    }

    public PlatformFeeInvoice generateInvoice(String venueId, String period) {
        return financeService.generateMonthlyInvoice(venueId, period);
    }

    public PlatformFeeInvoice markInvoicePaid(String invoiceId) {
        return financeService.markInvoicePaid(invoiceId);
    }
}
```

- [ ] **Step 3: Create AdminController**

`src/main/java/vn/chuongpl/badbook/features/admin/AdminController.java`:
```java
package vn.chuongpl.badbook.features.admin;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.features.admin.dto.SystemStatsResponse;
import vn.chuongpl.badbook.features.finance.PlatformFeeInvoice;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    @GetMapping("/stats")
    public ApiResponse<SystemStatsResponse> getStats() {
        return ApiResponse.<SystemStatsResponse>builder()
                .data(adminService.getSystemStats()).build();
    }

    @GetMapping("/invoices/pending")
    public ApiResponse<List<PlatformFeeInvoice>> getPendingInvoices() {
        return ApiResponse.<List<PlatformFeeInvoice>>builder()
                .data(adminService.getPendingInvoices()).build();
    }

    @PostMapping("/invoices/generate")
    public ApiResponse<PlatformFeeInvoice> generateInvoice(@RequestParam String venueId,
                                                            @RequestParam String period) {
        return ApiResponse.<PlatformFeeInvoice>builder()
                .data(adminService.generateInvoice(venueId, period)).build();
    }

    @PutMapping("/invoices/{id}/paid")
    public ApiResponse<PlatformFeeInvoice> markPaid(@PathVariable String id) {
        return ApiResponse.<PlatformFeeInvoice>builder()
                .data(adminService.markInvoicePaid(id)).build();
    }
}
```

- [ ] **Step 4: Final full test run**
```bash
mvn test -q 2>&1 | tail -15
```
Expected: BUILD SUCCESS, all tests pass.

- [ ] **Step 5: Compile verify**
```bash
mvn compile -q && echo "COMPILE OK"
```

- [ ] **Step 6: Commit Phase 4 complete**
```bash
git add src/main/java/vn/chuongpl/badbook/features/admin/
git commit -m "feat: add Admin dashboard with stats and platform fee invoice management"
git tag phase-4-complete
git commit --allow-empty -m "chore: Phase 4 Extended Services complete — reviews, search, admin dashboard"
```

---

## Final Verification

- [ ] **Step 1: Run all migrations on a clean database**
```bash
docker compose -f docker-compose.dev.yaml down -v && docker compose -f docker-compose.dev.yaml up -d
sleep 5 && make migrate
```
Expected: 13 migrations applied successfully.

- [ ] **Step 2: Start application and test all endpoints**
```bash
mvn spring-boot:run &
sleep 15

# Register
curl -s -X POST http://localhost:8080/badbook/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@test.com","password":"Test@123","phone":"0909090909"}' | python3 -m json.tool

# Login as admin
TOKEN=$(curl -s -X POST http://localhost:8080/badbook/api/auth \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@gmail.com","password":"Admin@123456"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['token'])")

# Get admin stats
curl -s http://localhost:8080/badbook/api/admin/stats \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
```
Expected: `{"code":200,"data":{"totalUsers":1,...}}`

- [ ] **Step 3: Stop application**
```bash
pkill -f "spring-boot:run"
```
