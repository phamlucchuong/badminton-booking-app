# Admin Portal Feature Pages Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace 5 admin stub pages with fully functional implementations wired to the existing backend API.

**Architecture:** Each page has a dedicated TanStack Query hook in `src/hooks/admin/`. Pages import shared UI components (DataTable, Modal, FormField, SelectField, Button, StatCard) from the foundation layer. No backend changes required — all endpoints exist.

**Tech Stack:** React 19, TanStack Query v5, Axios, Tailwind CSS v4, Lucide React, Sonner toasts.

**Prerequisite:** Foundation plan (`2026-06-06-web-portal-foundation-plan.md`) must be executed first. Assumes `DataTable`, `Modal`, `FormField`, `SelectField`, `Button`, `StatCard`, `api` (axios instance), `queryClient` all exist.

---

## File Map

### Modify
| File | Change |
|------|--------|
| `apps/web-admin/src/types/api.ts` | Add `SystemStatsResponse`, `AdminUserResponse`, `AdminUserCreateRequest` |

### Create — Hooks (`src/hooks/admin/`)
| File | Purpose |
|------|---------|
| `use-admin-stats.ts` | `GET /admin/stats` |
| `use-admin-venues.ts` | Pending + all venues + approve/reject/suspend mutations |
| `use-admin-users.ts` | Paginated users + create + delete |
| `use-admin-invoices.ts` | Pending invoices + generate + mark paid |

### Replace — Pages (`src/pages/admin/`)
All 5 existing stubs replaced with full implementations.

### API endpoints used (axios baseURL = `http://localhost:8080/badbook/api`)
| Hook path | Method | Full URL |
|-----------|--------|----------|
| `/admin/stats` | GET | `/api/admin/stats` |
| `/venues/pending?page=1&size=50` | GET | `/api/venues/pending` |
| `/venues?page=1&size=100` | GET | `/api/venues` |
| `/venues/{id}/approve` | PUT | `/api/venues/{id}/approve` |
| `/venues/{id}/reject` | PUT | `/api/venues/{id}/reject` |
| `/venues/{id}/suspend` | PUT | `/api/venues/{id}/suspend` |
| `/admin/users?page={n}&size=20` | GET | `/api/admin/users` |
| `/admin/users` | POST | `/api/admin/users` |
| `/admin/users/{id}` | DELETE | `/api/admin/users/{id}` |
| `/admin/invoices/pending` | GET | `/api/admin/invoices/pending` |
| `/admin/invoices/generate?venueId={v}&period={p}` | POST | `/api/admin/invoices/generate` |
| `/admin/invoices/{id}/paid` | PUT | `/api/admin/invoices/{id}/paid` |

---

## Task 1: TypeScript Types

**Files:**
- Modify: `apps/web-admin/src/types/api.ts`

- [ ] **Step 1: Append admin types to `src/types/api.ts`**

Add after the last existing interface:

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

- [ ] **Step 2: Verify TypeScript compiles**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit
```

Expected: 0 errors.

- [ ] **Step 3: Commit**

```bash
git add apps/web-admin/src/types/api.ts
git commit -m "feat(web-admin): add admin portal TypeScript types"
```

---

## Task 2: Hook — `use-admin-stats.ts`

**Files:**
- Create: `apps/web-admin/src/hooks/admin/use-admin-stats.ts`

- [ ] **Step 1: Create the hook**

```ts
import { useQuery } from '@tanstack/react-query'
import { api } from '@/lib/axios'
import type { ApiResponse, SystemStatsResponse } from '@/types/api'

export function useAdminStats() {
  return useQuery({
    queryKey: ['admin', 'stats'],
    queryFn: () =>
      api
        .get<ApiResponse<SystemStatsResponse>>('/admin/stats')
        .then((r) => r.data.data),
    staleTime: 60_000,
    retry: false,
  })
}
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit
```

- [ ] **Step 3: Commit**

```bash
git add apps/web-admin/src/hooks/admin/use-admin-stats.ts
git commit -m "feat(web-admin): add useAdminStats hook"
```

---

## Task 3: Hook — `use-admin-venues.ts`

**Files:**
- Create: `apps/web-admin/src/hooks/admin/use-admin-venues.ts`

- [ ] **Step 1: Create the hook**

```ts
import { useMutation, useQuery } from '@tanstack/react-query'
import { api } from '@/lib/axios'
import { queryClient } from '@/lib/query-client'
import type { ApiResponse, PageResponse, VenueResponse } from '@/types/api'

const KEYS = {
  pending: ['admin', 'venues', 'pending'] as const,
  all: ['admin', 'venues', 'all'] as const,
}

export function useAdminVenuesPending() {
  return useQuery({
    queryKey: KEYS.pending,
    queryFn: () =>
      api
        .get<ApiResponse<PageResponse<VenueResponse>>>('/venues/pending?page=1&size=50')
        .then((r) => r.data.data),
  })
}

