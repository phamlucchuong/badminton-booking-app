import type { ReactNode } from 'react'
import { toast } from 'sonner'
import { DataTable } from '@/components/ui/data-table'
import {
  useAdminVenuesPending,
  useApproveVenue,
  useRejectVenue,
} from '@/hooks/admin/use-admin-venues'
import { useAdminStats } from '@/hooks/admin/use-admin-stats'
import type { VenueResponse } from '@/types/api'

type TableColumn<T> = {
  key: string
  header: string
  render?: (row: T) => ReactNode
  className?: string
}

function formatRevenue(amount: number) {
  if (amount >= 1_000_000_000) return `${(amount / 1_000_000_000).toFixed(1)}B`
  if (amount >= 1_000_000) return `${(amount / 1_000_000).toFixed(1)}M`
  return amount.toLocaleString('vi-VN')
}

export function AdminDashboardPage() {
  const { data: stats, isLoading: statsLoading } = useAdminStats()
  const { data: pendingPage, isLoading: pendingLoading } = useAdminVenuesPending()
  const approve = useApproveVenue()
  const reject = useRejectVenue()

  const pendingVenues = pendingPage?.content ?? pendingPage?.items ?? []
  const statCards = stats
    ? [
        {
          label: 'Tong nguoi dung',
          value: stats.totalUsers.toLocaleString('vi-VN'),
          warn: false,
        },
        {
          label: 'Venue cho duyet',
          value: String(stats.pendingVenues),
          warn: stats.pendingVenues > 0,
        },
        {
          label: 'Doanh thu nen tang',
          value: `${formatRevenue(stats.totalPlatformRevenue)}d`,
          warn: false,
        },
        {
          label: 'Hoa don chua dong',
          value: String(stats.pendingInvoices),
          warn: stats.pendingInvoices > 0,
        },
      ]
    : []

  const columns: TableColumn<VenueResponse>[] = [
    {
      key: 'name',
      header: 'Ten san',
      render: (venue) => (
        <div>
          <p className="font-medium">{venue.name}</p>
          <p className="text-xs text-muted-foreground">{venue.licenseId ?? '-'}</p>
        </div>
      ),
    },
    { key: 'address', header: 'Dia chi' },
    { key: 'ownerName', header: 'Chu san' },
    {
      key: 'actions',
      header: 'Hanh dong',
      className: 'w-[180px]',
      render: (venue) => (
        <div className="flex gap-2">
          <button
            type="button"
            disabled={approve.isPending}
            onClick={() =>
              approve.mutate(venue.id, {
                onSuccess: () => toast.success(`Da duyet ${venue.name}`),
                onError: () => toast.error('Duyet that bai'),
              })
            }
            className="rounded bg-emerald-700 px-2 py-1 text-xs text-white disabled:opacity-50"
          >
            Duyet
          </button>
          <button
            type="button"
            disabled={reject.isPending}
            onClick={() => {
              if (!window.confirm(`Tu choi venue "${venue.name}"?`)) return
              reject.mutate(venue.id, {
                onSuccess: () => toast.success(`Da tu choi ${venue.name}`),
                onError: () => toast.error('Tu choi that bai'),
              })
            }}
            className="rounded bg-red-900/70 px-2 py-1 text-xs text-red-300 disabled:opacity-50"
          >
            Tu choi
          </button>
        </div>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Dashboard</h1>
        <p className="mt-1 text-sm text-muted-foreground">Tong quan he thong</p>
      </div>

      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        {statsLoading
          ? Array.from({ length: 4 }).map((_, index) => (
              <div key={index} className="h-20 animate-pulse rounded-lg bg-muted" />
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

      {(stats?.pendingVenues ?? 0) > 0 ? (
        <div className="space-y-3">
          <div className="flex items-center gap-2">
            <h2 className="text-base font-semibold">Venue cho duyet</h2>
            <span className="rounded-full bg-amber-900/50 px-2 py-0.5 text-xs text-amber-300">
              {stats?.pendingVenues}
            </span>
          </div>
          <DataTable
            columns={columns}
            data={pendingVenues}
            loading={pendingLoading}
            keyExtractor={(venue) => venue.id}
            emptyMessage="Khong co venue cho duyet"
          />
        </div>
      ) : (
        !statsLoading && (
          <div className="flex items-center gap-2 rounded-xl border border-emerald-700/40 bg-emerald-950/30 px-4 py-3">
            <span className="text-emerald-400">OK</span>
            <p className="text-sm text-emerald-400">Khong co venue cho duyet</p>
          </div>
        )
      )}
    </div>
  )
}
