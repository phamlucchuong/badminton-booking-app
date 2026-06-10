# Web Portal Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewrite `apps/web-admin` from a mock-data admin prototype into a dual-portal SPA (Admin + Venue Manager) with real JWT auth, Axios + TanStack Query API layer, shared `PortalLayout`, and route-based role guards.

**Architecture:** `PortalLayout` is the single shared layout component — `AdminLayout` and `VenueLayout` are thin wrappers that pass nav groups and accent colors. Route guards (`AdminGuard`, `VenueGuard`) protect `/admin` and `/venue` subtrees. All API calls go through a single Axios instance that auto-attaches JWT and clears auth on 401. TanStack Query manages server state for all feature pages (built in later specs).

**Tech Stack:** React 19, React Router DOM v6, Zustand v5, Tailwind CSS v4, Axios, TanStack Query v5, Lucide React, Sonner

---

## File Map

### Create
| File | Purpose |
|------|---------|
| `apps/web-admin/src/types/api.ts` | `ApiResponse<T>` and `PageResponse<T>` types |
| `apps/web-admin/src/lib/query-client.ts` | TanStack `QueryClient` singleton |
| `apps/web-admin/src/lib/axios.ts` | Axios instance with JWT + 401 interceptors |
| `apps/web-admin/src/hooks/use-auth.ts` | `getRolesFromToken`, `useAuth` helpers |
| `apps/web-admin/src/guards/admin-guard.tsx` | Protects `/admin` subtree |
| `apps/web-admin/src/guards/venue-guard.tsx` | Protects `/venue` subtree |
| `apps/web-admin/src/components/layouts/portal-layout.tsx` | Shared sidebar + header layout |
| `apps/web-admin/src/components/layouts/venue-layout.tsx` | Venue-specific layout wrapper |
| `apps/web-admin/src/components/ui/data-table.tsx` | Typed table with loading skeleton |
| `apps/web-admin/src/components/ui/modal.tsx` | Dialog wrapper with header/body/footer |
| `apps/web-admin/src/components/ui/form-field.tsx` | Input + Select with label/error |
| `apps/web-admin/src/pages/login/index.tsx` | Login page with real API call |
| `apps/web-admin/src/pages/select-role/index.tsx` | Role selection for dual-role users |
| `apps/web-admin/src/pages/admin/dashboard.tsx` | Admin dashboard stub |
| `apps/web-admin/src/pages/admin/venues.tsx` | Venue approval stub |
| `apps/web-admin/src/pages/admin/users.tsx` | User management stub |
| `apps/web-admin/src/pages/admin/invoices.tsx` | Invoices stub |
| `apps/web-admin/src/pages/admin/reviews.tsx` | Review moderation stub |
| `apps/web-admin/src/pages/venue/dashboard.tsx` | Venue dashboard stub |
| `apps/web-admin/src/pages/venue/profile.tsx` | Venue profile stub |
| `apps/web-admin/src/pages/venue/courts.tsx` | Courts management stub |
| `apps/web-admin/src/pages/venue/hours.tsx` | Operating hours stub |
| `apps/web-admin/src/pages/venue/products.tsx` | Products stub |
| `apps/web-admin/src/pages/venue/bookings.tsx` | Bookings stub |
| `apps/web-admin/src/pages/venue/reviews.tsx` | Reviews stub |
| `apps/web-admin/src/pages/venue/media.tsx` | Media upload stub |
| `apps/web-admin/src/pages/venue/invoices.tsx` | Invoices stub |

### Modify
| File | Change |
|------|--------|
| `apps/web-admin/package.json` | Add `axios`, `@tanstack/react-query` |
| `apps/web-admin/src/main.tsx` | Wrap app in `QueryClientProvider` |
| `apps/web-admin/src/store/auth.ts` | Add `refreshToken`, `roles`, `activeRole` |
| `apps/web-admin/src/components/layouts/admin-layout.tsx` | Rewrite — thin wrapper over `PortalLayout` |
| `apps/web-admin/src/router.tsx` | New dual-portal route tree with guards |
| `apps/web-admin/src/lib/copy.ts` | Add new i18n keys |
| `apps/web-admin/.env.example` | Update `VITE_API_BASE_URL` with `/api` suffix |

### Delete
| File | Reason |
|------|--------|
| `apps/web-admin/src/pages/sign-in-page.tsx` | Replaced by `pages/login/index.tsx` |
| `apps/web-admin/src/pages/admin/admin-ai-config-page.tsx` | Not in badminton spec |
| `apps/web-admin/src/pages/admin/admin-audit-logs-page.tsx` | Not in badminton spec |
| `apps/web-admin/src/pages/admin/admin-employer-verification-page.tsx` | Not in badminton spec |
| `apps/web-admin/src/pages/admin/admin-job-moderation-page.tsx` | Not in badminton spec |
| `apps/web-admin/src/pages/admin/admin-packages-page.tsx` | Not in badminton spec |
| `apps/web-admin/src/pages/admin/admin-payments-page.tsx` | Not in badminton spec |
| `apps/web-admin/src/pages/admin/admin-rbac-page.tsx` | Not in badminton spec |
| `apps/web-admin/src/pages/admin/admin-settings-page.tsx` | Not in badminton spec |
| `apps/web-admin/src/pages/admin/admin-dashboard-page.tsx` | Replaced by `pages/admin/dashboard.tsx` |
| `apps/web-admin/src/pages/admin/admin-users-page.tsx` | Replaced by `pages/admin/users.tsx` |

---

## Task 1: Install Dependencies + Type Definitions + QueryClient

**Files:**
- Modify: `apps/web-admin/package.json`
- Create: `apps/web-admin/src/types/api.ts`
- Create: `apps/web-admin/src/lib/query-client.ts`
- Modify: `apps/web-admin/src/main.tsx`

- [ ] **Step 1: Install axios and TanStack Query**

From the repo root:
```bash
cd apps/web-admin && pnpm add axios @tanstack/react-query
```

Expected: both packages appear in `dependencies` in `package.json`.

- [ ] **Step 2: Create `src/types/api.ts`**

```ts
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

- [ ] **Step 3: Create `src/lib/query-client.ts`**

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

- [ ] **Step 4: Update `src/main.tsx` to wrap with QueryClientProvider**

```tsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { QueryClientProvider } from '@tanstack/react-query'
import './index.css'
import App from './App'
import { queryClient } from '@/lib/query-client'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <App />
    </QueryClientProvider>
  </StrictMode>,
)
```

- [ ] **Step 5: Verify TypeScript compiles**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit
```

Expected: no errors.

- [ ] **Step 6: Commit**

```bash
git add apps/web-admin/package.json apps/web-admin/pnpm-lock.yaml \
        apps/web-admin/src/types/api.ts apps/web-admin/src/lib/query-client.ts \
        apps/web-admin/src/main.tsx
git commit -m "feat(web-admin): install axios + tanstack-query, add API types and QueryClient"
```