export function useAdminVenuesAll() {
  return useQuery({
    queryKey: KEYS.all,
    queryFn: () =>
      api
        .get<ApiResponse<PageResponse<VenueResponse>>>('/venues?page=1&size=100')
        .then((r) => r.data.data),
  })
}

const invalidateVenues = () => {
  queryClient.invalidateQueries({ queryKey: KEYS.pending })
  queryClient.invalidateQueries({ queryKey: KEYS.all })
}

export function useApproveVenue() {
  return useMutation({
    mutationFn: (id: string) =>
      api.put<ApiResponse<VenueResponse>>(`/venues/${id}/approve`),
    onSuccess: invalidateVenues,
  })
}

export function useRejectVenue() {
  return useMutation({
    mutationFn: (id: string) =>
      api.put<ApiResponse<VenueResponse>>(`/venues/${id}/reject`),
    onSuccess: invalidateVenues,
  })
}

export function useSuspendVenue() {
  return useMutation({
    mutationFn: (id: string) =>
      api.put<ApiResponse<VenueResponse>>(`/venues/${id}/suspend`),
    onSuccess: invalidateVenues,
  })
}
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit
```

- [ ] **Step 3: Commit**

```bash
git add apps/web-admin/src/hooks/admin/use-admin-venues.ts
git commit -m "feat(web-admin): add useAdminVenues hooks"
```

---

## Task 4: Hook — `use-admin-users.ts`

**Files:**
- Create: `apps/web-admin/src/hooks/admin/use-admin-users.ts`

- [ ] **Step 1: Create the hook**

```ts
import { useMutation, useQuery } from '@tanstack/react-query'
import { api } from '@/lib/axios'
import { queryClient } from '@/lib/query-client'
import type {
  AdminUserCreateRequest,
  AdminUserResponse,
  ApiResponse,
  PageResponse,
} from '@/types/api'

export function useAdminUsers(page: number) {
  return useQuery({
    queryKey: ['admin', 'users', page],
    queryFn: () =>
      api
        .get<ApiResponse<PageResponse<AdminUserResponse>>>(
          `/admin/users?page=${page}&size=20`,
        )
        .then((r) => r.data.data),
  })
}

export function useCreateAdminUser() {
  return useMutation({
    mutationFn: (req: AdminUserCreateRequest) =>
      api
        .post<ApiResponse<AdminUserResponse>>('/admin/users', req)
        .then((r) => r.data.data),
    onSuccess: () =>
      queryClient.invalidateQueries({ queryKey: ['admin', 'users'] }),
  })
}

export function useDeleteAdminUser() {
  return useMutation({
    mutationFn: (id: string) => api.delete(`/admin/users/${id}`),
    onSuccess: () =>
      queryClient.invalidateQueries({ queryKey: ['admin', 'users'] }),
  })
}
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit
```

- [ ] **Step 3: Commit**

```bash
git add apps/web-admin/src/hooks/admin/use-admin-users.ts
git commit -m "feat(web-admin): add useAdminUsers hooks"
```

---

## Task 5: Hook — `use-admin-invoices.ts`

**Files:**
- Create: `apps/web-admin/src/hooks/admin/use-admin-invoices.ts`

- [ ] **Step 1: Create the hook**

```ts
import { useMutation, useQuery } from '@tanstack/react-query'
import { api } from '@/lib/axios'
import { queryClient } from '@/lib/query-client'
import type { ApiResponse, PlatformFeeInvoice } from '@/types/api'

const QUERY_KEY = ['admin', 'invoices', 'pending'] as const

export function useAdminInvoices() {
  return useQuery({
    queryKey: QUERY_KEY,
    queryFn: () =>
      api
        .get<ApiResponse<PlatformFeeInvoice[]>>('/admin/invoices/pending')
        .then((r) => r.data.data),
  })
}

export function useGenerateInvoice() {
  return useMutation({
    mutationFn: ({
      venueId,
      period,
    }: {
      venueId: string
      period: string
    }) =>
      api
        .post<ApiResponse<PlatformFeeInvoice>>(
          `/admin/invoices/generate?venueId=${venueId}&period=${encodeURIComponent(period)}`,
        )
        .then((r) => r.data.data),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: QUERY_KEY }),
  })
}

export function useMarkInvoicePaid() {
  return useMutation({
    mutationFn: (id: string) =>
      api
        .put<ApiResponse<PlatformFeeInvoice>>(`/admin/invoices/${id}/paid`)
        .then((r) => r.data.data),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: QUERY_KEY }),
  })
}
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit
```

- [ ] **Step 3: Commit**

```bash
git add apps/web-admin/src/hooks/admin/use-admin-invoices.ts
git commit -m "feat(web-admin): add useAdminInvoices hooks"
```

---

## Task 6: Dashboard Page

**Files:**
- Modify: `apps/web-admin/src/pages/admin/dashboard.tsx`

- [ ] **Step 1: Replace stub with full implementation**

```tsx
import { toast } from 'sonner'
import { StatCard } from '@/components/ui/stat-card'
import { DataTable } from '@/components/ui/data-table'
import { Button } from '@/components/ui/button'
import { useAdminStats } from '@/hooks/admin/use-admin-stats'
import { useAdminVenuesPending, useApproveVenue, useRejectVenue } from '@/hooks/admin/use-admin-venues'
import type { VenueResponse } from '@/types/api'

