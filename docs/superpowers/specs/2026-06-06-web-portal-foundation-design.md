# Web Portal Foundation Design — Unified Admin + Venue Manager SPA

**Date:** 2026-06-06
**Tracks:** [`functional_requirements.md`](../../knowledge/functional_requirements.md), [`roadmap.md`](../../knowledge/roadmap.md)

This spec covers the **Foundation layer** of the unified web portal: routing architecture, API client, auth flow, and shared layout. Admin features (FR-ADM) and Venue Manager features (FR-VM) are separate specs built on top of this foundation.

---

## Current State Assessment

`apps/web-admin` is a UI prototype (~20% of FR, 0% backend integration):

| What exists | Status |
|-------------|--------|
| Layout shell (sidebar, header, dark/light theme, i18n) | ✅ Keep |
| Design system (Tailwind v4, OKLCH colors, Plus Jakarta Sans) | ✅ Keep |
| Zustand stores (auth, preferences) | ✅ Update |
| React Router 6 routing structure | ✅ Rewrite |
| 9 page components (wrong routes + mock data) | ⚠️ Rewrite content |
| HTTP client / API integration | ❌ Add |
| Data fetching library | ❌ Add |
| Form handling | ❌ Add |

**Approach:** Rewrite page content and routing from scratch. Keep the design system (CSS variables, fonts, Tailwind config) and Zustand/preferences patterns.

---

## Scope

This spec covers **Foundation only**:

| Layer | What it delivers |
|-------|-----------------|
| Routing | Dual-portal route tree with role guards |
| Auth | Login page, RoleSelectPage, JWT-based auth flow |
| API client | Axios instance + interceptors + TanStack Query setup |
| Shared layout | `PortalLayout` component used by both portals |
| Auth store | Updated Zustand store with roles, activeRole, refreshToken |
| Shared UI | `DataTable`, `Modal`, `FormField` components |

Admin feature pages (FR-ADM-01–06) and Venue Manager feature pages (FR-VM-01–09) are implemented in separate specs after this foundation is in place.

---

## 1. Tech Stack

| Library | Version | Purpose |
|---------|---------|---------|
| React | 19 (existing) | UI framework |
| React Router DOM | 6 (existing) | Routing |
| Zustand | 5 (existing) | Auth + preferences state |
| Tailwind CSS | v4 (existing) | Styling |
| Axios | latest | HTTP client + interceptors |
| TanStack Query | v5 | Server state, caching, loading/error |
| Lucide React | existing | Icons |
| Sonner | existing | Toast notifications |

New dependencies: `axios`, `@tanstack/react-query`.

---

## 2. Routing Architecture

```
/                     → redirect based on activeRole (/admin or /venue)
/login                → LoginPage (public)
/select-role          → RoleSelectPage (requires token, shown only for dual-role accounts)

/admin                → AdminGuard
  └── AdminLayout
       ├── /               → AdminDashboardPage      (FR-ADM-02)
       ├── /venues         → AdminVenueApprovalPage  (FR-ADM-01)
       ├── /invoices       → AdminInvoicesPage       (FR-ADM-03, FR-ADM-04)
       ├── /reviews        → AdminReviewModerationPage (FR-ADM-05)
       └── /users          → AdminUsersPage          (FR-ADM-06)

/venue                → VenueGuard
  └── VenueLayout
       ├── /               → VenueDashboardPage
       ├── /profile        → VenueProfilePage        (FR-VM-01, FR-VM-02)
       ├── /courts         → VenueCourtsPage          (FR-VM-03)
       ├── /hours          → VenueOperatingHoursPage  (operating hours config)
       ├── /products       → VenueProductsPage        (FR-VM-04)
       ├── /bookings       → VenueBookingsPage         (FR-VM-05, FR-VM-06)
       ├── /reviews        → VenueReviewsPage          (FR-VM-07)
       ├── /media          → VenueMediaPage            (FR-VM-08)
       └── /invoices       → VenueInvoicesPage         (FR-VM-09)
/*                    → NotFoundPage
```

### Route guards

**`AdminGuard`** (`src/guards/admin-guard.tsx`):
1. No token → redirect `/login`
2. Has token, has `ROLE_ADMIN` → render children
3. Has token, no `ROLE_ADMIN`, has `ROLE_VENUE_MANAGER` → redirect `/venue`
4. Has token, no admin role at all → redirect `/login`

**`VenueGuard`** — same pattern for `ROLE_VENUE_MANAGER`.

**Root redirect** (`/`):
- No token → `/login`
- `activeRole === 'ROLE_ADMIN'` → `/admin`
- `activeRole === 'ROLE_VENUE_MANAGER'` → `/venue`
- No `activeRole` but has token → `/select-role`

---

## 3. Auth Flow

### Login
1. User submits email + password on `LoginPage`.
2. `POST /api/auth` → `{ token, refreshToken, authenticated }`.
3. Decode JWT `scope` claim → `roles: string[]` (e.g. `["ROLE_ADMIN"]` or `["ROLE_ADMIN", "ROLE_VENUE_MANAGER"]`).
4. `setAuth({ token, refreshToken, user, roles })`.
5. **Single role:** `setActiveRole(roles[0])` → navigate to appropriate portal.
6. **Two roles:** navigate to `/select-role`.