---

## Task 2: Update Zustand Auth Store

**Files:**
- Modify: `apps/web-admin/src/store/auth.ts`

- [ ] **Step 1: Rewrite `src/store/auth.ts`**

Full replacement (adds `refreshToken`, `roles`, `activeRole`; renames storage key):

```ts
import { create } from 'zustand'
import { persist } from 'zustand/middleware'

interface AuthUser {
  id: string
  name: string
  email: string
}

interface AuthState {
  token: string | null
  refreshToken: string | null
  user: AuthUser | null
  roles: string[]
  activeRole: string | null
  setAuth: (payload: {
    token: string
    refreshToken: string
    user: AuthUser
    roles: string[]
  }) => void
  setActiveRole: (role: string) => void
  clearAuth: () => void
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      token: null,
      refreshToken: null,
      user: null,
      roles: [],
      activeRole: null,
      setAuth: ({ token, refreshToken, user, roles }) =>
        set({
          token,
          refreshToken,
          user,
          roles,
          activeRole: roles.length === 1 ? roles[0] : null,
        }),
      setActiveRole: (role) => set({ activeRole: role }),
      clearAuth: () =>
        set({ token: null, refreshToken: null, user: null, roles: [], activeRole: null }),
    }),
    { name: 'badminton-portal-auth' },
  ),
)
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit
```

