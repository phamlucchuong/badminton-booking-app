# Functional Requirements Specification — Badminton Court Booking Platform

**Status:** Draft 1
**Date:** 2026-06-04
**Sources:** [`screen_requirement.md`](./screen_requirement.md) (mobile UI flow), backend codebase (`apps/backend`), migration design spec (`docs/superpowers/specs/2026-06-03-badminton-booking-migration-design.md`).

This document defines *what* the platform must do, across all three actors. It is the reference for the implementation [roadmap](./roadmap.md) — every requirement carries a stable ID (`FR-<ROLE>-NN`) that the roadmap and plans link back to.

---

## 1. Overview

A platform that connects badminton players with court venues.

**Business model:**

```
USER ──books court──► VENUE (badminton club) ──pays platform fee──► ADMIN (platform)
                          │
                          ├── hourly court rental
                          ├── fixed weekly schedule
                          └── product sales (rackets, shuttlecocks, beverages, ...)
```

Platform revenue is a configurable percentage (`platformFeeRate`) deducted from each completed booking and settled monthly via a `PlatformFeeInvoice`.

**Deliverables (clients):**

- **User mobile app** (`apps/app-user`, Flutter) — the 9 screens in `screen_requirement.md`.
- **Admin web** (`apps/web-admin`, React) — platform operations.
- **Venue Manager** surface — currently no dedicated client; covered by backend APIs and planned for a future portal.
- **Backend** (`apps/backend`, Spring Boot) — shared REST API for all clients.

---

## 2. Actors & Roles

| Role | Description | Primary client |
|------|-------------|----------------|
| `USER` | Player who searches venues, books courts, pays, reviews | User mobile app |
| `VENUE_MANAGER` | Club owner who manages venue, courts, products, bookings | Backend APIs (portal planned) |
| `ADMIN` | Platform operator: venue approval, fees, moderation, stats | Admin web |

Roles map to Spring Security `ROLE_*` authorities. Authorization is enforced per-endpoint with `@PreAuthorize`. A default `ADMIN` account is seeded at startup.

---

## 3. Functional Requirements

Each requirement lists the related **screen** (from `screen_requirement.md`, where applicable) and the backing **API** (existing endpoint, or *(no endpoint yet)* where the requirement is not yet served by the backend).

### 3.1 USER — Player (mobile app)

| ID | Requirement | Screen | API |
|----|-------------|--------|-----|
| FR-USER-01 | Splash screen and a 3-card swipeable onboarding flow ending in "Get Started" → Login. | 1 | — |
| FR-USER-02 | Register with email + password; verify the account with a 6-digit email OTP. | 2 | `POST /api/auth/register`, `POST /api/otp/send`, `GET /api/otp/verify` |
| FR-USER-03 | Log in with email/password; log out (token invalidated). | 2 | `POST /api/auth`, `POST /api/auth/logout` |
| FR-USER-04 | Social login via OAuth2 (Google / Apple). | 2 | *(no endpoint yet)* |
| FR-USER-05 | Reset a forgotten password ("Forgot Password"). | 2 | *(no endpoint yet)* |
| FR-USER-06 | Home dashboard: global header, promotional banner carousel, and a list of recommended courts. | 3 | `GET /api/venues` |
| FR-USER-07 | Search venues by keyword with filters; see hot keywords and personal search history. | 3 | `GET /api/search`, `GET /api/search/hot`, `GET /api/search/history` |
| FR-USER-08 | Court/venue detail: hero image, description, price, cross-sell products, and reviews. | 4 | `GET /api/venues/{id}`, `GET /api/venues/{venueId}/courts`, `GET /api/venues/{venueId}/products`, `GET /api/reviews` |
| FR-USER-09 | Time-slot matrix: 2D grid of sub-courts × 30-min slots with available / unavailable / selected cell states. | 5 | `GET /api/venues/{venueId}/courts` (+ availability) |
| FR-USER-10 | Review order: summary of court/date/slots, selected add-on products, and pricing (subtotal, tax, total). | 6 | `GET /api/venues/{venueId}/products` |
| FR-USER-11 | Create a booking for the selected court, slots, and add-ons. | 6 | `POST /api/bookings` |
| FR-USER-12 | Pay a deposit via VNPay / QR; confirm payment completion. | 7 | `POST /api/payments/vnpay/create`, `GET /api/payments/vnpay-callback` |
| FR-USER-13 | Booking confirmation screen with booking ID, details, and a check-in QR code. | 8 | `GET /api/bookings/my` |
| FR-USER-14 | View own bookings and cancel a booking (with optional reason). | 8 | `GET /api/bookings/my`, `PUT /api/bookings/{id}/cancel` |
| FR-USER-15 | Submit a star rating + comment review for a completed booking. | 4 | `POST /api/reviews` |
| FR-USER-16 | Create and manage a fixed weekly (recurring) schedule. | — | `POST /api/schedules`, `GET /api/schedules/my`, `DELETE /api/schedules/{id}` |
| FR-USER-17 | Profile & account management: view profile, change password, edit email, edit phone, app settings, log out. | 9 | *(service exists; no controller endpoint yet)* |
| FR-USER-18 | Global header utilities: avatar → profile, language toggle (VI/EN), theme toggle (light/dark). | global | — |

