# Implementation Roadmap — Badminton Court Booking Platform

**Date:** 2026-06-04
**Tracks:** [`functional_requirements.md`](./functional_requirements.md)

This roadmap maps every functional requirement to its **actual** implementation state across the three layers (backend, user app, admin web), as observed in the codebase on `dev`.

## Status legend

| Symbol | Meaning |
|--------|---------|
| ✅ Done | Implemented and (where applicable) covered by tests |
| 🟡 Partial | Started but incomplete, or logic exists without an exposed endpoint |
| 🔌 API-ready | Backend endpoint exists; no client integration yet |
| 📱 UI-only | Client UI exists but is **not** wired to the backend (mock / Firebase data) |
| ⬜ Not started | No implementation |
| — | Not applicable to this layer |

## Headline assessment

> **The backend is the mature core.** Nearly every domain (auth, OTP, venues, courts, products, bookings, payments, finance, reviews, schedules, search, media, admin) has working REST endpoints, with unit tests on the booking/court/venue/product/review/finance/OTP/media services.
>
> **Both frontends are disconnected prototypes.**
> - `apps/app-user` (Flutter / FlutterFlow) renders all 9 screens but reads/writes **Firebase/Firestore** (`lib/backend/firebase`, schema records for bookings, courts, reviews, addons, time_slots). It does **not** call the Spring API.
> - `apps/web-admin` (React) is a static prototype whose pages still carry a **different domain** (job/employer/moderation) and has **no API client** at all.
>
> The biggest value gap is therefore *integration*, not new backend features.

---

## 1. USER requirements

| ID | Requirement | Backend | app-user | Notes |
|----|-------------|:------:|:--------:|-------|
| FR-USER-01 | Splash & onboarding | — | 📱 UI-only | `splash_onboarding` page exists |
| FR-USER-02 | Register + email OTP | ✅ | 📱 UI-only | `auth` + `otp` features; OTP tested |
| FR-USER-03 | Login / logout | ✅ | 📱 UI-only | JWT + Redis blacklist logout |
| FR-USER-04 | OAuth2 (Google/Apple) | ⬜ | 📱 UI-only | UI buttons only; no backend |
| FR-USER-05 | Forgot password | ⬜ | 🟡 | No reset endpoint |
| FR-USER-06 | Home + recommended courts | ✅ | 📱 UI-only | `GET /api/venues` |
| FR-USER-07 | Search + hot keywords + history | ✅ | 📱 UI-only | `search` feature (V13 history) |
| FR-USER-08 | Court detail + cross-sell + reviews | ✅ | 📱 UI-only | `court_details` page |
| FR-USER-09 | Time-slot matrix | 🟡 | 📱 UI-only | Courts API exists; availability endpoint to confirm |
| FR-USER-10 | Review order + pricing | ✅ | 📱 UI-only | `review_order` page |
| FR-USER-11 | Create booking | ✅ | 📱 UI-only | `POST /api/bookings` (tested) |
| FR-USER-12 | VNPay / QR payment | ✅ | 📱 UI-only | `q_r_payment` page; VNPay create + callback |
| FR-USER-13 | Booking confirmation + check-in QR | ✅ | 📱 UI-only | `booking_confirmation` page |
| FR-USER-14 | My bookings + cancel | ✅ | 📱 UI-only | `GET /api/bookings/my`, cancel |
| FR-USER-15 | Submit review | ✅ | 📱 UI-only | `POST /api/reviews` (tested) |
| FR-USER-16 | Fixed weekly schedule | ✅ | ⬜ | `schedule` feature; no UI |
| FR-USER-17 | Profile & account management | 🟡 | 📱 UI-only | `UserService` exists but **no `UserController`** |
| FR-USER-18 | Header: i18n + theme toggle | — | 🟡 | Toggles present; i18n wiring to confirm |

## 2. VENUE_MANAGER requirements

| ID | Requirement | Backend | Client | Notes |
|----|-------------|:------:|:------:|-------|
| FR-VM-01 | Register venue (+ geocode) | ✅ | ⬜ | `venue` + `location` (Goong) |
| FR-VM-02 | View own venue | ✅ | ⬜ | `GET /api/venues/my` |
| FR-VM-03 | Manage courts | ✅ | ⬜ | create + set status (tested) |
| FR-VM-04 | Manage products | ✅ | ⬜ | add + list (tested) |
| FR-VM-05 | View venue bookings | ✅ | ⬜ | `GET /api/bookings/venue/{id}` |
| FR-VM-06 | Confirm / complete booking | ✅ | ⬜ | confirm + complete |
| FR-VM-07 | Reply to reviews | ✅ | ⬜ | `PUT /api/reviews/{id}/reply` |
| FR-VM-08 | Upload media | ✅ | ⬜ | Cloudinary (tested) |
| FR-VM-09 | View own fee invoices | 🟡 | ⬜ | Generated admin-side; no VM read endpoint |

*No Venue Manager client exists yet — all rows are backend-only.*

## 3. ADMIN requirements

| ID | Requirement | Backend | web-admin | Notes |
|----|-------------|:------:|:---------:|-------|
| FR-ADM-01 | Approve / reject / suspend venue | ✅ | 📱 UI-only | web-admin pages are wrong-domain prototypes |
| FR-ADM-02 | Stats dashboard | ✅ | 📱 UI-only | `GET /api/admin/stats` |
| FR-ADM-03 | Generate fee invoice | ✅ | ⬜ | `POST /api/admin/invoices/generate` |
| FR-ADM-04 | Pending invoices + mark paid | ✅ | ⬜ | finance feature |
| FR-ADM-05 | Moderate reviews (delete) | ✅ | ⬜ | `DELETE /api/reviews/{id}` |
| FR-ADM-06 | User & role management | 🟡 | 📱 UI-only | `UserService` methods exist; no admin endpoint |

---

## 4. Milestones

### M1 — Backend foundation ✅ *(complete)*
All core domains implemented with the `ApiResponse` contract, JWT security, Flyway schema (V1–V13), and service-level tests. This is the platform's working core.

### M2 — User app ↔ backend integration 🟡 *(next — see plan)*
Replace the Flutter app's Firebase data layer with the real Spring REST API: auth/OTP, venue browse & search, court detail, time-slot availability, booking creation, VNPay payment, my-bookings, reviews, and profile. Delivers the first true end-to-end user journey.
→ **Plan:** `docs/superpowers/plans/2026-06-04-app-user-backend-integration-plan.md`

### M3 — Admin web adaptation ⬜
Rebuild `apps/web-admin` for the badminton domain (venue approval queue, fee invoices, stats, review moderation, users) and wire it to the admin APIs with a real HTTP client + auth token flow.

### M4 — Venue Manager portal ⬜
Provide a client (web or app) for club owners: venue/court/product management, booking confirmation, schedules, review replies, and fee-invoice visibility (requires FR-VM-09 read endpoint).

### Cross-cutting backend gaps (fold into the milestone that needs them)
- `UserController` to expose profile read/update + change password (FR-USER-17) and admin user management (FR-ADM-06).
- Password reset / forgot-password flow (FR-USER-05).
- OAuth2 social login (FR-USER-04).
- Confirm/define court time-slot availability endpoint for the matrix (FR-USER-09).
- VM-facing fee-invoice read endpoint (FR-VM-09).
