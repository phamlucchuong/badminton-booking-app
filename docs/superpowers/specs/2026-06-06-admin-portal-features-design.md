# Admin Portal Feature Pages — Design Spec

**Date:** 2026-06-06  
**Status:** Approved  
**Prerequisite:** `2026-06-06-web-portal-foundation-plan.md` must be executed first.

---

## 1. Scope

Replace the 5 admin stub pages at `src/pages/admin/` with fully functional implementations wired to the existing backend API. No new backend endpoints are required. The 10 legacy stub files (ai-config, audit-logs, employer-verification, job-moderation, packages, payments, rbac, settings, and the old dashboard/users) are deleted and replaced.

**In scope:**

| Route | Page | Primary API |
|-------|------|-------------|
| `/admin` | Dashboard | `GET /api/admin/stats` |
| `/admin/venues` | Venue Approval | `GET /api/venues/admin/pending` + approve/reject/suspend |
| `/admin/users` | User Management | `GET /api/admin/users` + create + delete |
| `/admin/invoices` | Invoice Management | `GET /api/admin/invoices/pending` + generate + mark paid |
| `/admin/reviews` | Reviews | Stub — "Sắp ra mắt" |

**Out of scope:** Review moderation UI (backend only has `DELETE /{id}`, no list-all endpoint without venue filter — deferred).

---

## 2. Architecture

### Frontend structure

```
src/
  hooks/admin/
    use-admin-stats.ts          # GET /admin/stats
    use-admin-venues.ts         # pending venues + approve/reject/suspend
    use-admin-users.ts          # paginated users + create + delete
    use-admin-invoices.ts       # pending invoices + generate + mark paid
  pages/admin/
    dashboard.tsx               # replaces admin-dashboard-page.tsx
    venues.tsx                  # replaces admin-employer-verification-page.tsx (old)
    users.tsx                   # replaces admin-users-page.tsx
    invoices.tsx                # replaces admin-payments-page.tsx (old)
    reviews.tsx                 # replaces admin-job-moderation-page.tsx (old)
  types/api.ts                  # extend with SystemStatsResponse, AdminUserResponse
```

All 10 legacy stub files are deleted. The 5 new pages above are the only admin pages.

### Shared dependencies (from foundation plan)
- `DataTable` component — `src/components/ui/data-table.tsx`
- `Modal` component — `src/components/ui/modal.tsx`
- `FormField`, `SelectField` — `src/components/ui/form-field.tsx`
- `api` axios instance — `src/lib/axios.ts`
- `queryClient` — `src/lib/query-client.ts`
- `Button` — `src/components/ui/button.tsx`

### Query key namespace
All admin hooks use `['admin', ...]` query keys to avoid collisions with venue hooks.

---

## 3. TypeScript Types

Add to `src/types/api.ts`:

```ts
export interface SystemStatsResponse {
  totalUsers: number
  totalVenues: number
  activeVenues: number
  pendingVenues: number
  totalBookings: number
  completedBookings: number
  totalPlatformRevenue: number
  pendingInvoices: number
}

export interface AdminUserResponse {
  id: string
  name: string
  phone: string
  email: string
  createdAt: string
  deleted: boolean
}

export interface AdminUserCreateRequest {
  name: string
  phone: string
  email: string
  password: string
}
```

`PlatformFeeInvoice` and `VenueResponse` are already defined in the venue manager spec — reuse them.

---

## 4. TanStack Query Hooks

### `use-admin-stats.ts`
```ts
queryKey: ['admin', 'stats']
queryFn: GET /admin/stats → SystemStatsResponse
staleTime: 60_000
```

### `use-admin-venues.ts`
```ts
// Pending venues (admin endpoint)
queryKey: ['admin', 'venues', 'pending']
queryFn: GET /venues/admin/pending?page=1&size=50 → PageResponse<VenueResponse>

// All venues (public endpoint — returns ACTIVE + possibly PENDING/SUSPENDED depending on backend filter)
queryKey: ['admin', 'venues', 'all']
queryFn: GET /venues?page=1&size=100 → PageResponse<VenueResponse>

// Mutations — ALL THREE invalidate both ['admin','venues','pending'] AND ['admin','venues','all']
approveVenue: PUT /venues/{id}/approve   // sets status ACTIVE (also used to reactivate SUSPENDED)
rejectVenue:  PUT /venues/{id}/reject    // sets status REJECTED
suspendVenue: PUT /venues/{id}/suspend   // sets status SUSPENDED
```

> Note: If `GET /api/venues` only returns ACTIVE venues (backend may filter), the venues page table shows ACTIVE + PENDING merged: pending venues fetched separately and prepended. Implementation should merge and deduplicate by `id`. If backend returns all statuses, use the single query only.

### `use-admin-users.ts`
```ts
queryKey: ['admin', 'users', page]   // page: number state
queryFn: GET /admin/users?page={page} → PageResponse<AdminUserResponse>

createUser: POST /admin/users (body: AdminUserCreateRequest) → AdminUserResponse
  onSuccess: invalidate ['admin', 'users']

deleteUser: DELETE /admin/users/{id}
  onSuccess: invalidate ['admin', 'users']
```

