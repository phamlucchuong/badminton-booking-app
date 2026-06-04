import {
  Area,
  AreaChart,
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts'
import { StatCard } from '@/components/ui/stat-card'
import { StatusBadge } from '@/components/ui/status-badge'
import { useCopy } from '@/lib/copy'

const userGrowth = [
  { month: 'T1', users: 2200 },
  { month: 'T2', users: 2480 },
  { month: 'T3', users: 2670 },
  { month: 'T4', users: 2890 },
  { month: 'T5', users: 3150 },
  { month: 'T6', users: 3420 },
]

const revenue = [
  { month: 'T1', amount: 72 },
  { month: 'T2', amount: 83 },
  { month: 'T3', amount: 78 },
  { month: 'T4', amount: 96 },
  { month: 'T5', amount: 108 },
  { month: 'T6', amount: 124 },
]

export function AdminDashboardPage() {
  const copy = useCopy()

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">{copy.dashboardTitle}</h1>

      <div className="grid gap-3 md:grid-cols-3 lg:grid-cols-6">
        <StatCard label={copy.activeUsers} value="12,482" />
        <StatCard label={copy.newCandidates} value="328" />
        <StatCard label={copy.newEmployers} value="64" />
        <StatCard label={copy.jobsToday} value="187" />
        <StatCard label={copy.monthlyRevenue} value="124M VND" />
        <StatCard label={copy.aiQueue} value="42 tickets" />
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <div className="card-surface p-5">
          <h2 className="mb-4 font-semibold">{copy.userGrowth}</h2>
          <ResponsiveContainer width="100%" height={260}>
            <AreaChart data={userGrowth}>
              <CartesianGrid stroke="var(--color-border)" strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip />
              <Area
                dataKey="users"
                stroke="var(--color-primary)"
                fill="var(--color-primary)"
                fillOpacity={0.2}
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        <div className="card-surface p-5">
          <h2 className="mb-4 font-semibold">{copy.revenueChart}</h2>
          <ResponsiveContainer width="100%" height={260}>
            <LineChart data={revenue}>
              <CartesianGrid stroke="var(--color-border)" strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip />
              <Line
                dataKey="amount"
                stroke="var(--color-ai)"
                strokeWidth={2.5}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <div className="card-surface p-5">
          <h3 className="mb-3 font-semibold">{copy.pendingEmployers}</h3>
          <div className="space-y-3 text-sm">
            {['Sân Cầu Lông 3T', 'Bad Zone Arena', 'Victory Court'].map((item) => (
              <div key={item} className="flex items-center justify-between">
                <span>{item}</span>
                <StatusBadge status="Pending" />
              </div>
            ))}
          </div>
        </div>

        <div className="card-surface p-5">
          <h3 className="mb-3 font-semibold">{copy.recentTransactions}</h3>
          <div className="space-y-3 text-sm">
            {[
              ['Sân ABC', '12,000,000 VND', 'Paid' as const],
              ['Sân Hoàng Gia', '6,500,000 VND', 'Pending' as const],
              ['CLB Phoenix', '9,000,000 VND', 'Paid' as const],
            ].map(([company, amount, status]) => (
              <div key={company} className="flex items-center justify-between">
                <span>
                  {company} • {amount}
                </span>
                <StatusBadge status={status} />
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