const fmtRevenue = (n: number): string => {
  if (n >= 1_000_000_000) return `${(n / 1_000_000_000).toFixed(1)}B`
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`
  return n.toLocaleString('vi-VN')
}

export function AdminDashboardPage() {
  const { data: stats, isLoading: statsLoading } = useAdminStats()
  const { data: pendingPage, isLoading: pendingLoading } = useAdminVenuesPending()
  const approve = useApproveVenue()
  const reject = useRejectVenue()

  const pendingVenues: VenueResponse[] =
    pendingPage?.content ?? pendingPage?.items ?? []

  const statCards = stats
    ? [
        {
          label: 'Tổng người dùng',
          value: stats.totalUsers.toLocaleString('vi-VN'),
          warn: false,
        },
        {
          label: 'Venue chờ duyệt',
          value: String(stats.pendingVenues),
          warn: stats.pendingVenues > 0,
        },
        {
          label: 'Doanh thu nền tảng',
          value: fmtRevenue(stats.totalPlatformRevenue) + 'đ',
          warn: false,
        },
        {
          label: 'Hóa đơn chưa đóng',
          value: String(stats.pendingInvoices),
          warn: stats.pendingInvoices > 0,
        },
      ]
    : []

  const venueColumns = [
    {
      key: 'name',
      header: 'Tên sân',
      render: (v: VenueResponse) => (
        <div>
          <p className="font-medium">{v.name}</p>
          <p className="text-xs text-muted-foreground">{v.licenseId}</p>
        </div>
      ),
    },
    { key: 'address', header: 'Địa chỉ' },
    { key: 'ownerName', header: 'Chủ sân' },
    {
      key: 'actions',
      header: 'Hành động',
      render: (v: VenueResponse) => (
        <div className="flex gap-2">
          <button
            type="button"
            disabled={approve.isPending}
            onClick={() =>
              approve.mutate(v.id, {
                onSuccess: () => toast.success(`Đã duyệt ${v.name}`),
                onError: () => toast.error('Duyệt thất bại'),
              })
            }
            className="rounded bg-emerald-700 px-2 py-1 text-xs text-white disabled:opacity-50"
          >
            ✓ Duyệt
          </button>
          <button
            type="button"
            disabled={reject.isPending}
            onClick={() => {
              if (window.confirm(`Từ chối venue "${v.name}"?`))
                reject.mutate(v.id, {
                  onSuccess: () => toast.success(`Đã từ chối ${v.name}`),
                  onError: () => toast.error('Từ chối thất bại'),
                })
            }}
            className="rounded bg-red-900/70 px-2 py-1 text-xs text-red-300 disabled:opacity-50"
          >
            ✕ Từ chối
          </button>
        </div>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Dashboard</h1>
        <p className="mt-1 text-sm text-muted-foreground">Tổng quan hệ thống</p>
      </div>

      {/* Stat cards */}
      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        {statsLoading
          ? Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="h-20 animate-pulse rounded-lg bg-muted" />
            ))
          : statCards.map((card) => (
              <div
                key={card.label}
                className={`rounded-xl border bg-card p-4 ${card.warn ? 'border-amber-500/50' : 'border-border'}`}
              >
                <p className={`text-2xl font-bold ${card.warn ? 'text-amber-400' : ''}`}>
                  {card.value}
                </p>
                <p className="mt-1 text-xs text-muted-foreground">{card.label}</p>
              </div>
            ))}
      </div>

      {/* Pending venues */}
      {(stats?.pendingVenues ?? 0) > 0 ? (
        <div className="space-y-3">
          <div className="flex items-center gap-2">
            <h2 className="text-base font-semibold">Venue chờ duyệt</h2>
            <span className="rounded-full bg-amber-900/50 px-2 py-0.5 text-xs text-amber-300">
              {stats?.pendingVenues}
            </span>
          </div>
          <DataTable
            columns={venueColumns}
            data={pendingVenues}
            loading={pendingLoading}
            keyExtractor={(v) => v.id}
            emptyMessage="Không có venue chờ duyệt"
          />
        </div>
      ) : (
        !statsLoading && (
          <div className="flex items-center gap-2 rounded-xl border border-emerald-700/40 bg-emerald-950/30 px-4 py-3">
            <span className="text-emerald-400">✓</span>
            <p className="text-sm text-emerald-400">Không có venue chờ duyệt</p>
          </div>
        )
      )}
    </div>
  )
}
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit
```

- [ ] **Step 3: Commit**

```bash
git add apps/web-admin/src/pages/admin/dashboard.tsx
git commit -m "feat(web-admin): implement admin dashboard page"
```

---

## Task 7: Venues Page

**Files:**
- Modify: `apps/web-admin/src/pages/admin/venues.tsx`

- [ ] **Step 1: Replace stub with full implementation**

```tsx
import { useState } from 'react'
import { toast } from 'sonner'
import { DataTable } from '@/components/ui/data-table'
import { Modal } from '@/components/ui/modal'
import { Button } from '@/components/ui/button'
import {
  useAdminVenuesPending,
  useAdminVenuesAll,
  useApproveVenue,
  useRejectVenue,
  useSuspendVenue,
} from '@/hooks/admin/use-admin-venues'
import type { VenueResponse } from '@/types/api'

const STATUS_BADGE: Record<string, string> = {
  PENDING: 'bg-amber-900/50 text-amber-300',
  ACTIVE: 'bg-emerald-900/50 text-emerald-300',
  SUSPENDED: 'bg-red-900/50 text-red-300',
  REJECTED: 'bg-slate-700 text-slate-300',
}

export function AdminVenuesPage() {
  const { data: pendingPage, isLoading: pendingLoading } = useAdminVenuesPending()
  const { data: allPage, isLoading: allLoading } = useAdminVenuesAll()
  const approve = useApproveVenue()
  const reject = useRejectVenue()
  const suspend = useSuspendVenue()

  const [selected, setSelected] = useState<VenueResponse | null>(null)

  const pending: VenueResponse[] = pendingPage?.content ?? pendingPage?.items ?? []
  const all: VenueResponse[] = allPage?.content ?? allPage?.items ?? []

  // Pending venues first, then active (no duplicates by id)
  const pendingIds = new Set(pending.map((v) => v.id))
  const venues = [...pending, ...all.filter((v) => !pendingIds.has(v.id))]

  const closeModal = () => setSelected(null)

  const handleAction = (
    action: 'approve' | 'reject' | 'suspend',
    venue: VenueResponse,
  ) => {
    const label =
      action === 'approve'
        ? 'Phê duyệt'
        : action === 'reject'
          ? 'Từ chối'
          : 'Tạm dừng'
    const mutate =
      action === 'approve' ? approve : action === 'reject' ? reject : suspend
    mutate.mutate(venue.id, {
      onSuccess: () => {
        toast.success(`${label} "${venue.name}" thành công`)
        closeModal()
      },
      onError: () => toast.error(`${label} thất bại`),
    })
  }

  const anyPending =
    approve.isPending || reject.isPending || suspend.isPending

  const columns = [
    {
      key: 'name',
      header: 'Tên sân',
      render: (v: VenueResponse) => (
        <div>
          <p className="font-medium">{v.name}</p>
          <p className="text-xs text-muted-foreground">{v.address}</p>
        </div>
      ),
    },
    { key: 'ownerName', header: 'Chủ sân' },
    {
      key: 'status',
      header: 'Trạng thái',
      render: (v: VenueResponse) => (
        <span
          className={`rounded-full px-2 py-0.5 text-xs font-medium ${STATUS_BADGE[v.status] ?? 'bg-slate-700 text-slate-300'}`}
        >
          {v.status}
        </span>
      ),
    },
    {
      key: 'action',
      header: '',
      render: (v: VenueResponse) => (
        <button
          type="button"
          onClick={() => setSelected(v)}
          className="text-xs text-blue-400 hover:underline"
        >
          Xem chi tiết →
        </button>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Quản lý Venue</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          {pending.length} chờ duyệt · {venues.length} tổng
        </p>
      </div>

      <DataTable
        columns={columns}
        data={venues}
        loading={pendingLoading || allLoading}
        keyExtractor={(v) => v.id}
        emptyMessage="Không có venue nào"
      />

      {/* Detail modal */}
      <Modal
        open={!!selected}
        onClose={closeModal}
        title="Chi tiết Venue"
        footer={
          selected && (
            <div className="flex gap-2">
              {(selected.status === 'PENDING' || selected.status === 'SUSPENDED') && (
                <Button
                  disabled={anyPending}
                  onClick={() => handleAction('approve', selected)}
                  className="bg-emerald-700 hover:bg-emerald-600"
                >
                  ✓ {selected.status === 'SUSPENDED' ? 'Kích hoạt lại' : 'Phê duyệt'}
                </Button>
              )}
              {selected.status === 'PENDING' && (
                <Button
                  variant="outline"
                  disabled={anyPending}
                  onClick={() => {
                    if (window.confirm(`Từ chối venue "${selected.name}"?`))
                      handleAction('reject', selected)
                  }}
                  className="border-red-700 text-red-400 hover:bg-red-950"
                >
                  ✕ Từ chối
                </Button>
              )}
              {selected.status === 'ACTIVE' && (
                <Button
                  variant="outline"
                  disabled={anyPending}
                  onClick={() => {
                    if (window.confirm(`Tạm dừng venue "${selected.name}"?`))
                      handleAction('suspend', selected)
                  }}
                  className="border-amber-700 text-amber-400 hover:bg-amber-950"
                >
                  ⛔ Tạm dừng
                </Button>
              )}
              <Button variant="outline" onClick={closeModal}>
                Đóng
              </Button>
            </div>
          )
        }
      >
        {selected && (
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-xs text-muted-foreground">TÊN SÂN</p>
                <p className="mt-0.5 font-medium">{selected.name}</p>
              </div>
              <div>
                <p className="text-xs text-muted-foreground">CHỦ SÂN</p>
                <p className="mt-0.5 font-medium">{selected.ownerName}</p>
              </div>
              <div>
                <p className="text-xs text-muted-foreground">ĐỊA CHỈ</p>
                <p className="mt-0.5 text-sm">{selected.address}</p>
              </div>
              <div>
                <p className="text-xs text-muted-foreground">MÃ GIẤY PHÉP</p>
                <p className="mt-0.5 font-mono text-sm text-amber-400">
                  {selected.licenseId ?? '—'}
                </p>
              </div>
              <div>
                <p className="text-xs text-muted-foreground">GIỜ HOẠT ĐỘNG</p>
                <p className="mt-0.5 text-sm">
                  {selected.openTime?.slice(0, 5)} – {selected.closeTime?.slice(0, 5)}
                </p>
              </div>
              <div>
                <p className="text-xs text-muted-foreground">TRẠNG THÁI</p>
                <span
                  className={`mt-0.5 inline-block rounded-full px-2 py-0.5 text-xs font-medium ${STATUS_BADGE[selected.status] ?? ''}`}
                >
                  {selected.status}
                </span>
              </div>
            </div>
            {selected.description && (
              <div>
                <p className="text-xs text-muted-foreground">MÔ TẢ</p>
                <p className="mt-0.5 text-sm">{selected.description}</p>
              </div>
            )}
          </div>
        )}
      </Modal>
    </div>
  )
}
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit
```

- [ ] **Step 3: Commit**

```bash
git add apps/web-admin/src/pages/admin/venues.tsx
git commit -m "feat(web-admin): implement admin venues approval page"
```

---

## Task 8: Users Page

**Files:**
- Modify: `apps/web-admin/src/pages/admin/users.tsx`

- [ ] **Step 1: Replace stub with full implementation**

```tsx
import { useState } from 'react'
import { ChevronLeft, ChevronRight, Plus } from 'lucide-react'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { DataTable } from '@/components/ui/data-table'
import { FormField } from '@/components/ui/form-field'
import { Modal } from '@/components/ui/modal'
import {
  useAdminUsers,
  useCreateAdminUser,
  useDeleteAdminUser,
} from '@/hooks/admin/use-admin-users'
import type { AdminUserResponse } from '@/types/api'

export function AdminUsersPage() {
  const [page, setPage] = useState(1)
  const { data: usersPage, isLoading } = useAdminUsers(page)
  const createUser = useCreateAdminUser()
  const deleteUser = useDeleteAdminUser()

  const [showModal, setShowModal] = useState(false)
  const [form, setForm] = useState({ name: '', email: '', phone: '', password: '' })

  const users = usersPage?.content ?? usersPage?.items ?? []
  const totalPages = usersPage?.totalPages ?? 1

  const set =
    (key: keyof typeof form) =>
    (e: React.ChangeEvent<HTMLInputElement>) =>
      setForm((f) => ({ ...f, [key]: e.target.value }))

  const handleCreate = async () => {
    await createUser.mutateAsync(form, {
      onSuccess: () => {
        toast.success('Đã tạo tài khoản')
        setShowModal(false)
        setForm({ name: '', email: '', phone: '', password: '' })
      },
      onError: () => toast.error('Tạo tài khoản thất bại'),
    })
  }

  const handleDelete = (user: AdminUserResponse) => {
    if (!window.confirm(`Xóa tài khoản "${user.name}" (${user.email})?`)) return
    deleteUser.mutate(user.id, {
      onSuccess: () => toast.success('Đã xóa tài khoản'),
      onError: () => toast.error('Xóa thất bại'),
    })
  }

  const columns = [
    {
      key: 'name',
      header: 'Tên',
      render: (u: AdminUserResponse) => (
        <span className="font-medium">{u.name}</span>
      ),
    },
    { key: 'email', header: 'Email' },
    { key: 'phone', header: 'SĐT' },
    {
      key: 'createdAt',
      header: 'Ngày tạo',
      render: (u: AdminUserResponse) =>
        new Date(u.createdAt).toLocaleDateString('vi-VN'),
    },
    {
      key: 'deleted',
      header: 'Trạng thái',
      render: (u: AdminUserResponse) => (
        <span
          className={`rounded-full px-2 py-0.5 text-xs font-medium ${
            u.deleted
              ? 'bg-red-900/50 text-red-300'
              : 'bg-emerald-900/50 text-emerald-300'
          }`}
        >
          {u.deleted ? 'Đã xóa' : 'Hoạt động'}
        </span>
      ),
    },
    {
      key: 'actions',
      header: '',
      render: (u: AdminUserResponse) => (
        <button
          type="button"
          disabled={u.deleted || deleteUser.isPending}
          onClick={() => handleDelete(u)}
          className="text-xs text-red-400 hover:underline disabled:cursor-not-allowed disabled:opacity-40"
        >
          🗑 Xóa
        </button>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Người dùng</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Trang {page} / {totalPages}
          </p>
        </div>
        <Button onClick={() => setShowModal(true)}>
          <Plus className="mr-1.5 size-4" />
          Tạo tài khoản
        </Button>
      </div>

      <DataTable
        columns={columns}
        data={users}
        loading={isLoading}
        keyExtractor={(u) => u.id}
        emptyMessage="Không có người dùng"
      />

      {/* Pagination */}
      <div className="flex items-center justify-end gap-2">
        <Button
          variant="outline"
          size="icon"
          disabled={page <= 1}
          onClick={() => setPage((p) => p - 1)}
        >
          <ChevronLeft className="size-4" />
        </Button>
        <span className="text-sm text-muted-foreground">
          {page} / {totalPages}
        </span>
        <Button
          variant="outline"
          size="icon"
          disabled={page >= totalPages}
          onClick={() => setPage((p) => p + 1)}
        >
          <ChevronRight className="size-4" />
        </Button>
      </div>

      {/* Create modal */}
      <Modal
        open={showModal}
        onClose={() => setShowModal(false)}
        title="Tạo tài khoản mới"
        footer={
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setShowModal(false)}>
              Hủy
            </Button>
            <Button
              onClick={handleCreate}
              disabled={
                createUser.isPending ||
                !form.name ||
                !form.email ||
                !form.phone ||
                !form.password
              }
            >
              {createUser.isPending ? 'Đang tạo...' : 'Tạo tài khoản'}
            </Button>
          </div>
        }
      >
        <div className="space-y-4">
          <FormField
            label="Tên *"
            value={form.name}
            onChange={set('name')}
            placeholder="Nguyễn Văn A"
          />
          <FormField
            label="Email *"
            type="email"
            value={form.email}
            onChange={set('email')}
            placeholder="user@example.com"
          />
          <FormField
            label="Số điện thoại *"
            value={form.phone}
            onChange={set('phone')}
            placeholder="0901234567"
          />
          <FormField
            label="Mật khẩu *"
            type="password"
            value={form.password}
            onChange={set('password')}
            placeholder="••••••••"
          />
        </div>
      </Modal>
    </div>
  )
}
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit
```

- [ ] **Step 3: Commit**

```bash
git add apps/web-admin/src/pages/admin/users.tsx
git commit -m "feat(web-admin): implement admin users management page"
```

---

## Task 9: Invoices Page

**Files:**
- Modify: `apps/web-admin/src/pages/admin/invoices.tsx`

- [ ] **Step 1: Replace stub with full implementation**

```tsx
import { useState } from 'react'
import { Plus } from 'lucide-react'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { DataTable } from '@/components/ui/data-table'
import { FormField } from '@/components/ui/form-field'
import { Modal } from '@/components/ui/modal'
import {
  useAdminInvoices,
  useGenerateInvoice,
  useMarkInvoicePaid,
} from '@/hooks/admin/use-admin-invoices'
import { useAdminVenuesAll } from '@/hooks/admin/use-admin-venues'
import type { PlatformFeeInvoice } from '@/types/api'

type FilterStatus = 'all' | 'pending' | 'paid'

export function AdminInvoicesPage() {
  const { data: invoices, isLoading } = useAdminInvoices()
  const { data: venuesPage } = useAdminVenuesAll()
  const generateInvoice = useGenerateInvoice()
  const markPaid = useMarkInvoicePaid()

  const [filter, setFilter] = useState<FilterStatus>('pending')
  const [showModal, setShowModal] = useState(false)
  const [form, setForm] = useState({ venueId: '', period: '' })

  const allInvoices = invoices ?? []
  const filtered =
    filter === 'all'
      ? allInvoices
      : filter === 'pending'
        ? allInvoices.filter((i) => i.status === 'PENDING')
        : allInvoices.filter((i) => i.status === 'PAID')

  const venues = venuesPage?.content ?? venuesPage?.items ?? []

  const set =
    (key: keyof typeof form) =>
    (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) =>
      setForm((f) => ({ ...f, [key]: e.target.value }))

  const handleGenerate = async () => {
    if (!/^\d{4}-\d{2}$/.test(form.period)) {
      toast.error('Kỳ phải có định dạng YYYY-MM (ví dụ: 2026-06)')
      return
    }
    await generateInvoice.mutateAsync(
      { venueId: form.venueId, period: form.period },
      {
        onSuccess: () => {
          toast.success('Đã tạo hóa đơn')
          setShowModal(false)
          setForm({ venueId: '', period: '' })
        },
        onError: () => toast.error('Tạo hóa đơn thất bại'),
      },
    )
  }

  const handleMarkPaid = (inv: PlatformFeeInvoice) => {
    markPaid.mutate(inv.id, {
      onSuccess: () =>
        toast.success(`Đã đánh dấu đóng hóa đơn ${inv.venue.name} · ${inv.period}`),
      onError: () => toast.error('Cập nhật thất bại'),
    })
  }

  const columns = [
    {
      key: 'venue',
      header: 'Venue',
      render: (i: PlatformFeeInvoice) => (
        <span className="font-medium">{i.venue.name}</span>
      ),
    },
    { key: 'period', header: 'Kỳ' },
    {
      key: 'totalBookings',
      header: 'Booking',
      render: (i: PlatformFeeInvoice) => String(i.totalBookings),
    },
    {
      key: 'totalRevenue',
      header: 'Doanh thu',
      render: (i: PlatformFeeInvoice) =>
        i.totalRevenue.toLocaleString('vi-VN') + 'đ',
    },
    {
      key: 'feeAmount',
      header: 'Phí nền tảng',
      render: (i: PlatformFeeInvoice) => (
        <span className="font-semibold text-amber-400">
          {i.feeAmount.toLocaleString('vi-VN')}đ
        </span>
      ),
    },
    { key: 'dueDate', header: 'Hạn đóng' },
    {
      key: 'status',
      header: 'Trạng thái',
      render: (i: PlatformFeeInvoice) => (
        <span
          className={`rounded-full px-2 py-0.5 text-xs font-medium ${
            i.status === 'PAID'
              ? 'bg-emerald-900/50 text-emerald-300'
              : 'bg-amber-900/50 text-amber-300'
          }`}
        >
          {i.status === 'PAID' ? 'Đã đóng' : 'Chưa đóng'}
        </span>
      ),
    },
    {
      key: 'action',
      header: '',
      render: (i: PlatformFeeInvoice) =>
        i.status === 'PENDING' ? (
          <button
            type="button"
            disabled={markPaid.isPending}
            onClick={() => handleMarkPaid(i)}
            className="rounded bg-emerald-700 px-2 py-1 text-xs text-white disabled:opacity-50"
          >
            ✓ Đã đóng
          </button>
        ) : (
          <span className="text-xs text-muted-foreground">—</span>
        ),
    },
  ]

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Hóa đơn phí nền tảng</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            {allInvoices.filter((i) => i.status === 'PENDING').length} chưa đóng
          </p>
        </div>
        <div className="flex items-center gap-3">
          <select
            value={filter}
            onChange={(e) => setFilter(e.target.value as FilterStatus)}
            className="h-9 rounded-md border border-input bg-background px-3 text-sm"
          >
            <option value="all">Tất cả</option>
            <option value="pending">Chưa đóng</option>
            <option value="paid">Đã đóng</option>
          </select>
          <Button onClick={() => setShowModal(true)}>
            <Plus className="mr-1.5 size-4" />
            Tạo hóa đơn
          </Button>
        </div>
      </div>

      <DataTable
        columns={columns}
        data={filtered}
        loading={isLoading}
        keyExtractor={(i) => i.id}
        emptyMessage="Không có hóa đơn"
      />

      {/* Generate invoice modal */}
      <Modal
        open={showModal}
        onClose={() => setShowModal(false)}
        title="Tạo hóa đơn"
        footer={
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setShowModal(false)}>
              Hủy
            </Button>
            <Button
              onClick={handleGenerate}
              disabled={
                generateInvoice.isPending || !form.venueId || !form.period
              }
            >
              {generateInvoice.isPending ? 'Đang tạo...' : 'Tạo hóa đơn'}
            </Button>
          </div>
        }
      >
        <div className="space-y-4">
          <div className="space-y-1.5">
            <label className="text-sm font-medium">Venue *</label>
            <select
              value={form.venueId}
              onChange={set('venueId')}
              className="h-10 w-full rounded-md border border-input bg-background px-3 text-sm focus:outline-none focus:ring-2 focus:ring-ring"
            >
              <option value="">Chọn venue...</option>
              {venues.map((v) => (
                <option key={v.id} value={v.id}>
                  {v.name}
                </option>
              ))}
            </select>
          </div>
          <FormField
            label="Kỳ * (YYYY-MM)"
            value={form.period}
            onChange={set('period')}
            placeholder="2026-06"
            pattern="\d{4}-\d{2}"
          />
          <p className="text-xs text-muted-foreground">
            Ví dụ: <code>2026-06</code> cho tháng 6 năm 2026
          </p>
        </div>
      </Modal>
    </div>
  )
}
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit
```

- [ ] **Step 3: Commit**

```bash
git add apps/web-admin/src/pages/admin/invoices.tsx
git commit -m "feat(web-admin): implement admin invoices management page"
```

---

## Task 10: Reviews Page (Stub)

**Files:**
- Modify: `apps/web-admin/src/pages/admin/reviews.tsx`

- [ ] **Step 1: Replace stub with coming-soon page**

```tsx
export function AdminReviewsPage() {
  return (
    <div className="flex flex-col items-center justify-center py-24 gap-4 text-center">
      <div className="rounded-full border border-border bg-muted/30 p-6">
        <span className="text-4xl">📋</span>
      </div>
      <div>
        <h1 className="text-xl font-semibold">Quản lý đánh giá</h1>
        <p className="mt-2 text-sm text-muted-foreground max-w-xs">
          Tính năng kiểm duyệt đánh giá đang được phát triển.
        </p>
      </div>
      <span className="rounded-full border border-blue-700/40 bg-blue-950/30 px-3 py-1 text-xs text-blue-400">
        Sắp ra mắt
      </span>
    </div>
  )
}
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit
```

- [ ] **Step 3: Commit**

```bash
git add apps/web-admin/src/pages/admin/reviews.tsx
git commit -m "feat(web-admin): add admin reviews stub page"
```

---

## Task 11: Final Verification

- [ ] **Step 1: Full TypeScript check**

```bash
cd apps/web-admin && pnpm exec tsc --noEmit
```

Expected: 0 errors.

- [ ] **Step 2: Production build**

```bash
cd apps/web-admin && pnpm build
```

Expected: exits 0, `dist/` created.

- [ ] **Step 3: Smoke test in dev server**

Start services and dev server:
```bash
make compose-up && make run   # terminal 1
make web-admin-dev            # terminal 2
```

Open **http://localhost:3002**, login as ADMIN user and test each route:

| Test | Steps | Expected |
|------|-------|----------|
| Dashboard loads | `/admin` | 4 stat cards + pending venues table (or green check if none) |
| Stats display | View stat cards | Numbers visible, amber highlight on pending counts > 0 |
| Approve venue | Click ✓ Duyệt on a pending venue | Toast success, venue disappears from pending |
| Venues table | `/admin/venues` | Table shows venues with status badges |
| Detail modal | Click "Xem chi tiết →" | Modal opens with venue info + conditional action buttons |
| Reject venue | Open PENDING modal → Từ chối | Confirm dialog → toast success |
| Suspend venue | Open ACTIVE modal → Tạm dừng | Confirm dialog → toast success |
| Users table | `/admin/users` | Paginated user list |
| Create user | Click "Tạo tài khoản" → fill form → submit | Toast success, new user in table |
| Delete user | Click 🗑 Xóa → confirm | Toast success, status changes |
| Pagination | Click next/prev | Page number updates, different users |
| Invoices filter | `/admin/invoices` → filter dropdown | List filters client-side |
| Mark paid | Click "✓ Đã đóng" on PENDING invoice | Toast success, status changes |
| Generate invoice | Click "+ Tạo hóa đơn" → select venue + period → submit | Toast success |
| Reviews stub | `/admin/reviews` | "Sắp ra mắt" page, no errors |

- [ ] **Step 4: Final commit if any fixes**

```bash
git add apps/web-admin/src/
git commit -m "fix(web-admin): admin pages smoke test fixes"
```

---

## Self-Review

**Spec coverage:**

| Spec requirement | Task |
|-----------------|------|
| `SystemStatsResponse` + `AdminUserResponse` + `AdminUserCreateRequest` types | Task 1 |
| `useAdminStats` hook | Task 2 |
| `useAdminVenuesPending` + `useAdminVenuesAll` + approve/reject/suspend mutations | Task 3 |
| `useAdminUsers` + create + delete | Task 4 |
| `useAdminInvoices` + generate + mark paid | Task 5 |
| Dashboard: 4 stat cards + pending venues table | Task 6 |
| Venues: DataTable + detail modal + approve/reject/suspend | Task 7 |
| Users: DataTable + pagination + create modal + delete | Task 8 |
| Invoices: DataTable + status filter + generate modal + mark paid | Task 9 |
| Reviews: stub "Sắp ra mắt" | Task 10 |

**Placeholder scan:** None found. All steps have complete code.

**Type consistency:**
- `AdminUserResponse.deleted` (boolean) — used as `u.deleted` in users page ✓
- `PlatformFeeInvoice.venue` is `{ id, name }` object — used as `i.venue.name` in invoices page ✓
- `VenueResponse.content` fallback pattern `pendingPage?.content ?? pendingPage?.items ?? []` — consistent across dashboard and venues pages ✓
- `useAdminVenuesAll()` imported in invoices page for venue dropdown — queryKey `['admin', 'venues', 'all']` matches hook definition ✓
- `useApproveVenue()` / `useRejectVenue()` / `useSuspendVenue()` — all exported from `use-admin-venues.ts`, imported correctly in dashboard and venues pages ✓
- `filter` state typed as `FilterStatus = 'all' | 'pending' | 'paid'` — matches select options ✓
