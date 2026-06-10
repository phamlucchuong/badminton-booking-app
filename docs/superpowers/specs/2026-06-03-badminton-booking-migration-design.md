# Badminton Booking BE — Migration Design Spec

**Date:** 2026-06-03
**Source project:** BIGFOOD-BE (food delivery, Spring Boot 3.4.1, MySQL)
**Target project:** badminton-booking-be (sports court booking, Spring Boot 3.5.11, PostgreSQL + Redis)

---

## 1. Overview

Migrate and adapt BIGFOOD-BE into a badminton court booking platform. The goal is to reuse technical infrastructure (auth, media, exception handling, OTP, maps) while rewriting all domain-specific logic for the new domain: court booking, venue management, product sales, and platform fee collection.

---

## 2. Business Model

```
USER ──books court──► VENUE (badminton club) ──pays platform fee──► ADMIN (platform)
                          │
                          ├── hourly court rental
                          ├── fixed weekly schedule
                          └── product sales (rackets, shuttlecocks, beverages, ...)
```

**Platform revenue source:** A configurable percentage fee (`platformFeeRate`) deducted from each completed booking's total amount. Settled monthly via `PlatformFeeInvoice`.

---

## 3. Roles & Responsibilities

| Role | Capabilities |
|------|-------------|
| `USER` | Search venues/courts, book courts (hourly or fixed schedule), add products to booking, pay via VNPay or cash, write reviews, view booking history |
| `VENUE_MANAGER` | Register and manage one venue, manage courts and products, confirm/cancel bookings, reply to reviews, view venue revenue |
| `ADMIN` | Approve/suspend venues, manage platform fee invoices, view system-wide statistics, delete violating reviews |

**VENUE_MANAGER owns exactly one Venue.** The `Venue.ownerId` field references the user's ID.

---

## 4. Domain Entities

### 4.1 Core (Copy & Adapt from BIGFOOD-BE)

| Entity | Table | Key Fields |
|--------|-------|-----------|
| `User` | `users` | id (UUID), name, email, password, phone, imageId, isDeleted, createdAt |
| `Role` | `roles` | name (ADMIN / VENUE_MANAGER / USER), description |
| `Permission` | `permissions` | name, description |

Junction tables: `user_roles`, `role_permissions` (already in V1–V3 migrations).

### 4.2 Venue & Court (Rewrite from Restaurant/Food)

| Entity | Table | Key Fields |
|--------|-------|-----------|
| `Venue` | `venues` | id (UUID), ownerId, name, address, latitude, longitude, description, bannerIds, licenseId, **status** (PENDING/ACTIVE/SUSPENDED/REJECTED), openTime, closeTime, **platformFeeRate** (decimal), bankName, bankNumber, bankAccountName, createdAt |
| `Court` | `courts` | id (UUID), venueId, name, **courtType** (STANDARD/PREMIUM/VIP), pricePerHour, imageIds, **status** (ACTIVE/MAINTENANCE/INACTIVE), description |

**Venue lifecycle:** VENUE_MANAGER registers → `status = PENDING` → ADMIN approves → `status = ACTIVE`. ADMIN can set `SUSPENDED` at any time.

### 4.3 Products (Rewrite from FoodOption — now a standalone entity)

| Entity | Table | Key Fields |
|--------|-------|-----------|
| `Product` | `products` | id (UUID), venueId, name, **category** (RACKET_RENTAL / SHUTTLECOCK / BEVERAGE / EQUIPMENT / OTHER), price, unit, stock, imageId, isActive |

Products belong to a venue and can be added to any booking at that venue.

### 4.4 Booking System (Rewrite from Order)

| Entity | Table | Key Fields |
|--------|-------|-----------|
| `Booking` | `bookings` | id (UUID), userId, courtId, venueId, date, startTime, endTime, **type** (HOURLY/FIXED), **status** (PENDING/CONFIRMED/IN_PROGRESS/COMPLETED/CANCELLED), totalAmount, notes, cancelReason, createdAt |
| `BookingProduct` | `booking_products` | id (UUID), bookingId, productId, productName (snapshot), quantity, unitPrice, totalPrice |
| `FixedSchedule` | `fixed_schedules` | id (UUID), userId, courtId, venueId, dayOfWeek (array), startTime, endTime, startDate, endDate, status (ACTIVE/CANCELLED), notes |

**Booking conflict detection:** Before creating a booking, check that no other CONFIRMED/IN_PROGRESS booking overlaps the same `courtId + date + [startTime, endTime)` range.

**FixedSchedule:** A recurring booking template. A Spring `@Scheduled` job runs weekly and generates individual `Booking` records for each active `FixedSchedule`. VENUE_MANAGER can also trigger generation manually for a specific week.

