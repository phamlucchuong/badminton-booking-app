import { Button } from '@/components/ui/button'
import { StatusBadge } from '@/components/ui/status-badge'
import { useCopy } from '@/lib/copy'

export function AdminUsersPage() {
  const copy = useCopy()

  return (
    <div className="space-y-5">
      <h1 className="text-2xl font-bold">{copy.usersTitle}</h1>
      <div className="card-surface overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="bg-muted/50 text-left">
            <tr>
              <th className="p-3">Avatar</th>
              <th className="p-3">Name</th>
              <th className="p-3">Email</th>
              <th className="p-3">Role</th>
              <th className="p-3">Status</th>
              <th className="p-3">Actions</th>
            </tr>
          </thead>
          <tbody>
            {[
              ['Lan Anh', 'lan@example.com', copy.roleCandidate, 'Active' as const],
              ['Nguyen HR', 'hr@company.vn', copy.roleEmployer, 'Locked' as const],
            ].map((user) => (
              <tr key={user[1]} className="border-t border-border">
                <td className="p-3">
                  <div className="flex size-8 items-center justify-center rounded-full bg-primary/15 font-semibold text-primary">
                    {user[0][0]}
                  </div>
                </td>
                <td className="p-3">{user[0]}</td>
                <td className="p-3">{user[1]}</td>
                <td className="p-3">{user[2]}</td>
                <td className="p-3">
                  <StatusBadge status={user[3]} />
                </td>
                <td className="p-3">
                  <Button variant="outline" size="sm">
                    {user[3] === 'Locked' ? copy.actionUnlock : copy.actionLock}
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