### `use-admin-invoices.ts`
```ts
queryKey: ['admin', 'invoices', 'pending']
queryFn: GET /admin/invoices/pending → PlatformFeeInvoice[]

generateInvoice: POST /admin/invoices/generate?venueId={v}&period={p} → PlatformFeeInvoice
  onSuccess: invalidate ['admin', 'invoices', 'pending']

markPaid: PUT /admin/invoices/{id}/paid → PlatformFeeInvoice
  onSuccess: invalidate ['admin', 'invoices', 'pending']
```

---

## 5. Page Designs

### 5.1 Dashboard (`/admin`)

**Layout:** 4 stat cards (1 row) → full-width pending venues table below.

**Stat cards** (4 most actionable from 8 available stats):

| Card | Value | Highlight condition |
|------|-------|-------------------|
| Total Users | `totalUsers` | never |
| Pending Venues | `pendingVenues` | amber border if > 0 |
| Platform Revenue | `totalPlatformRevenue` formatted as `xB` / `xM` | never |
| Pending Invoices | `pendingInvoices` | amber border if > 0 |

**Pending venues section** (below stats): If `pendingVenues > 0`, show a full-width table fetching from `GET /api/venues/admin/pending?page=1&size=10`. Columns: Tên sân, Địa chỉ, Chủ sân, inline "✓ Duyệt" + "✕ Từ chối" buttons. If `pendingVenues === 0`, show a green checkmark panel "Không có venue chờ duyệt".

**Data flow:** Single `useAdminStats()` call. Pending venues fetched only if `stats.pendingVenues > 0` (enabled: `stats?.pendingVenues > 0`).

---

### 5.2 Venues (`/admin/venues`)

**Layout:** Single DataTable of all venues + venue detail Modal.

**Table columns:** Tên sân, Địa chỉ, Chủ sân, Status badge (PENDING=amber, ACTIVE=green, SUSPENDED=red), "Xem →" link per row.

**Status badge colours:**
- `PENDING` → amber
- `ACTIVE` → green
- `SUSPENDED` → red/orange

**Detail Modal** (opens on row click or "Xem →"):

Fields displayed:
- Tên sân, Địa chỉ, Mã giấy phép (`licenseId`), Chủ sân (`ownerName`)
- Giờ hoạt động (`openTime`–`closeTime`)
- Status badge

Action buttons (conditional on status):
- `PENDING` → "✓ Phê duyệt" (green) + "✕ Từ chối" (red)
- `ACTIVE` → "⛔ Tạm dừng" (amber)
- `SUSPENDED` → "✓ Kích hoạt lại" (green, calls approve endpoint)

After any action: close modal, show toast, invalidate queries.

**Data:** `useAdminVenuesAll()` + `useAdminVenuesPending()` merged for the table (pending prepended, deduplicated by id). `useAdminVenuesPending()` is also used on the dashboard.

---

### 5.3 Users (`/admin/users`)

**Layout:** DataTable + "Tạo tài khoản" button + create Modal + delete confirm.

**Table columns:** Tên, Email, SĐT, Ngày tạo (formatted), Status (`deleted` → red "Đã xóa" badge / green "Hoạt động"), "🗑 Xóa" button (disabled if `deleted === true`).

**Pagination:** `page` state (starts at 1), prev/next buttons below table. Page size = 20 (default from backend).

**Create modal fields:**
- Tên (`name`) — required
- Email (`email`) — required
- SĐT (`phone`) — required
- Mật khẩu (`password`) — required, type="password"

**Delete flow:** `window.confirm('Xóa tài khoản này?')` → `DELETE /api/admin/users/{id}` → toast success → invalidate.

---

### 5.4 Invoices (`/admin/invoices`)

**Layout:** Status filter dropdown + DataTable + "Tạo hóa đơn" modal.

**Filter:** dropdown `[Tất cả | Chưa đóng | Đã đóng]` — client-side filter of the loaded list. Default: "Chưa đóng".

**Table columns:** Venue, Kỳ, Số booking, Doanh thu, Phí nền tảng (bold amber), Hạn đóng, Status badge, Action.

**Action column:** If `status === 'PENDING'` → "✓ Đánh dấu đã đóng" button. If `status === 'PAID'` → "—".

**Data source:** `GET /api/admin/invoices/pending` returns only PENDING invoices. Invoices that get marked as PAID are optimistically removed from the list (or refetched via invalidation). The "Tất cả" filter shows all items currently in cache (pending + any newly generated ones from this session).

**Generate Invoice modal:**
- Venue dropdown (loaded from `GET /api/venues?page=1&size=100`, shows name + id)
- Kỳ input: text field, placeholder `2026-06`, validated as `YYYY-MM` regex
- Submit → `POST /api/admin/invoices/generate?venueId={v}&period={p}` → toast "Đã tạo hóa đơn" → invalidate

---

### 5.5 Reviews (`/admin/reviews`)

Stub page only. Shows:
- Heading: "Quản lý đánh giá"
- Badge: "Sắp ra mắt"
- Description: "Tính năng kiểm duyệt đánh giá đang được phát triển."

No API calls, no hooks.

---

## 6. Error Handling

- All mutations use Sonner `toast.error(...)` in `onError` callback.
- 401 responses handled globally by the axios response interceptor (redirects to `/login`).
- `useMyVenue` equivalents: admin hooks use `retry: false` where appropriate (e.g., stats).

---

## 7. Verification

No vitest/jest in web-admin. Verification steps:
1. `pnpm exec tsc --noEmit` — 0 errors
2. `pnpm build` — exits 0
3. Dev server smoke test per page (see implementation plan)