**Booking status flow:**
```
PENDING
  ├─► [VNPay paid]      → CONFIRMED
  ├─► [Cash + VM confirms] → CONFIRMED
  └─► [User/VM cancels]  → CANCELLED

CONFIRMED → IN_PROGRESS (on booking date/time) → COMPLETED
COMPLETED → User can write Review + Finance record is created
```

### 4.5 Payment & Finance (New + Adapt)

| Entity | Table | Key Fields |
|--------|-------|-----------|
| `Payment` | `payments` | id (UUID), bookingId, amount, **method** (VNPAY/CASH), transactionId, **status** (PENDING/SUCCESS/FAILED/REFUNDED), paidAt |
| `Finance` | `finances` | id, bookingId, totalAmount, **platformFeeAmount**, **venueRevenue**, status (PENDING/COMPLETED/FAILED) |
| `PlatformFeeInvoice` | `platform_fee_invoices` | id (UUID), venueId, period (YYYY-MM), totalBookings, totalRevenue, feeAmount, **status** (PENDING/PAID/OVERDUE), dueDate, paidAt |

`Finance` is created automatically when a `Booking` transitions to `COMPLETED`:
- `platformFeeAmount = totalAmount × venue.platformFeeRate`
- `venueRevenue = totalAmount − platformFeeAmount`

`PlatformFeeInvoice` is generated monthly (one per venue per month) aggregating all `Finance` records for that period.

### 4.6 Social & Search (Adapt from BIGFOOD-BE)

| Entity | Table | Key Fields |
|--------|-------|-----------|
| `Review` | `reviews` | id (UUID), userId, bookingId, **targetType** (VENUE/COURT), targetId, rating (1–5), content, replyText, replyAt, isDeleted, createdAt |
| `SearchHistory` | `search_history` | id (UUID), userId (nullable), keyword, count, lastSearchedAt |

**Review constraint:** A user may only submit a review after the associated booking reaches `COMPLETED` status. VENUE_MANAGER may reply once. ADMIN may soft-delete.

---

## 5. Architecture

### Package Structure

```
vn.chuongpl.badbook/
├── common/
│   ├── exception/       AppException, GlobalExceptionHandler
│   ├── enums/           ErrorCode, BookingStatus, BookingType,
│   │                    PaymentStatus, PaymentMethod, VenueStatus,
│   │                    CourtType, CourtStatus, ProductCategory,
│   │                    ReviewTarget, PlatformFeeStatus
│   ├── ApiResponse.java
│   └── PageResponse.java
├── configuration/       SecurityConfig, FlywayConfig, ApplicationInitConfig,
│                        CustomerJwtDecoder, JwtBlacklistFilter,
│                        CloudinaryConfig, GoongWebClientConfig, TwilioConfig
└── features/
    ├── auth/            JWT login/logout/register/introspect + OTP
    ├── user/            Profile management + image upload
    ├── media/           Cloudinary upload endpoint
    ├── venue/           Venue CRUD + approval workflow
    ├── court/           Court CRUD per venue
    ├── product/         Product CRUD per venue
    ├── location/        Goong API geocoding for venue address
    ├── booking/         Booking creation, conflict check, status management
    ├── schedule/        Fixed recurring schedule management
    ├── payment/         VNPay integration + callback handling
    ├── finance/         Per-booking finance + monthly invoice generation
    ├── review/          Review submission, reply, moderation
    ├── search/          Venue search + search history
    └── admin/           Admin dashboard: stats, venue approval, fee management
```

Each feature package contains its own: `Entity.java`, `Repository.java`, `Service.java`, `Controller.java`, and `dto/` subfolder.

### Migration Strategy per Module

| Module | Strategy | Source |
|--------|----------|--------|
| auth, user, role, permission | Already in badminton-booking-be | Enhance only |
| OTP (Twilio) | Copy & adapt package names | BIGFOOD-BE |
| media (Cloudinary) | Copy & adapt package names | BIGFOOD-BE |
| location (Goong) | Copy & adapt package names | BIGFOOD-BE |
| exception, ErrorCode | Merge both projects + add new codes | Both |
| ApplicationInitConfig | Adapt to seed 3 new roles | BIGFOOD-BE |
| venue, court, product | Rewrite (Restaurant/Food→Venue/Court/Product) | Domain: new |
| booking, schedule | Rewrite (Order→Booking + new FixedSchedule) | Domain: new |
| payment | New (VNPay config already present) | New |
| finance | Adapt pattern (per-booking split + monthly invoice) | BIGFOOD-BE Finance |
| review, search | Adapt (add targetType, link to booking) | BIGFOOD-BE |
| admin dashboard | New | New |

---

## 6. Flyway Migration Plan

