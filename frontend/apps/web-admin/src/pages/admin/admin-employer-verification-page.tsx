import { Button } from '@/components/ui/button'
import { StatusBadge } from '@/components/ui/status-badge'
import { useCopy } from '@/lib/copy'

export function AdminEmployerVerificationPage() {
  const copy = useCopy()

  return (
    <div className="space-y-5">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-bold">{copy.employerVerificationTitle}</h1>
        <select className="h-9 rounded-md border border-input bg-background px-3 text-sm">
          <option>{copy.allStatus}</option>
          <option>Pending</option>
          <option>Verified</option>
          <option>Rejected</option>
        </select>
      </div>

      <div className="card-surface overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="bg-muted/50 text-left">
            <tr>
              <th className="p-3">Venue</th>
              <th className="p-3">Representative</th>
              <th className="p-3">Submitted</th>
              <th className="p-3">Document</th>
              <th className="p-3">Status</th>
              <th className="p-3">Actions</th>
            </tr>
          </thead>
          <tbody>
            {[
              ['Sân 3T', 'Tran Minh', '2026-05-21', 'Business license', 'Pending' as const],
              ['Royal Court', 'Le Huy', '2026-05-18', 'Ownership file', 'Rejected' as const],
            ].map((row) => (
              <tr key={row[0]} className="border-t border-border">
                <td className="p-3">{row[0]}</td>
                <td className="p-3">{row[1]}</td>
                <td className="p-3">{row[2]}</td>
                <td className="p-3">{row[3]}</td>
                <td className="p-3">
                  <StatusBadge status={row[4]} />
                </td>
                <td className="flex gap-2 p-3">
                  <Button size="sm">{copy.actionApprove}</Button>
                  <Button size="sm" variant="outline">
                    {copy.actionReject}
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