### Role selection (`/select-role`)
- Shows two cards: "Admin Portal" (navy) and "Venue Manager" (green).
- User clicks one → `setActiveRole(role)` → navigate to portal.
- Only accessible when `token` exists; redirect `/login` if not.

### Role switching (sidebar button)
Available only when `roles.length > 1`:
1. `queryClient.clear()` — clear all cached data from previous role.
2. `setActiveRole(otherRole)`.
3. `navigate(otherRole === 'ROLE_ADMIN' ? '/admin' : '/venue')`.

### Logout
1. `POST /api/auth/logout` with `{ refreshToken }`.
2. `clearAuth()` in Zustand.
3. `queryClient.clear()`.
4. Navigate to `/login`.

---

## 4. API Client Layer

### `src/lib/axios.ts`

```ts
import axios from 'axios'
import { useAuthStore } from '@/store/auth'

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080/badbook/api',
  headers: { 'Content-Type': 'application/json' },
})

// Auto-attach JWT
api.interceptors.request.use(config => {
  const token = useAuthStore.getState().token
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// Handle 401 — clear auth and redirect to login
api.interceptors.response.use(
  res => res,
  err => {
    if (err.response?.status === 401) {
      useAuthStore.getState().clearAuth()
      window.location.href = '/login'
    }
    return Promise.reject(err)
  }
)
```

**Environment variable:** `VITE_API_BASE_URL` in `.env.local`. Add `VITE_API_BASE_URL=http://localhost:8080/badbook/api` to `.env.example`.

### `src/lib/query-client.ts`

```ts
import { QueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: { staleTime: 30_000, retry: 1 },
    mutations: {
      onError: (err: unknown) => {
        const msg = (err as any)?.response?.data?.message ?? 'Có lỗi xảy ra'
        toast.error(msg)
      },
    },
  },
})
```

### Feature hook pattern

Each feature exposes typed hooks in `src/hooks/admin/` or `src/hooks/venue/`:

```ts
// src/hooks/admin/use-admin-venues.ts
export const useAdminPendingVenues = (page = 1) =>
  useQuery({
    queryKey: ['admin', 'venues', 'pending', page],
    queryFn: () =>
      api.get<ApiResponse<PageResponse<VenueResponse>>>(`/venues/pending?page=${page}`)
         .then(r => r.data.data),
  })

export const useApproveVenue = () =>
  useMutation({
    mutationFn: (id: string) => api.put(`/venues/${id}/approve`),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['admin', 'venues'] }),
  })
```

### `ApiResponse<T>` type

Mirrors backend envelope:
```ts
// src/types/api.ts
export interface ApiResponse<T> {
  code: number
  message: string | null
  data: T
}

export interface PageResponse<T> {
  content: T[]
  totalElements: number
  totalPages: number
  currentPage: number
  pageSize: number
}
```

---

## 5. Zustand Auth Store Update

```ts
// src/store/auth.ts
interface AuthUser {
  id: string
  name: string
  email: string
}

interface AuthState {
  token: string | null
  refreshToken: string | null
  user: AuthUser | null
  roles: string[]            // ['ROLE_ADMIN'] | ['ROLE_VENUE_MANAGER'] | both
  activeRole: string | null  // currently active role
  setAuth: (payload: { token: string; refreshToken: string; user: AuthUser; roles: string[] }) => void
  setActiveRole: (role: string) => void
  clearAuth: () => void
}
```

`setAuth` implementation parses `roles` from JWT `scope` claim. The backend encodes roles as a space-separated string (e.g. `"ROLE_ADMIN ROLE_VENUE_MANAGER"`), so split on space:
```ts
setAuth: ({ token, refreshToken, user, roles }) =>
  set({ token, refreshToken, user, roles, activeRole: roles.length === 1 ? roles[0] : null })
```

`getRolesFromToken(token: string): string[]` in `src/hooks/use-auth.ts` decodes the JWT locally (no API call):
```ts
export const getRolesFromToken = (token: string): string[] => {
  try {
    const payload = JSON.parse(atob(token.split('.')[1]))
    return (payload.scope as string ?? '').split(' ').filter(Boolean)
  } catch { return [] }
}
```
This is called in `LoginPage` after a successful `/api/auth` response to populate `roles` before calling `setAuth`.

`clearAuth` resets all fields to null/empty.

Storage key: `badminton-portal-auth` (rename from `badminton-admin-auth` to reflect dual-portal).

---

## 6. Shared Layout — `PortalLayout`

### Props

```ts
interface NavItem { icon: LucideIcon; label: string; to: string }
interface NavGroup { label: string; items: NavItem[] }

interface PortalLayoutProps {
  navGroups: NavGroup[]
  accentColor: string      // '#132D77' (admin) | '#0d7c5f' (venue)
  roleLabel: string        // 'ADMIN' | 'VENUE MGR'
  roleIcon: LucideIcon     // Zap (admin) | Dumbbell (venue)
  otherRole?: string       // present only when user has both roles
  onSwitchRole?: () => void
}
```