Expected: no errors (the old `admin-layout.tsx` will error because it calls `setAuth` with the old signature — that's expected and will be fixed in Task 7).

- [ ] **Step 3: Commit**

```bash
git add apps/web-admin/src/store/auth.ts
git commit -m "feat(web-admin): extend auth store with roles, activeRole, refreshToken"
```

---

## Task 3: Axios Instance + .env

**Files:**
- Create: `apps/web-admin/src/lib/axios.ts`
- Modify: `apps/web-admin/.env.example`

- [ ] **Step 1: Create `src/lib/axios.ts`**

```ts
import axios from 'axios'
import { useAuthStore } from '@/store/auth'

export const api = axios.create({
  baseURL:
    import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080/badbook/api',
  headers: { 'Content-Type': 'application/json' },
})

api.interceptors.request.use((config) => {
  const token = useAuthStore.getState().token
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

api.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) {
      useAuthStore.getState().clearAuth()
      window.location.href = '/login'
    }
    return Promise.reject(err)
  },
)
```

- [ ] **Step 2: Update `.env.example`**

Replace the existing single line:
```
VITE_API_BASE_URL=http://localhost:8080/badbook/api
VITE_WEB_ADMIN_PORT=3002
```

- [ ] **Step 3: Commit**

```bash
git add apps/web-admin/src/lib/axios.ts apps/web-admin/.env.example
git commit -m "feat(web-admin): add Axios instance with JWT interceptor and 401 auto-logout"
```

---

## Task 4: useAuth Hook

**Files:**
- Create: `apps/web-admin/src/hooks/use-auth.ts`

- [ ] **Step 1: Create `src/hooks/use-auth.ts`**

```ts
import { useAuthStore } from '@/store/auth'

export const getRolesFromToken = (token: string): string[] => {
  try {
    const payload = JSON.parse(atob(token.split('.')[1]))
    return ((payload.scope as string) ?? '').split(' ').filter(Boolean)
  } catch {
    return []
  }
}

export function useAuth() {
  const { token, roles, activeRole } = useAuthStore()
  return {
    isLoggedIn: !!token,
    isAdmin: roles.includes('ROLE_ADMIN'),
    isVenueManager: roles.includes('ROLE_VENUE_MANAGER'),
    isDualRole: roles.length > 1,
    activeRole,
  }
}
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit
```

- [ ] **Step 3: Commit**

```bash
git add apps/web-admin/src/hooks/use-auth.ts
git commit -m "feat(web-admin): add getRolesFromToken and useAuth hook"
```

---

## Task 5: Route Guards

**Files:**
- Create: `apps/web-admin/src/guards/admin-guard.tsx`
- Create: `apps/web-admin/src/guards/venue-guard.tsx`

- [ ] **Step 1: Create `src/guards/admin-guard.tsx`**

```tsx
import type { ReactNode } from 'react'
import { Navigate } from 'react-router-dom'
import { useAuthStore } from '@/store/auth'

export function AdminGuard({ children }: { children: ReactNode }) {
  const { token, roles } = useAuthStore()
  if (!token) return <Navigate to="/login" replace />
  if (roles.includes('ROLE_ADMIN')) return <>{children}</>
  if (roles.includes('ROLE_VENUE_MANAGER')) return <Navigate to="/venue" replace />
  return <Navigate to="/login" replace />
}
```

- [ ] **Step 2: Create `src/guards/venue-guard.tsx`**

```tsx
import type { ReactNode } from 'react'
import { Navigate } from 'react-router-dom'
import { useAuthStore } from '@/store/auth'

export function VenueGuard({ children }: { children: ReactNode }) {
  const { token, roles } = useAuthStore()
  if (!token) return <Navigate to="/login" replace />
  if (roles.includes('ROLE_VENUE_MANAGER')) return <>{children}</>
  if (roles.includes('ROLE_ADMIN')) return <Navigate to="/admin" replace />
  return <Navigate to="/login" replace />
}
```

- [ ] **Step 3: Commit**

```bash
git add apps/web-admin/src/guards/
git commit -m "feat(web-admin): add AdminGuard and VenueGuard route protection"
```

---

## Task 6: Update `copy.ts` with New Keys

**Files:**
- Modify: `apps/web-admin/src/lib/copy.ts`

`PortalLayout` and new pages need several keys that don't exist yet. Add them to both `EN` and `VI` objects.

- [ ] **Step 1: Add keys to `copy.ts`**

In `src/lib/copy.ts`, inside **both** the `EN` and `VI` objects, add the following keys after the existing `forgotPassword` line:

**EN additions:**
```ts
    logout: 'Sign out',
    loading: 'Loading...',
    loginError: 'Invalid email or password',
    selectRoleTitle: 'Choose a portal',
    selectRoleDesc: 'You have access to multiple portals. Select one to continue.',
    adminPortal: 'Admin Portal',
    adminPortalDesc: 'Manage venues, users, invoices and platform settings.',
    venuePortal: 'Venue Manager Portal',
    venuePortalDesc: 'Manage your courts, bookings, products and reviews.',
```

**VI additions:**
```ts
    logout: 'Đăng xuất',
    loading: 'Đang xử lý...',
    loginError: 'Email hoặc mật khẩu không đúng',
    selectRoleTitle: 'Chọn giao diện',
    selectRoleDesc: 'Tài khoản của bạn có nhiều vai trò. Chọn giao diện để tiếp tục.',
    adminPortal: 'Cổng Quản trị',
    adminPortalDesc: 'Quản lý sân, người dùng, hóa đơn và cài đặt hệ thống.',
    venuePortal: 'Cổng Quản lý Sân',
    venuePortalDesc: 'Quản lý sân, booking, sản phẩm và đánh giá.',
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit
```

- [ ] **Step 3: Commit**

```bash
git add apps/web-admin/src/lib/copy.ts
git commit -m "feat(web-admin): add portal i18n keys to copy.ts"
```

---

## Task 7: PortalLayout + AdminLayout Rewrite + VenueLayout

**Files:**
- Create: `apps/web-admin/src/components/layouts/portal-layout.tsx`
- Modify: `apps/web-admin/src/components/layouts/admin-layout.tsx` (full rewrite)
- Create: `apps/web-admin/src/components/layouts/venue-layout.tsx`

- [ ] **Step 1: Create `src/components/layouts/portal-layout.tsx`**

```tsx
import {
  ChevronDown,
  Menu,
  Moon,
  Search,
  Sun,
  type LucideIcon,
} from 'lucide-react'
import { useState, type ReactNode } from 'react'
import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { useCopy } from '@/lib/copy'
import { queryClient } from '@/lib/query-client'
import { api } from '@/lib/axios'
import { cn } from '@/lib/utils'
import { useAuthStore } from '@/store/auth'
import { usePreferencesStore } from '@/store/preferences'

export interface NavItem {
  icon: LucideIcon
  label: string
  to: string
}

export interface NavGroup {
  key: string
  label: string
  items: NavItem[]
}

interface PortalLayoutProps {
  navGroups: NavGroup[]
  accentColor: string
  roleLabel: string
  roleIcon: LucideIcon
  otherRole?: string
  onSwitchRole?: () => void
}

export function PortalLayout({
  navGroups,
  accentColor,
  roleLabel,
  roleIcon: RoleIcon,
  otherRole,
  onSwitchRole,
}: PortalLayoutProps) {
  const copy = useCopy()
  const navigate = useNavigate()
  const { pathname } = useLocation()
  const [collapsed, setCollapsed] = useState(false)
  const [openGroups, setOpenGroups] = useState<Record<string, boolean>>({})
  const theme = usePreferencesStore((s) => s.theme)
  const toggleTheme = usePreferencesStore((s) => s.toggleTheme)
  const toggleLanguage = usePreferencesStore((s) => s.toggleLanguage)
  const language = usePreferencesStore((s) => s.language)
  const user = useAuthStore((s) => s.user)
  const refreshToken = useAuthStore((s) => s.refreshToken)
  const clearAuth = useAuthStore((s) => s.clearAuth)

  const handleLogout = async () => {
    try {
      await api.post('/auth/logout', { refreshToken })
    } catch {
      // always clear locally even if request fails
    }
    clearAuth()
    queryClient.clear()
    navigate('/login')
  }

  return (
    <div className="flex min-h-screen bg-background">
      <aside
        className={cn(
          'sticky top-0 flex h-screen flex-col border-r border-sidebar-border bg-sidebar transition-all',
          collapsed ? 'w-16' : 'w-64',
        )}
      >
        <div className="flex h-16 items-center border-b border-sidebar-border px-4">
          <div className="flex min-w-0 items-center gap-2">
            <div
              className="flex size-8 shrink-0 items-center justify-center rounded-lg text-white"
              style={{ backgroundColor: accentColor }}
            >
              <RoleIcon className="size-4" />
            </div>
            {!collapsed && (
              <div className="min-w-0">
                <div className="truncate text-sm font-bold">{copy.brand}</div>
                <div
                  className="mt-0.5 inline-block rounded px-1.5 py-0 text-[9px] font-semibold uppercase tracking-wide text-white"
                  style={{ backgroundColor: accentColor }}
                >
                  {roleLabel}
                </div>
              </div>
            )}
          </div>
        </div>

        <nav className="flex-1 space-y-1 overflow-y-auto p-2">
          {navGroups.map((group) => {
            const groupHasActive = group.items.some(
              (item) =>
                pathname === item.to ||
                (item.to !== '/admin' &&
                  item.to !== '/venue' &&
                  pathname.startsWith(item.to)),
            )

            if (group.items.length === 1) {
              const item = group.items[0]
              return (
                <PortalNavLink
                  key={item.to}
                  to={item.to}
                  icon={<item.icon className="size-4" />}
                  label={item.label}
                  collapsed={collapsed}
                  accentColor={accentColor}
                />
              )
            }

            const expanded = collapsed
              ? false
              : (openGroups[group.key] ?? groupHasActive ?? true)

            return (
              <div key={group.key} className="space-y-0.5">
                <button
                  type="button"
                  onClick={() =>
                    setOpenGroups((s) => ({ ...s, [group.key]: !expanded }))
                  }
                  className={cn(
                    'flex w-full items-center rounded-lg px-2 py-1.5 text-xs font-semibold uppercase tracking-wide text-muted-foreground hover:bg-sidebar-accent',
                    collapsed && 'justify-center px-0',
                  )}
                >
                  {!collapsed && (
                    <span className="truncate">{group.label}</span>
                  )}
                  {!collapsed && (
                    <ChevronDown
                      className={cn(
                        'ml-auto size-3.5 transition-transform',
                        expanded && 'rotate-180',
                      )}
                    />
                  )}
                  {collapsed && (
                    <div
                      className={cn(
                        'size-1.5 rounded-full',
                        groupHasActive
                          ? 'bg-primary'
                          : 'bg-muted-foreground/40',
                      )}
                    />
                  )}
                </button>

                {expanded &&
                  group.items.map((item) => (
                    <PortalNavLink
                      key={item.to}
                      to={item.to}
                      icon={<item.icon className="size-4" />}
                      label={item.label}
                      collapsed={collapsed}
                      accentColor={accentColor}
                    />
                  ))}
              </div>
            )
          })}
        </nav>

        <div className="space-y-1 p-2">
          {otherRole && onSwitchRole && !collapsed && (
            <button
              type="button"
              onClick={onSwitchRole}
              className="w-full rounded-lg border border-border px-3 py-2 text-xs text-muted-foreground hover:bg-accent"
            >
              ↔ {otherRole}
            </button>
          )}
          <button
            type="button"
            onClick={() => setCollapsed((v) => !v)}
            className="w-full rounded-lg border border-border px-3 py-2 text-xs text-muted-foreground hover:bg-accent"
          >
            {collapsed ? (
              <Menu className="mx-auto size-4" />
            ) : (
              copy.collapseSidebar
            )}
          </button>
        </div>
      </aside>

      <div className="flex min-w-0 flex-1 flex-col">
        <header className="sticky top-0 z-20 flex h-16 items-center gap-3 border-b border-border bg-card px-5">
          <div className="relative max-w-md flex-1">
            <Search className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
            <input
              placeholder={copy.searchPlaceholder}
              className="h-9 w-full rounded-lg border border-input bg-background pl-9 pr-3 text-sm"
            />
          </div>

          <div className="ml-auto flex items-center gap-2">
            <button
              type="button"
              onClick={toggleLanguage}
              className="relative flex h-9 w-[84px] cursor-pointer items-center rounded-lg border border-border bg-muted/60 p-1 text-xs"
            >
              <span
                className={cn(
                  'absolute top-1 h-7 w-9 rounded-md bg-primary transition-transform duration-200',
                  language === 'EN' ? 'translate-x-0' : 'translate-x-[38px]',
                )}
              />
              <span
                className={cn(
                  'relative z-10 w-9 text-center transition-colors duration-200',
                  language === 'EN'
                    ? 'text-primary-foreground'
                    : 'text-muted-foreground',
                )}
              >
                EN
              </span>
              <span
                className={cn(
                  'relative z-10 w-9 text-center transition-colors duration-200',
                  language === 'VI'
                    ? 'text-primary-foreground'
                    : 'text-muted-foreground',
                )}
              >
                VI
              </span>
            </button>

            <Button
              variant="outline"
              size="icon"
              onClick={toggleTheme}
              className="h-9 w-9 bg-muted/60 text-muted-foreground"
            >
              {theme === 'dark' ? (
                <Sun className="size-4" />
              ) : (
                <Moon className="size-4" />
              )}
            </Button>

            <button
              type="button"
              onClick={handleLogout}
              className="flex items-center gap-2 rounded-lg px-2 py-1.5 hover:bg-accent"
            >
              <div
                className="flex size-8 shrink-0 items-center justify-center rounded-full text-xs font-bold text-white"
                style={{ backgroundColor: accentColor }}
              >
                {(user?.name ?? 'U').slice(0, 1).toUpperCase()}
              </div>
              <div className="hidden text-left md:block">
                <div className="text-sm font-medium">
                  {user?.name ?? 'User'}
                </div>
                <div className="text-xs text-muted-foreground">
                  {copy.logout}
                </div>
              </div>
            </button>
          </div>
        </header>

        <main className="mx-auto w-full max-w-[1600px] flex-1 p-6">
          <Outlet />
        </main>
      </div>
    </div>
  )
}

interface PortalNavLinkProps {
  to: string
  icon: ReactNode
  label: string
  collapsed: boolean
  accentColor: string
}

function PortalNavLink({
  to,
  icon,
  label,
  collapsed,
  accentColor,
}: PortalNavLinkProps) {
  return (
    <NavLink
      to={to}
      end={to === '/admin' || to === '/venue'}
      className={({ isActive }) =>
        cn(
          'flex items-center gap-3 rounded-lg border border-transparent px-3 py-2 text-sm',
          isActive
            ? 'font-semibold'
            : 'text-sidebar-foreground hover:bg-sidebar-accent',
          collapsed && 'justify-center px-0',
        )
      }
      style={({ isActive }) =>
        isActive
          ? {
              color: accentColor,
              borderColor: `${accentColor}33`,
              backgroundColor: `${accentColor}1a`,
            }
          : {}
      }
    >
      {icon}
      {!collapsed && <span>{label}</span>}
    </NavLink>
  )
}
```

- [ ] **Step 2: Rewrite `src/components/layouts/admin-layout.tsx`**

Full replacement (thin wrapper over PortalLayout):

```tsx
import {
  CheckSquare,
  LayoutDashboard,
  Receipt,
  Star,
  Users,
  Zap,
} from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { queryClient } from '@/lib/query-client'
import { useAuthStore } from '@/store/auth'
import { type NavGroup, PortalLayout } from './portal-layout'

const adminNavGroups: NavGroup[] = [
  {
    key: 'overview',
    label: 'Tổng quan',
    items: [{ icon: LayoutDashboard, label: 'Dashboard', to: '/admin' }],
  },
  {
    key: 'manage',
    label: 'Quản lý',
    items: [
      { icon: CheckSquare, label: 'Duyệt venue', to: '/admin/venues' },
      { icon: Users, label: 'Users', to: '/admin/users' },
      { icon: Receipt, label: 'Invoices', to: '/admin/invoices' },
      { icon: Star, label: 'Reviews', to: '/admin/reviews' },
    ],
  },
]

export function AdminLayout() {
  const { roles, setActiveRole } = useAuthStore()
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

- [ ] **Step 3: Create `src/components/layouts/venue-layout.tsx`**

```tsx
import {
  Building2,
  CalendarDays,
  Clock,
  Dumbbell,
  Image,
  LayoutDashboard,
  Package,
  Receipt,
  Layers,
  Star,
  Zap,
} from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { queryClient } from '@/lib/query-client'
import { useAuthStore } from '@/store/auth'
import { type NavGroup, PortalLayout } from './portal-layout'

const venueNavGroups: NavGroup[] = [
  {
    key: 'overview',
    label: 'Tổng quan',
    items: [{ icon: LayoutDashboard, label: 'Dashboard', to: '/venue' }],
  },
  {
    key: 'facility',
    label: 'Cơ sở',
    items: [
      { icon: Building2, label: 'Thông tin venue', to: '/venue/profile' },
      { icon: Layers, label: 'Quản lý sân', to: '/venue/courts' },
      { icon: Clock, label: 'Giờ hoạt động', to: '/venue/hours' },
      { icon: Package, label: 'Sản phẩm', to: '/venue/products' },
      { icon: Image, label: 'Media', to: '/venue/media' },
    ],
  },
  {
    key: 'operations',
    label: 'Vận hành',
    items: [
      { icon: CalendarDays, label: 'Bookings', to: '/venue/bookings' },
      { icon: Star, label: 'Đánh giá', to: '/venue/reviews' },
      { icon: Receipt, label: 'Hóa đơn', to: '/venue/invoices' },
    ],
  },
]

export function VenueLayout() {
  const { roles, setActiveRole } = useAuthStore()
  const navigate = useNavigate()
  const hasAdminRole = roles.includes('ROLE_ADMIN')

  const handleSwitch = () => {
    queryClient.clear()
    setActiveRole('ROLE_ADMIN')
    navigate('/admin')
  }

  return (
    <PortalLayout
      navGroups={venueNavGroups}
      accentColor="#0d7c5f"
      roleLabel="VENUE MGR"
      roleIcon={Dumbbell}
      otherRole={hasAdminRole ? 'ADMIN' : undefined}
      onSwitchRole={hasAdminRole ? handleSwitch : undefined}
    />
  )
}
```

- [ ] **Step 4: Verify TypeScript compiles (errors on router expected)**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit 2>&1 | head -30
```

Expected: errors only in `router.tsx` (old imports) and `sign-in-page.tsx` (old `setAuth` signature). Layout files should be clean.

- [ ] **Step 5: Commit**

```bash
git add apps/web-admin/src/components/layouts/
git commit -m "feat(web-admin): add PortalLayout, rewrite AdminLayout, add VenueLayout"
```

---

## Task 8: Scaffold All Page Stubs

Create minimal stub components for every route. These will be filled in by future feature specs.

**Files:**
- Create: `apps/web-admin/src/pages/admin/dashboard.tsx`
- Create: `apps/web-admin/src/pages/admin/venues.tsx`
- Create: `apps/web-admin/src/pages/admin/users.tsx`
- Create: `apps/web-admin/src/pages/admin/invoices.tsx`
- Create: `apps/web-admin/src/pages/admin/reviews.tsx`
- Create: `apps/web-admin/src/pages/venue/dashboard.tsx`
- Create: `apps/web-admin/src/pages/venue/profile.tsx`
- Create: `apps/web-admin/src/pages/venue/courts.tsx`
- Create: `apps/web-admin/src/pages/venue/hours.tsx`
- Create: `apps/web-admin/src/pages/venue/products.tsx`
- Create: `apps/web-admin/src/pages/venue/bookings.tsx`
- Create: `apps/web-admin/src/pages/venue/reviews.tsx`
- Create: `apps/web-admin/src/pages/venue/media.tsx`
- Create: `apps/web-admin/src/pages/venue/invoices.tsx`
- Delete: all 11 old admin page files listed in File Map

- [ ] **Step 1: Create admin page stubs**

`apps/web-admin/src/pages/admin/dashboard.tsx`:
```tsx
export function AdminDashboardPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">Dashboard</h1>
      <p className="mt-1 text-sm text-muted-foreground">Tổng quan hệ thống — coming soon</p>
    </div>
  )
}
```

`apps/web-admin/src/pages/admin/venues.tsx`:
```tsx
export function AdminVenuesPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">Duyệt venue</h1>
      <p className="mt-1 text-sm text-muted-foreground">Venue approval — coming soon</p>
    </div>
  )
}
```

`apps/web-admin/src/pages/admin/users.tsx`:
```tsx
export function AdminUsersPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">Users</h1>
      <p className="mt-1 text-sm text-muted-foreground">User management — coming soon</p>
    </div>
  )
}
```

`apps/web-admin/src/pages/admin/invoices.tsx`:
```tsx
export function AdminInvoicesPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">Invoices</h1>
      <p className="mt-1 text-sm text-muted-foreground">Platform invoices — coming soon</p>
    </div>
  )
}
```

`apps/web-admin/src/pages/admin/reviews.tsx`:
```tsx
export function AdminReviewsPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">Reviews</h1>
      <p className="mt-1 text-sm text-muted-foreground">Review moderation — coming soon</p>
    </div>
  )
}
```

- [ ] **Step 2: Create venue page stubs**

`apps/web-admin/src/pages/venue/dashboard.tsx`:
```tsx
export function VenueDashboardPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">Dashboard</h1>
      <p className="mt-1 text-sm text-muted-foreground">Tổng quan sân — coming soon</p>
    </div>
  )
}
```

`apps/web-admin/src/pages/venue/profile.tsx`:
```tsx
export function VenueProfilePage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">Thông tin venue</h1>
      <p className="mt-1 text-sm text-muted-foreground">Venue profile — coming soon</p>
    </div>
  )
}
```

`apps/web-admin/src/pages/venue/courts.tsx`:
```tsx
export function VenueCourtsPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">Quản lý sân</h1>
      <p className="mt-1 text-sm text-muted-foreground">Court management — coming soon</p>
    </div>
  )
}
```

`apps/web-admin/src/pages/venue/hours.tsx`:
```tsx
export function VenueHoursPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">Giờ hoạt động</h1>
      <p className="mt-1 text-sm text-muted-foreground">Operating hours — coming soon</p>
    </div>
  )
}
```

`apps/web-admin/src/pages/venue/products.tsx`:
```tsx
export function VenueProductsPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">Sản phẩm</h1>
      <p className="mt-1 text-sm text-muted-foreground">Products — coming soon</p>
    </div>
  )
}
```

`apps/web-admin/src/pages/venue/bookings.tsx`:
```tsx
export function VenueBookingsPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">Bookings</h1>
      <p className="mt-1 text-sm text-muted-foreground">Booking management — coming soon</p>
    </div>
  )
}
```

`apps/web-admin/src/pages/venue/reviews.tsx`:
```tsx
export function VenueReviewsPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">Đánh giá</h1>
      <p className="mt-1 text-sm text-muted-foreground">Reviews — coming soon</p>
    </div>
  )
}
```

`apps/web-admin/src/pages/venue/media.tsx`:
```tsx
export function VenueMediaPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">Media</h1>
      <p className="mt-1 text-sm text-muted-foreground">Media uploads — coming soon</p>
    </div>
  )
}
```

`apps/web-admin/src/pages/venue/invoices.tsx`:
```tsx
export function VenueInvoicesPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold">Hóa đơn</h1>
      <p className="mt-1 text-sm text-muted-foreground">Venue invoices — coming soon</p>
    </div>
  )
}
```

- [ ] **Step 3: Delete old admin pages**

```bash
cd apps/web-admin
rm src/pages/admin/admin-ai-config-page.tsx
rm src/pages/admin/admin-audit-logs-page.tsx
rm src/pages/admin/admin-employer-verification-page.tsx
rm src/pages/admin/admin-job-moderation-page.tsx
rm src/pages/admin/admin-packages-page.tsx
rm src/pages/admin/admin-payments-page.tsx
rm src/pages/admin/admin-rbac-page.tsx
rm src/pages/admin/admin-settings-page.tsx
rm src/pages/admin/admin-dashboard-page.tsx
rm src/pages/admin/admin-users-page.tsx
```

- [ ] **Step 4: Commit**

```bash
git add apps/web-admin/src/pages/
git commit -m "feat(web-admin): scaffold admin and venue page stubs, remove legacy pages"
```

---

## Task 9: Rewrite `router.tsx`

**Files:**
- Modify: `apps/web-admin/src/router.tsx` (full rewrite)

- [ ] **Step 1: Rewrite `src/router.tsx`**

```tsx
import { Navigate, createBrowserRouter } from 'react-router-dom'
import { AdminLayout } from '@/components/layouts/admin-layout'
import { VenueLayout } from '@/components/layouts/venue-layout'
import { AdminGuard } from '@/guards/admin-guard'
import { VenueGuard } from '@/guards/venue-guard'
import { AdminDashboardPage } from '@/pages/admin/dashboard'
import { AdminInvoicesPage } from '@/pages/admin/invoices'
import { AdminReviewsPage } from '@/pages/admin/reviews'
import { AdminUsersPage } from '@/pages/admin/users'
import { AdminVenuesPage } from '@/pages/admin/venues'
import { LoginPage } from '@/pages/login'
import { NotFoundPage } from '@/pages/not-found-page'
import { RoleSelectPage } from '@/pages/select-role'
import { VenueBookingsPage } from '@/pages/venue/bookings'
import { VenueCourtsPage } from '@/pages/venue/courts'
import { VenueDashboardPage } from '@/pages/venue/dashboard'
import { VenueHoursPage } from '@/pages/venue/hours'
import { VenueInvoicesPage } from '@/pages/venue/invoices'
import { VenueMediaPage } from '@/pages/venue/media'
import { VenueProductsPage } from '@/pages/venue/products'
import { VenueProfilePage } from '@/pages/venue/profile'
import { VenueReviewsPage } from '@/pages/venue/reviews'
import { useAuthStore } from '@/store/auth'

function RootRedirect() {
  const { token, activeRole } = useAuthStore()
  if (!token) return <Navigate to="/login" replace />
  if (activeRole === 'ROLE_ADMIN') return <Navigate to="/admin" replace />
  if (activeRole === 'ROLE_VENUE_MANAGER') return <Navigate to="/venue" replace />
  return <Navigate to="/select-role" replace />
}

export const router = createBrowserRouter([
  { path: '/', element: <RootRedirect /> },
  { path: '/login', element: <LoginPage /> },
  { path: '/select-role', element: <RoleSelectPage /> },
  {
    path: '/admin',
    element: (
      <AdminGuard>
        <AdminLayout />
      </AdminGuard>
    ),
    children: [
      { index: true, element: <AdminDashboardPage /> },
      { path: 'venues', element: <AdminVenuesPage /> },
      { path: 'users', element: <AdminUsersPage /> },
      { path: 'invoices', element: <AdminInvoicesPage /> },
      { path: 'reviews', element: <AdminReviewsPage /> },
    ],
  },
  {
    path: '/venue',
    element: (
      <VenueGuard>
        <VenueLayout />
      </VenueGuard>
    ),
    children: [
      { index: true, element: <VenueDashboardPage /> },
      { path: 'profile', element: <VenueProfilePage /> },
      { path: 'courts', element: <VenueCourtsPage /> },
      { path: 'hours', element: <VenueHoursPage /> },
      { path: 'products', element: <VenueProductsPage /> },
      { path: 'bookings', element: <VenueBookingsPage /> },
      { path: 'reviews', element: <VenueReviewsPage /> },
      { path: 'media', element: <VenueMediaPage /> },
      { path: 'invoices', element: <VenueInvoicesPage /> },
    ],
  },
  { path: '*', element: <NotFoundPage /> },
])
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit
```

Expected: errors only in `sign-in-page.tsx` (not yet deleted). Router itself should be clean.

- [ ] **Step 3: Commit**

```bash
git add apps/web-admin/src/router.tsx
git commit -m "feat(web-admin): rewrite router with dual-portal route tree and role guards"
```

---

## Task 10: Login Page + Role Select Page

**Files:**
- Delete: `apps/web-admin/src/pages/sign-in-page.tsx`
- Create: `apps/web-admin/src/pages/login/index.tsx`
- Create: `apps/web-admin/src/pages/select-role/index.tsx`

- [ ] **Step 1: Delete old sign-in page**

```bash
rm apps/web-admin/src/pages/sign-in-page.tsx
```

- [ ] **Step 2: Create `src/pages/login/index.tsx`**

```tsx
import { Lock, Mail, Volleyball } from 'lucide-react'
import { useState } from 'react'
import { Navigate, useNavigate } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { getRolesFromToken } from '@/hooks/use-auth'
import { api } from '@/lib/axios'
import { useCopy } from '@/lib/copy'
import { useAuthStore } from '@/store/auth'
import type { ApiResponse } from '@/types/api'

interface LoginResponse {
  token: string
  refreshToken: string
  authenticated: boolean
}

export function LoginPage() {
  const copy = useCopy()
  const navigate = useNavigate()
  const { token, activeRole, setAuth } = useAuthStore()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  if (token) {
    if (activeRole === 'ROLE_ADMIN') return <Navigate to="/admin" replace />
    if (activeRole === 'ROLE_VENUE_MANAGER')
      return <Navigate to="/venue" replace />
    return <Navigate to="/select-role" replace />
  }

  const handleLogin = async () => {
    setLoading(true)
    setError(null)
    try {
      const res = await api.post<ApiResponse<LoginResponse>>('/auth', {
        username: email,
        password,
      })
      const { token: accessToken, refreshToken } = res.data.data
      const roles = getRolesFromToken(accessToken)
      setAuth({
        token: accessToken,
        refreshToken,
        user: { id: '', name: email.split('@')[0], email },
        roles,
      })
      if (roles.length === 1) {
        navigate(roles[0] === 'ROLE_ADMIN' ? '/admin' : '/venue', {
          replace: true,
        })
      } else {
        navigate('/select-role', { replace: true })
      }
    } catch (err: unknown) {
      const msg =
        (err as any)?.response?.data?.message ?? copy.loginError
      setError(msg)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="grid min-h-screen bg-background lg:grid-cols-2">
      <div className="px-6 py-10 lg:px-16">
        <div className="flex items-center gap-2">
          <div className="flex size-9 items-center justify-center rounded-lg bg-primary text-primary-foreground">
            <Volleyball className="size-4" />
          </div>
          <span className="text-lg font-bold">{copy.brand}</span>
        </div>

        <div className="mx-auto mt-20 max-w-md space-y-4">
          <h1 className="text-3xl font-bold">{copy.signInTitle}</h1>

          {error && (
            <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-600 dark:border-red-900 dark:bg-red-950 dark:text-red-400">
              {error}
            </div>
          )}

          <div>
            <label className="text-sm font-medium">{copy.email}</label>
            <div className="relative mt-1.5">
              <Mail className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="h-11 w-full rounded-md border border-input bg-background pl-9 pr-3 text-sm"
                placeholder="admin@gmail.com"
              />
            </div>
          </div>

          <div>
            <label className="text-sm font-medium">{copy.password}</label>
            <div className="relative mt-1.5">
              <Lock className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && handleLogin()}
                className="h-11 w-full rounded-md border border-input bg-background pl-9 pr-3 text-sm"
              />
            </div>
          </div>

          <Button
            className="h-11 w-full"
            onClick={handleLogin}
            disabled={loading || !email || !password}
          >
            {loading ? copy.loading : copy.login}
          </Button>
        </div>
      </div>

      <div className="hidden items-center justify-center bg-[radial-gradient(circle_at_top,_rgba(255,255,255,0.16),_transparent_35%),linear-gradient(135deg,_#0f2e7a,_#1f5fd6_55%,_#13a4c9)] p-12 text-white lg:flex">
        <div className="max-w-md">
          <h2 className="text-3xl font-bold">{copy.signInVisualTitle}</h2>
          <p className="mt-2 opacity-90">{copy.signInVisualDesc}</p>
        </div>
      </div>
    </div>
  )
}
```

- [ ] **Step 3: Create `src/pages/select-role/index.tsx`**

```tsx
import { Dumbbell, Zap } from 'lucide-react'
import { Navigate, useNavigate } from 'react-router-dom'
import { useCopy } from '@/lib/copy'
import { queryClient } from '@/lib/query-client'
import { useAuthStore } from '@/store/auth'

export function RoleSelectPage() {
  const { token, roles, setActiveRole } = useAuthStore()
  const navigate = useNavigate()
  const copy = useCopy()

  if (!token) return <Navigate to="/login" replace />
  if (roles.length === 1) {
    return (
      <Navigate
        to={roles[0] === 'ROLE_ADMIN' ? '/admin' : '/venue'}
        replace
      />
    )
  }

  const select = (role: string) => {
    queryClient.clear()
    setActiveRole(role)
    navigate(role === 'ROLE_ADMIN' ? '/admin' : '/venue', { replace: true })
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-background p-4">
      <div className="w-full max-w-md space-y-6">
        <div className="text-center">
          <h1 className="text-2xl font-bold">{copy.selectRoleTitle}</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            {copy.selectRoleDesc}
          </p>
        </div>

        <div className="grid gap-4">
          <button
            type="button"
            onClick={() => select('ROLE_ADMIN')}
            className="flex items-center gap-4 rounded-xl border-2 border-transparent bg-card p-6 text-left shadow-sm transition-all hover:border-[#132D77] hover:shadow-md"
          >
            <div className="flex size-12 shrink-0 items-center justify-center rounded-xl bg-[#132D77] text-white">
              <Zap className="size-6" />
            </div>
            <div>
              <div className="text-base font-semibold">{copy.adminPortal}</div>
              <div className="mt-0.5 text-sm text-muted-foreground">
                {copy.adminPortalDesc}
              </div>
            </div>
          </button>

          <button
            type="button"
            onClick={() => select('ROLE_VENUE_MANAGER')}
            className="flex items-center gap-4 rounded-xl border-2 border-transparent bg-card p-6 text-left shadow-sm transition-all hover:border-[#0d7c5f] hover:shadow-md"
          >
            <div className="flex size-12 shrink-0 items-center justify-center rounded-xl bg-[#0d7c5f] text-white">
              <Dumbbell className="size-6" />
            </div>
            <div>
              <div className="text-base font-semibold">{copy.venuePortal}</div>
              <div className="mt-0.5 text-sm text-muted-foreground">
                {copy.venuePortalDesc}
              </div>
            </div>
          </button>
        </div>
      </div>
    </div>
  )
}
```

- [ ] **Step 4: Verify TypeScript compiles**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit
```

Expected: no errors.

- [ ] **Step 5: Start dev server and smoke-test login flow**

```bash
cd apps/web-admin && pnpm dev
```

Open `http://localhost:3002`:
1. Should redirect to `/login` (no token).
2. Enter `admin@gmail.com` / `admin123` (backend must be running: `make compose-up && make run` from repo root).
3. On success: redirected to `/admin` (single ADMIN role) or `/select-role` (dual-role).
4. Sidebar shows "BadBook / ADMIN" badge in navy `#132D77`.
5. Click "Sign out" → clears token → redirected to `/login`.

- [ ] **Step 6: Commit**

```bash
git add apps/web-admin/src/pages/login/ \
        apps/web-admin/src/pages/select-role/
git commit -m "feat(web-admin): add LoginPage with real API call and RoleSelectPage"
```

---

## Task 11: Shared UI Components

**Files:**
- Create: `apps/web-admin/src/components/ui/data-table.tsx`
- Create: `apps/web-admin/src/components/ui/modal.tsx`
- Create: `apps/web-admin/src/components/ui/form-field.tsx`

- [ ] **Step 1: Create `src/components/ui/data-table.tsx`**

```tsx
import { cn } from '@/lib/utils'

interface Column<T> {
  key: string
  header: string
  render?: (row: T) => React.ReactNode
  className?: string
}

interface DataTableProps<T extends object> {
  columns: Column<T>[]
  data: T[]
  loading?: boolean
  emptyMessage?: string
  keyExtractor: (row: T) => string | number
}

export function DataTable<T extends object>({
  columns,
  data,
  loading = false,
  emptyMessage = 'Không có dữ liệu',
  keyExtractor,
}: DataTableProps<T>) {
  return (
    <div className="overflow-hidden rounded-lg border border-border">
      <table className="w-full text-sm">
        <thead className="bg-muted/50">
          <tr>
            {columns.map((col) => (
              <th
                key={col.key}
                className={cn(
                  'px-4 py-3 text-left font-medium text-muted-foreground',
                  col.className,
                )}
              >
                {col.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {loading ? (
            Array.from({ length: 5 }).map((_, i) => (
              <tr key={i} className="border-t border-border">
                {columns.map((col) => (
                  <td key={col.key} className="px-4 py-3">
                    <div className="h-4 w-3/4 animate-pulse rounded bg-muted" />
                  </td>
                ))}
              </tr>
            ))
          ) : data.length === 0 ? (
            <tr>
              <td
                colSpan={columns.length}
                className="px-4 py-8 text-center text-muted-foreground"
              >
                {emptyMessage}
              </td>
            </tr>
          ) : (
            data.map((row) => (
              <tr
                key={keyExtractor(row)}
                className="border-t border-border transition-colors hover:bg-muted/30"
              >
                {columns.map((col) => (
                  <td key={col.key} className={cn('px-4 py-3', col.className)}>
                    {col.render
                      ? col.render(row)
                      : String((row as Record<string, unknown>)[col.key] ?? '')}
                  </td>
                ))}
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  )
}
```

- [ ] **Step 2: Create `src/components/ui/modal.tsx`**

```tsx
import { X } from 'lucide-react'
import type { ReactNode } from 'react'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'

interface ModalProps {
  open: boolean
  onClose: () => void
  title: string
  children: ReactNode
  footer?: ReactNode
  size?: 'sm' | 'md' | 'lg'
}

export function Modal({
  open,
  onClose,
  title,
  children,
  footer,
  size = 'md',
}: ModalProps) {
  if (!open) return null

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      <div
        className="absolute inset-0 bg-black/50 backdrop-blur-sm"
        onClick={onClose}
      />
      <div
        className={cn(
          'relative z-10 flex max-h-[90vh] flex-col rounded-xl bg-card shadow-2xl',
          size === 'sm' && 'w-full max-w-sm',
          size === 'md' && 'w-full max-w-lg',
          size === 'lg' && 'w-full max-w-2xl',
        )}
      >
        <div className="flex items-center justify-between border-b border-border px-6 py-4">
          <h2 className="text-base font-semibold">{title}</h2>
          <Button variant="ghost" size="icon" onClick={onClose} className="size-8">
            <X className="size-4" />
          </Button>
        </div>
        <div className="overflow-y-auto p-6">{children}</div>
        {footer && (
          <div className="border-t border-border px-6 py-4">{footer}</div>
        )}
      </div>
    </div>
  )
}
```

- [ ] **Step 3: Create `src/components/ui/form-field.tsx`**

```tsx
import type { InputHTMLAttributes, SelectHTMLAttributes } from 'react'
import { cn } from '@/lib/utils'

interface FormFieldProps extends InputHTMLAttributes<HTMLInputElement> {
  label: string
  error?: string
}

export function FormField({ label, error, className, ...props }: FormFieldProps) {
  return (
    <div className="space-y-1.5">
      <label className="text-sm font-medium">{label}</label>
      <input
        className={cn(
          'h-10 w-full rounded-md border border-input bg-background px-3 text-sm transition-colors',
          'focus:outline-none focus:ring-2 focus:ring-ring',
          error && 'border-red-400 focus:ring-red-300',
          className,
        )}
        {...props}
      />
      {error && <p className="text-xs text-red-500">{error}</p>}
    </div>
  )
}

interface SelectFieldProps extends SelectHTMLAttributes<HTMLSelectElement> {
  label: string
  error?: string
  options: { value: string; label: string }[]
}

export function SelectField({
  label,
  error,
  options,
  className,
  ...props
}: SelectFieldProps) {
  return (
    <div className="space-y-1.5">
      <label className="text-sm font-medium">{label}</label>
      <select
        className={cn(
          'h-10 w-full rounded-md border border-input bg-background px-3 text-sm transition-colors',
          'focus:outline-none focus:ring-2 focus:ring-ring',
          error && 'border-red-400 focus:ring-red-300',
          className,
        )}
        {...props}
      >
        {options.map((opt) => (
          <option key={opt.value} value={opt.value}>
            {opt.label}
          </option>
        ))}
      </select>
      {error && <p className="text-xs text-red-500">{error}</p>}
    </div>
  )
}
```

- [ ] **Step 4: Verify TypeScript compiles**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit
```

Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add apps/web-admin/src/components/ui/data-table.tsx \
        apps/web-admin/src/components/ui/modal.tsx \
        apps/web-admin/src/components/ui/form-field.tsx
git commit -m "feat(web-admin): add DataTable, Modal, and FormField shared UI components"
```

---

## Task 12: Final Lint + Build Verification

- [ ] **Step 1: Run linter**

```bash
cd apps/web-admin && pnpm lint
```

Expected: no errors.

- [ ] **Step 2: Run TypeScript check**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit
```

Expected: no errors.

- [ ] **Step 3: Run production build**

```bash
cd apps/web-admin && pnpm build
```

Expected: exits with code 0, `dist/` folder created.

- [ ] **Step 4: Manual smoke test (requires backend running)**

Start backend: `make compose-up && make run` (from repo root).
Start dev server: `make web-admin-dev` (from repo root).

Test matrix:
| Scenario | Steps | Expected |
|----------|-------|----------|
| Unauthenticated | Open `http://localhost:3002` | Redirects to `/login` |
| Login admin | Enter `admin@gmail.com` + `admin123` → click Sign in | Redirects to `/admin`, sidebar shows "ADMIN" navy badge |
| Admin navigation | Click each nav item | Page changes, active item highlighted in `#132D77` |
| Collapse sidebar | Click "Thu gọn menu" | Sidebar shrinks to icons only |
| Logout | Click user name area | Clears token, redirects to `/login` |
| Guard: direct URL | While logged out, navigate to `/admin` | Redirects to `/login` |
| Guard: wrong role | Admin user navigates to `/venue` | Redirects to `/admin` |
| Theme toggle | Click moon/sun icon | Theme changes |
| Language toggle | Click EN/VI toggle | Language switches |

- [ ] **Step 5: Commit (if any lint fixes were needed)**

```bash
git add -p  # stage only lint-fix changes if any
git commit -m "fix(web-admin): lint fixes and build verification"
```

---

## Self-Review

**Spec coverage check:**

| Spec section | Task |
|-------------|------|
| Routing architecture | Task 9 |
| AdminGuard / VenueGuard | Task 5 |
| Root redirect logic | Task 9 (`RootRedirect`) |
| Auth store (roles, refreshToken, activeRole) | Task 2 |
| `getRolesFromToken` | Task 4 |
| Axios instance + interceptors | Task 3 |
| QueryClient | Task 1 |
| `PortalLayout` shared component | Task 7 |
| AdminLayout (navy `#132D77`) | Task 7 |
| VenueLayout (green `#0d7c5f`) | Task 7 |
| LoginPage with real API call | Task 10 |
| RoleSelectPage | Task 10 |
| DataTable | Task 11 |
| Modal | Task 11 |
| FormField / SelectField | Task 11 |
| Admin dashboard stub | Task 8 |
| Venue dashboard stub | Task 8 |
| All other stubs (9 admin + 8 venue) | Task 8 |
| New copy.ts keys | Task 6 |
| `.env.example` update | Task 3 |
| `main.tsx` QueryClientProvider | Task 1 |
| Delete old pages | Task 8 |
| Role switch button (sidebar bottom) | Task 7 (PortalLayout) |
| `queryClient.clear()` on role switch | Task 7 (AdminLayout/VenueLayout), Task 10 (RoleSelectPage) |

**Placeholder scan:** None found. All steps contain complete code.

**Type consistency check:**
- `NavGroup` / `NavItem` defined in `portal-layout.tsx` and re-exported — `AdminLayout` and `VenueLayout` import `type NavGroup` from there. ✓
- `AuthState.setAuth` takes `{ token, refreshToken, user, roles }` in Task 2, and called the same way in Task 10 (LoginPage). ✓
- `getRolesFromToken` defined in Task 4 (`hooks/use-auth.ts`), imported in Task 10. ✓
- `queryClient` from `lib/query-client.ts`, imported in `portal-layout.tsx`, `admin-layout.tsx`, `venue-layout.tsx`, `select-role/index.tsx`. ✓
- `api` from `lib/axios.ts`, imported in `portal-layout.tsx` (logout) and `pages/login/index.tsx`. ✓
