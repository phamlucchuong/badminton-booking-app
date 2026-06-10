import { cn } from '@/lib/utils'

type Status =
  | 'Active'
  | 'Locked'
  | 'Pending'
  | 'Verified'
  | 'Rejected'
  | 'Approved'
  | 'Hidden'
  | 'Paid'
  | 'Failed'
  | 'Refunded'
  | 'Success'

const tones: Record<Status, string> = {
  Active: 'bg-emerald-50 text-emerald-700 border-emerald-200',
  Locked: 'bg-slate-100 text-slate-700 border-slate-200',
  Pending: 'bg-amber-50 text-amber-700 border-amber-200',
  Verified: 'bg-emerald-50 text-emerald-700 border-emerald-200',
  Rejected: 'bg-red-50 text-red-700 border-red-200',
  Approved: 'bg-emerald-50 text-emerald-700 border-emerald-200',
  Hidden: 'bg-slate-100 text-slate-700 border-slate-200',
  Paid: 'bg-emerald-50 text-emerald-700 border-emerald-200',
  Failed: 'bg-red-50 text-red-700 border-red-200',
  Refunded: 'bg-sky-50 text-sky-700 border-sky-200',
  Success: 'bg-emerald-50 text-emerald-700 border-emerald-200',
}

export function StatusBadge({ status }: { status: Status | string }) {
  return (
    <span
      className={cn(
        'inline-flex items-center rounded-full border px-2.5 py-1 text-xs font-medium',
        tones[status as Status] ?? 'bg-slate-100 text-slate-700 border-slate-200',
      )}
    >
      {status}
    </span>
  )
}