### Structure

```
PortalLayout
├── <aside> Sidebar (fixed, collapsible w-64 ↔ w-16)
│   ├── Brand logo + role badge (accentColor)
│   ├── NavGroups (map → NavGroup → NavItems)
│   ├── Collapse toggle button
│   └── [conditional] Switch role button (shown only when otherRole present)
├── <div> Main area
│   ├── <header> Top bar (sticky h-14)
│   │   ├── Sidebar toggle (mobile)
│   │   ├── Search input (placeholder, non-functional in foundation)
│   │   ├── Theme toggle
│   │   ├── Language toggle
│   │   └── User avatar dropdown (name + logout)
│   └── <main> <Outlet /> with padding
```

### AdminLayout

```tsx
// src/components/layouts/admin-layout.tsx
const adminNavGroups: NavGroup[] = [
  { label: 'Tổng quan', items: [{ icon: LayoutDashboard, label: 'Dashboard', to: '/admin' }] },
  { label: 'Quản lý', items: [
    { icon: CheckSquare, label: 'Duyệt venue', to: '/admin/venues' },
    { icon: Users, label: 'Users', to: '/admin/users' },
    { icon: Receipt, label: 'Invoices', to: '/admin/invoices' },
    { icon: Star, label: 'Reviews', to: '/admin/reviews' },
  ]},
]

export const AdminLayout = () => {
  const { roles, activeRole, setActiveRole } = useAuthStore()
  const navigate = useNavigate()
  const hasVenueRole = roles.includes('ROLE_VENUE_MANAGER')

  const handleSwitch = () => {
    queryClient.clear()
    setActiveRole('ROLE_VENUE_MANAGER')
    navigate('/venue')
  }

  return (
    <PortalLayout
      navGroups={adminNavGroups}
      accentColor="#132D77"
      roleLabel="ADMIN"
      roleIcon={Zap}
      otherRole={hasVenueRole ? 'VENUE MGR' : undefined}
      onSwitchRole={hasVenueRole ? handleSwitch : undefined}
    />
  )
}
```

### VenueLayout

Same pattern with `accentColor="#0d7c5f"`, `roleLabel="VENUE MGR"`, `roleIcon={Dumbbell}`, venue nav groups.

---

## 7. Shared UI Components to Add

| Component | Purpose | Used by |
|-----------|---------|---------|
| `DataTable` | Sortable table with pagination, loading skeleton | All list pages |
| `Modal` | Dialog wrapper with header/body/footer slots | Confirm dialogs, forms |
| `FormField` | Input/Select with label, error message | All forms |
| `StatusBadge` | Already exists — keep | Status columns |
| `StatCard` | Already exists — keep | Dashboard pages |

These components have no API dependency and can be built as pure presentational components in the foundation phase.

---

## 8. New Files Summary

### Add
| File | Purpose |
|------|---------|
| `src/lib/axios.ts` | Axios instance |
| `src/lib/query-client.ts` | TanStack QueryClient |
| `src/types/api.ts` | ApiResponse, PageResponse types |
| `src/guards/admin-guard.tsx` | Route protection for /admin |
| `src/guards/venue-guard.tsx` | Route protection for /venue |
| `src/hooks/use-auth.ts` | getRolesFromToken, isAdmin, isVenueManager helpers |
| `src/components/layouts/portal-layout.tsx` | Shared layout |
| `src/components/layouts/admin-layout.tsx` | Admin-specific layout wrapper |
| `src/components/layouts/venue-layout.tsx` | Venue-specific layout wrapper |
| `src/components/ui/data-table.tsx` | Reusable table |
| `src/components/ui/modal.tsx` | Dialog wrapper |
| `src/components/ui/form-field.tsx` | Form input wrapper |
| `src/pages/login/index.tsx` | Login page (replaces existing) |
| `src/pages/select-role/index.tsx` | Role selection page |
| `src/pages/admin/dashboard.tsx` | Placeholder (stats only) |
| `src/pages/venue/dashboard.tsx` | Placeholder (venue summary) |
| `.env.example` | Add VITE_API_BASE_URL |

### Update
| File | Change |
|------|--------|
| `src/store/auth.ts` | Add roles, activeRole, refreshToken |
| `src/router.tsx` | New route structure with guards |
| `package.json` | Add axios, @tanstack/react-query |
| `src/main.tsx` | Wrap app in QueryClientProvider |

### Delete
| File | Reason |
|------|--------|
| `src/components/layouts/admin-layout.tsx` (old) | Replaced by portal-layout + admin-layout |
| `src/pages/admin/*.tsx` (all 9 existing pages) | Rewritten |

---

## 9. Out of Scope (Foundation)

- Admin feature pages (FR-ADM-01–06) — separate spec
- Venue Manager feature pages (FR-VM-01–09) — separate spec
- Search functionality (header search bar stays non-functional)
- Push notifications
- Refresh token auto-rotation (access token refresh on expiry)
