import { Button } from '@/components/ui/button'
import { StatusBadge } from '@/components/ui/status-badge'
import { useCopy } from '@/lib/copy'

export function AdminJobModerationPage() {
  const copy = useCopy()

  return (
    <div className="space-y-5">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-bold">{copy.jobModerationTitle}</h1>
        <select className="h-9 rounded-md border border-input bg-background px-3 text-sm">
          <option>{copy.allStatus}</option>
          <option>Pending</option>
          <option>Approved</option>
          <option>Hidden</option>
        </select>
      </div>

      <div className="card-surface overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="bg-muted/50 text-left">
            <tr>
              <th className="p-3">Booking</th>
              <th className="p-3">Venue</th>
              <th className="p-3">Date</th>
              <th className="p-3">Status</th>
              <th className="p-3">Actions</th>
            </tr>
          </thead>
          <tbody>
            {[
              ['Court 1 - 19:00', 'Sân ABC', '2026-06-01', 'Pending' as const],
              ['Court 2 - 20:00', 'Victory Arena', '2026-05-30', 'Approved' as const],
            ].map((row) => (
              <tr key={row[0]} className="border-t border-border">
                <td className="p-3">{row[0]}</td>
                <td className="p-3">{row[1]}</td>
                <td className="p-3">{row[2]}</td>
                <td className="p-3">
                  <StatusBadge status={row[3]} />
                </td>
                <td className="flex gap-2 p-3">
                  <Button size="sm">{copy.actionApprove}</Button>
                  <Button size="sm" variant="outline">
                    {copy.actionReject}
                  </Button>
                  <Button size="sm" variant="outline">
                    {copy.actionHide}
                  </Button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
