import { StatusBadge } from '@/components/ui/status-badge'
import { useCopy } from '@/lib/copy'

export function AdminAuditLogsPage() {
  const copy = useCopy()

  return (
    <div className="space-y-5">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-bold">{copy.auditLogsTitle}</h1>
        <div className="flex gap-2">
          <input
            type="date"
            className="h-9 rounded-md border border-input bg-background px-3 text-sm"
            defaultValue="2026-06-01"
          />
          <select className="h-9 rounded-md border border-input bg-background px-3 text-sm">
            <option>{copy.allActions}</option>
            <option>User.Update</option>
            <option>Venue.Verify</option>
          </select>
        </div>
      </div>

      <div className="card-surface overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="bg-muted/50 text-left">
            <tr>
              <th className="p-3">Time</th>
              <th className="p-3">Actor</th>
              <th className="p-3">Action</th>
              <th className="p-3">Resource</th>
              <th className="p-3">Result</th>
            </tr>
          </thead>
          <tbody>
            {[
              ['2026-06-01 10:15', 'admin@badminton.vn', 'Venue.Verify', 'venue:123', 'Success' as const],
              ['2026-06-01 10:07', 'admin@badminton.vn', 'Booking.Hide', 'booking:893', 'Failed' as const],
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