| File | Content |
|------|---------|
| V1 | Create users table |
| V2 | Create roles table |
| V3 | Create user_roles, permissions, role_permissions |
| V4 | Create venues |
| V5 | Create courts |
| V6 | Create products |
| V7 | Create bookings |
| V8 | Create booking_products |
| V9 | Create fixed_schedules |
| V10 | Create payments |
| V11 | Create finances, platform_fee_invoices |
| V12 | Create reviews |
| V13 | Create search_history |
| V14 | Insert initial data (roles, admin account, permissions) |

V1–V3 already exist. V4 onward will be written per phase.

---

## 7. Error Codes (additions to existing ErrorCode enum)

```
// Venue
VENUE_NOT_FOUND, VENUE_NOT_APPROVED, VENUE_ALREADY_EXISTS, VENUE_NOT_OWNED_BY_USER

// Court
COURT_NOT_FOUND, COURT_NOT_AVAILABLE, COURT_NOT_IN_VENUE

// Booking
BOOKING_NOT_FOUND, BOOKING_CONFLICT, BOOKING_CANNOT_CANCEL, BOOKING_NOT_COMPLETED

// Product
PRODUCT_NOT_FOUND, PRODUCT_OUT_OF_STOCK, PRODUCT_NOT_IN_VENUE

// Payment
PAYMENT_NOT_FOUND, PAYMENT_FAILED, PAYMENT_ALREADY_PROCESSED

// Review
REVIEW_ONLY_AFTER_COMPLETION, REVIEW_ALREADY_SUBMITTED

// Finance
PLATFORM_FEE_ALREADY_PAID, INVOICE_NOT_FOUND

// Schedule
SCHEDULE_CONFLICT, SCHEDULE_NOT_FOUND
```

---

## 8. Phase Breakdown

### Phase 1 — Foundation
**Goal:** Complete technical infrastructure. No new business logic.

- Copy OTP module (Twilio) from BIGFOOD-BE
- Copy media module (Cloudinary) from BIGFOOD-BE
- Copy Goong API client from BIGFOOD-BE
- Merge and extend ErrorCode enum
- Adapt ApplicationInitConfig to seed ADMIN/VENUE_MANAGER/USER roles
- Verify auth flow (JWT + Redis blacklist + OTP) end-to-end

**Test:** Unit test OTP flow, Cloudinary upload, Goong geocoding with mocks.

### Phase 2 — Venue & Court Management
**Goal:** VENUE_MANAGER can register a venue and add courts. ADMIN can approve.

- Implement `features/venue/`: CRUD + approval workflow (PENDING→ACTIVE/REJECTED)
- Implement `features/court/`: CRUD per venue
- Implement `features/product/`: CRUD per venue (rackets, shuttlecocks, beverages)
- Implement `features/location/`: Goong geocoding wrapper
- Flyway: V4 (venues), V5 (courts), V6 (products)

**Test:** Integration test venue registration + admin approval, court CRUD, product stock management.

### Phase 3 — Booking + Payment + Finance
**Goal:** USER can book a court, pay, and the system auto-calculates platform fees.

- Implement `features/booking/`: create booking with conflict detection, status transitions
- Implement `features/schedule/`: fixed weekly schedule + booking generation
- Implement `features/payment/`: VNPay payment initiation + return/IPN callback
- Implement `features/finance/`: auto-create Finance on booking COMPLETED, monthly invoice aggregation
- Flyway: V7 (bookings), V8 (booking_products), V9 (fixed_schedules), V10 (payments), V11 (finances + platform_fee_invoices)

**Test:** Booking conflict detection, VNPay callback simulation, Finance auto-creation, invoice aggregation.

### Phase 4 — Extended Services
**Goal:** Reviews, search, and admin dashboard complete.

- Implement `features/review/`: post-completion review, venue reply, admin moderation
- Implement `features/search/`: venue full-text search by name/address/courtType + history
- Implement `features/admin/`: statistics (bookings/revenue/active venues), pending venue approval list, platform fee invoice management
- Flyway: V12 (reviews), V13 (search_history)

**Test:** Review permission enforcement (COMPLETED bookings only), search relevance, admin stats correctness.

---

## 9. Tech Stack Summary

| Concern | Choice | Rationale |
|---------|--------|-----------|
| Framework | Spring Boot 3.5.11 | Already in badminton-booking-be |
| Database | PostgreSQL | Superior spatial queries, UUID native support |
| Cache / JWT blacklist | Redis (Lettuce) | Already configured |
| ORM | Spring Data JPA + Hibernate | Consistent with both projects |
| Migrations | Flyway | Already configured |
| Auth | OAuth2 Resource Server + custom JWT | Already implemented |
| SMS/OTP | Twilio | From BIGFOOD-BE |
| Image storage | Cloudinary | From BIGFOOD-BE |
| Maps/Geocoding | Goong API | From BIGFOOD-BE |
| Payment | VNPay | Already configured in badminton-booking-be |
| DTO mapping | MapStruct | Both projects |
| API docs | SpringDoc OpenAPI | Both projects |
