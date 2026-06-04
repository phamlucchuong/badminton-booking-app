import { StatusBadge } from '@/components/ui/status-badge'
import { useCopy } from '@/lib/copy'

export function AdminPaymentsPage() {
  const copy = useCopy()

  return (
    <div className="space-y-5">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-bold">{copy.paymentsTitle}</h1>
        <input
          type="month"
          className="h-9 rounded-md border border-input bg-background px-3 text-sm"
          defaultValue="2026-06"
        />
      </div>

      <div className="card-surface overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="bg-muted/50 text-left">
            <tr>
              <th className="p-3">Venue</th>
              <th className="p-3">Package</th>
              <th className="p-3">Amount</th>
              <th className="p-3">Date</th>
              <th className="p-3">Status</th>
            </tr>
          </thead>
          <tbody>
            {[
              ['Sân ABC', 'Growth', '3,500,000 VND', '2026-06-01', 'Paid' as const],
              ['Sân Hoàng Gia', 'Starter', '1,200,000 VND', '2026-06-01', 'Pending' as const],
              ['Victory Court', 'Enterprise', '8,000,000 VND', '2026-05-30', 'Failed' as const],
              ['Phoenix Club', 'Growth', '3,500,000 VND', '2026-05-28', 'Refunded' as const],
            ].map((item) => (
              <tr key={`${item[0]}-${item[3]}`} className="border-t border-border">
                <td className="p-3">{item[0]}</td>
                <td className="p-3">{item[1]}</td>
                <td className="p-3">{item[2]}</td>
                <td className="p-3">{item[3]}</td>
                <td className="p-3">
                  <StatusBadge status={item[4]} />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