### 3.2 VENUE_MANAGER — Club owner

| ID | Requirement | API |
|----|-------------|-----|
| FR-VM-01 | Register a venue (name, address auto-geocoded to coordinates). | `POST /api/venues`, `POST /api/location/geocode` |
| FR-VM-02 | View own venue and its approval status. | `GET /api/venues/my` |
| FR-VM-03 | Manage courts: create courts, set court status (available/maintenance/…). | `POST /api/venues/{venueId}/courts`, `PUT /api/venues/{venueId}/courts/{courtId}/status` |
| FR-VM-04 | Manage sellable products (rackets, shuttlecocks, beverages). | `POST /api/venues/{venueId}/products`, `GET /api/venues/{venueId}/products` |
| FR-VM-05 | View bookings for own venue. | `GET /api/bookings/venue/{venueId}` |
| FR-VM-06 | Confirm a pending booking and mark a booking complete. | `PUT /api/bookings/{id}/confirm`, `PUT /api/bookings/{id}/complete` |
| FR-VM-07 | Reply to user reviews. | `PUT /api/reviews/{id}/reply` |
| FR-VM-08 | Upload media (court / venue images). | `POST /api/media` |
| FR-VM-09 | View own platform-fee invoices and settlement status. | *(generated admin-side; VM-facing read not exposed yet)* |

### 3.3 ADMIN — Platform operator (admin web)

| ID | Requirement | API |
|----|-------------|-----|
| FR-ADM-01 | Review pending venues; approve, reject, or suspend a venue. | `GET /api/venues/pending`, `PUT /api/venues/{id}/approve`, `PUT /api/venues/{id}/reject`, `PUT /api/venues/{id}/suspend` |
| FR-ADM-02 | View system statistics dashboard (users, venues, bookings, revenue). | `GET /api/admin/stats` |
| FR-ADM-03 | Generate a monthly platform-fee invoice for a venue. | `POST /api/admin/invoices/generate` |
| FR-ADM-04 | View pending invoices and mark an invoice paid. | `GET /api/admin/invoices/pending`, `PUT /api/admin/invoices/{id}/paid` |
| FR-ADM-05 | Moderate content: delete an inappropriate review. | `DELETE /api/reviews/{id}` |
| FR-ADM-06 | Manage users and roles (list, create, delete). | *(service exists; no admin controller endpoint yet)* |

---

## 4. Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR-01 | **Auth:** stateless JWT (OAuth2 resource server). Logout invalidates tokens via a Redis-backed blacklist filter. Passwords hashed with BCrypt. |
| NFR-02 | **Authorization:** role-based, enforced per endpoint with `@PreAuthorize`; method-level security enabled. |
| NFR-03 | **API contract:** every response uses the uniform `ApiResponse<T>` envelope `{code, message, data}`; errors map through a central `ErrorCode` enum + `GlobalExceptionHandler`. |
| NFR-04 | **Internationalization:** UI supports Vietnamese and English with a runtime language toggle. |
| NFR-05 | **Design system:** professional/minimalist; primary color `#132D77`; `SafeArea` on all mobile screens; responsive mobile constraints; light/dark theme. |
| NFR-06 | **Schema ownership:** database schema owned by Flyway migrations (`V1…Vn`); JPA runs in `validate` mode. |
| NFR-07 | **External integrations:** Cloudinary (media), Goong (geocoding), VNPay (payments), JavaMail (OTP email). |

---

## 5. Out of Scope (current phase)

- In-app chat between users and venues.
- Push notifications.
- Multi-currency / international payment providers beyond VNPay.
- Loyalty / rewards program.
