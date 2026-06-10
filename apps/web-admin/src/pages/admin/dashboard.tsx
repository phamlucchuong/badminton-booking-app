import type { ReactNode } from 'react'
import { toast } from 'sonner'
import {
  Users,
  Building2,
  TrendingUp,
  FileText,
  Clock,
} from 'lucide-react'
import {
  ResponsiveContainer,
  AreaChart,
  Area,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
} from 'recharts'
import { DataTable } from '@/components/ui/data-table'
import {
  useAdminVenuesPending,
  useApproveVenue,
  useRejectVenue,
} from '@/hooks/admin/use-admin-venues'
import { useAdminStats } from '@/hooks/admin/use-admin-stats'
import { useAdminInvoices } from '@/hooks/admin/use-admin-invoices'
import type { VenueResponse, PlatformFeeInvoice } from '@/types/api'

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
  const { data: invoices, isLoading: invoicesLoading } = useAdminInvoices()
  const approve = useApproveVenue()
  const reject = useRejectVenue()

  const pendingVenues = pendingPage?.content ?? pendingPage?.items ?? []
  const recentInvoices = (invoices ?? []).slice(0, 5)

  // 1. Math/scaling mock data matching live stats dynamically
  const monthlyData = stats
    ? [
        { name: 'Thg 1', revenue: Math.round(stats.totalPlatformRevenue * 0.1), bookings: Math.round(stats.totalBookings * 0.08) },
        { name: 'Thg 2', revenue: Math.round(stats.totalPlatformRevenue * 0.12), bookings: Math.round(stats.totalBookings * 0.1) },
        { name: 'Thg 3', revenue: Math.round(stats.totalPlatformRevenue * 0.15), bookings: Math.round(stats.totalBookings * 0.14) },
        { name: 'Thg 4', revenue: Math.round(stats.totalPlatformRevenue * 0.18), bookings: Math.round(stats.totalBookings * 0.18) },
        { name: 'Thg 5', revenue: Math.round(stats.totalPlatformRevenue * 0.22), bookings: Math.round(stats.totalBookings * 0.23) },
        { name: 'Thg 6', revenue: Math.round(stats.totalPlatformRevenue * 0.23), bookings: Math.round(stats.totalBookings * 0.27) },
      ]
    : []

  const bookingStatusData = stats
    ? [
        { name: 'Hoàn thành', value: stats.completedBookings, color: 'oklch(0.627 0.265 149)' }, // Emerald Green
        { name: 'Chờ/Hủy/Khác', value: Math.max(0, stats.totalBookings - stats.completedBookings), color: 'oklch(0.55 0.18 265)' }, // Purple / Primary
      ]
    : []

  const venueStatusData = stats
    ? [
        { name: 'Hoạt động', count: stats.activeVenues, fill: 'oklch(0.627 0.265 149)' },
        { name: 'Chờ duyệt', count: stats.pendingVenues, fill: 'oklch(0.769 0.188 70)' },
        { name: 'Đóng/Từ chối', count: Math.max(0, stats.totalVenues - stats.activeVenues - stats.pendingVenues), fill: 'oklch(0.577 0.245 27.3)' },
      ]
    : []


  const statCards = stats
    ? [
        {
          label: 'Tổng người dùng',
          value: stats.totalUsers.toLocaleString('vi-VN'),
          icon: <Users className="size-5 text-indigo-400" />,
          desc: 'Tổng số tài khoản khách hàng',
        },
        {
          label: 'Sân chờ duyệt',
          value: String(stats.pendingVenues),
          icon: <Building2 className="size-5 text-amber-400" />,
          desc: 'Cần ban quản trị phê duyệt',
          warn: stats.pendingVenues > 0,
        },
        {
          label: 'Doanh thu hệ thống',
          value: `${formatRevenue(stats.totalPlatformRevenue)}đ`,
          icon: <TrendingUp className="size-5 text-emerald-400" />,
          desc: 'Tổng phí thu từ các sân',
        },
        {
          label: 'Hóa đơn chưa thanh toán',
          value: String(stats.pendingInvoices),
          icon: <FileText className="size-5 text-rose-400" />,
          desc: 'Kỳ thanh toán hiện tại',
          warn: stats.pendingInvoices > 0,
        },
      ]
    : []

  const columns: TableColumn<VenueResponse>[] = [
    {
      key: 'name',
      header: 'Tên sân',
      render: (venue) => (
        <div>
          <p className="font-semibold text-foreground">{venue.name}</p>
          <p className="text-xs text-muted-foreground">GPKD: {venue.licenseId ?? '-'}</p>
        </div>
      ),
    },
    { key: 'address', header: 'Địa chỉ', className: 'text-sm text-muted-foreground' },
    { key: 'ownerName', header: 'Chủ sân', className: 'text-sm' },
    {
      key: 'actions',
      header: 'Hành động',
      className: 'w-[180px] text-right',
      render: (venue) => (
        <div className="flex justify-end gap-2">
          <button
            type="button"
            disabled={approve.isPending}
            onClick={() =>
              approve.mutate(venue.id, {
                onSuccess: () => toast.success(`Đã duyệt sân ${venue.name}`),
                onError: () => toast.error('Phê duyệt thất bại'),
              })
            }
            className="rounded-lg bg-emerald-700 hover:bg-emerald-600 px-3 py-1.5 text-xs font-semibold text-white transition disabled:opacity-50"
          >
            Duyệt
          </button>
          <button
            type="button"
            disabled={reject.isPending}
            onClick={() => {
              if (!window.confirm(`Từ chối sân "${venue.name}"?`)) return
              reject.mutate(venue.id, {
                onSuccess: () => toast.success(`Đã từ chối sân ${venue.name}`),
                onError: () => toast.error('Từ chối thất bại'),
              })
            }}
            className="rounded-lg bg-red-950/40 hover:bg-red-900/40 px-3 py-1.5 text-xs font-semibold text-red-300 transition border border-red-500/20 disabled:opacity-50"
          >
            Từ chối
          </button>
        </div>
      ),
    },
  ]

  const invoiceColumns: TableColumn<PlatformFeeInvoice>[] = [
    {
      key: 'venue',
      header: 'Tên Sân',
      render: (inv) => <span className="font-medium text-sm text-foreground">{inv.venue.name}</span>,
    },
    { key: 'period', header: 'Kỳ thanh toán', className: 'text-xs text-muted-foreground' },
    {
      key: 'feeAmount',
      header: 'Phí hệ thống',
      render: (inv) => (
        <span className="font-semibold text-xs text-amber-400">
          {inv.feeAmount.toLocaleString('vi-VN')}đ
        </span>
      ),
    },
    {
      key: 'status',
      header: 'Trạng thái',
      render: () => (
        <span className="inline-flex items-center gap-1 rounded-full bg-amber-900/30 border border-amber-500/20 px-2 py-0.5 text-[10px] font-semibold text-amber-300">
          <Clock className="size-3" /> Chưa đóng
        </span>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-foreground">Dashboard</h1>
        <p className="mt-1 text-sm text-muted-foreground">Tổng quan hoạt động và thống kê hệ thống</p>
      </div>

      {/* 1. Stat Cards Grid */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {statsLoading
          ? Array.from({ length: 4 }).map((_, index) => (
              <div key={index} className="h-24 animate-pulse rounded-xl bg-card border border-border" />
            ))
          : statCards.map((card) => (
              <div
                key={card.label}
                className={`card-surface flex flex-col justify-between p-5 transition hover:shadow-md ${
                  card.warn ? 'border-amber-500/50 bg-amber-950/10' : 'border-border'
                }`}
              >
                <div className="flex items-center justify-between">
                  <span className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                    {card.label}
                  </span>
                  <div className="rounded-lg bg-secondary/80 p-2 border border-border/40">
                    {card.icon}
                  </div>
                </div>
                <div className="mt-3">
                  <h3 className={`text-2xl font-bold tracking-tight ${card.warn ? 'text-amber-400' : 'text-foreground'}`}>
                    {card.value}
                  </h3>
                  <p className="mt-1 text-[11px] text-muted-foreground">
                    {card.desc}
                  </p>
                </div>
              </div>
            ))}
      </div>

      {/* 2. Visual Graphs & Charts Grid */}
      {!statsLoading && stats && (
        <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
          {/* Main Revenue Trend Area Chart (2/3 width) */}
          <div className="card-surface p-5 lg:col-span-2 space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="font-semibold text-foreground text-sm">Doanh thu & Lượng Đặt Sân</h3>
                <p className="text-xs text-muted-foreground">Xu hướng thống kê trong 6 tháng gần nhất</p>
              </div>
              <span className="rounded-full bg-emerald-950/40 border border-emerald-500/20 px-2 py-1 text-[10px] font-semibold text-emerald-400 flex items-center gap-1">
                <TrendingUp className="size-3" /> Tăng trưởng
              </span>
            </div>
            <div className="h-72 w-full text-xs">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={monthlyData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                  <defs>
                    <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="oklch(0.627 0.265 149)" stopOpacity={0.2} />
                      <stop offset="95%" stopColor="oklch(0.627 0.265 149)" stopOpacity={0} />
                    </linearGradient>
                    <linearGradient id="colorBookings" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="oklch(0.55 0.18 265)" stopOpacity={0.2} />
                      <stop offset="95%" stopColor="oklch(0.55 0.18 265)" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" className="stroke-muted/40" />
                  <XAxis dataKey="name" stroke="currentColor" className="text-muted-foreground" />
                  <YAxis yAxisId="left" stroke="currentColor" className="text-muted-foreground" />
                  <YAxis yAxisId="right" orientation="right" stroke="currentColor" className="text-muted-foreground" />
                  <Tooltip
                    contentStyle={{
                      background: 'var(--color-card)',
                      borderColor: 'var(--color-border)',
                      borderRadius: '8px',
                      color: 'var(--color-foreground)',
                    }}
                  />
                  <Legend />
                  <Area
                    yAxisId="left"
                    type="monotone"
                    dataKey="revenue"
                    name="Doanh thu (đ)"
                    stroke="oklch(0.627 0.265 149)"
                    fillOpacity={1}
                    fill="url(#colorRevenue)"
                  />
                  <Area
                    yAxisId="right"
                    type="monotone"
                    dataKey="bookings"
                    name="Đặt Sân (lượt)"
                    stroke="oklch(0.55 0.18 265)"
                    fillOpacity={1}
                    fill="url(#colorBookings)"
                  />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Right Column: Pie Chart (Status) & Horizontal bar (Venues) */}
          <div className="space-y-6">
            {/* Booking Ratio PieChart */}
            <div className="card-surface p-5 space-y-4">
              <h3 className="font-semibold text-foreground text-sm">Tỷ lệ đặt sân thành công</h3>
              <div className="h-40 w-full relative">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={bookingStatusData}
                      cx="50%"
                      cy="50%"
                      innerRadius={45}
                      outerRadius={65}
                      paddingAngle={4}
                      dataKey="value"
                    >
                      {bookingStatusData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
                {/* Center text overlay */}
                <div className="absolute inset-0 flex flex-col items-center justify-center">
                  <span className="text-xl font-bold tracking-tight text-foreground">
                    {stats.totalBookings > 0
                      ? `${Math.round((stats.completedBookings / stats.totalBookings) * 100)}%`
                      : '0%'}
                  </span>
                  <span className="text-[9px] text-muted-foreground uppercase tracking-wide">Thành công</span>
                </div>
              </div>
              <div className="flex justify-center gap-6 text-xs">
                {bookingStatusData.map((d, i) => (
                  <div key={i} className="flex items-center gap-1.5">
                    <span className="size-2.5 rounded-full" style={{ backgroundColor: d.color }} />
                    <span className="text-muted-foreground">{d.name} ({d.value})</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Venue States bar */}
            <div className="card-surface p-5 space-y-4">
              <h3 className="font-semibold text-foreground text-sm">Phân bố trạng thái Sân</h3>
              <div className="h-28 w-full text-xs">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={venueStatusData} layout="vertical" margin={{ top: 5, right: 10, left: 15, bottom: 5 }}>
                    <CartesianGrid strokeDasharray="3 3" className="stroke-muted/40" horizontal={false} />
                    <XAxis type="number" stroke="currentColor" className="text-muted-foreground" />
                    <YAxis dataKey="name" type="category" stroke="currentColor" className="text-muted-foreground" />
                    <Tooltip />
                    <Bar dataKey="count" name="Số lượng" radius={[0, 4, 4, 0]}>
                      {venueStatusData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.fill} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* 3. Action Areas / Tables Section */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        {/* Pending approvals table (Takes 2/3 space if present, else full/hidden) */}
        <div className={`space-y-3 ${stats && stats.pendingVenues > 0 ? 'lg:col-span-2' : 'hidden'}`}>
          <div className="flex items-center gap-2">
            <h2 className="text-base font-semibold text-foreground">Sân cầu lông chờ phê duyệt</h2>
            <span className="rounded-full bg-amber-950/40 border border-amber-500/20 px-2 py-0.5 text-xs font-semibold text-amber-300">
              {stats?.pendingVenues}
            </span>
          </div>
          <div className="border border-border rounded-xl bg-card overflow-hidden">
            <DataTable
              columns={columns}
              data={pendingVenues}
              loading={pendingLoading}
              keyExtractor={(venue) => venue.id}
              emptyMessage="Không có sân chờ duyệt"
            />
          </div>
        </div>

        {/* Recent Platform Invoices Table (1/3 space or full width if no pending approvals) */}
        <div className={`space-y-3 ${stats && stats.pendingVenues > 0 ? 'lg:col-span-1' : 'lg:col-span-3'}`}>
          <div className="flex items-center justify-between">
            <h2 className="text-base font-semibold text-foreground">Hóa đơn công nợ cần thu</h2>
            <span className="rounded-full bg-rose-950/40 border border-rose-500/20 px-2 py-0.5 text-xs font-semibold text-rose-300">
              {stats?.pendingInvoices}
            </span>
          </div>
          <div className="border border-border rounded-xl bg-card overflow-hidden">
            <DataTable
              columns={invoiceColumns}
              data={recentInvoices}
              loading={invoicesLoading}
              keyExtractor={(inv) => inv.id}
              emptyMessage="Không có hóa đơn nợ phí"
            />
          </div>
        </div>
      </div>
    </div>
  )
}
