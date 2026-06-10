import type { ReactNode } from 'react'
import { useState } from 'react'
import { toast } from 'sonner'
import { ChevronLeft, ChevronRight } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { DataTable } from '@/components/ui/data-table'
import { Modal } from '@/components/ui/modal'
import {
  useAdminVenuesAll,
  useAdminVenuesPending,
  useApproveVenue,
  useRejectVenue,
  useSuspendVenue,
} from '@/hooks/admin/use-admin-venues'
import type { VenueResponse } from '@/types/api'

type TableColumn<T> = {
  key: string
  header: string
  render?: (row: T) => ReactNode
  className?: string
}

const STATUS_BADGE: Record<string, string> = {
  PENDING: 'bg-amber-900/50 text-amber-300',
  ACTIVE: 'bg-emerald-900/50 text-emerald-300',
  SUSPENDED: 'bg-red-900/50 text-red-300',
  REJECTED: 'bg-slate-700 text-slate-300',
}

export function AdminVenuesPage() {
  const [page, setPage] = useState(1)
  const { data: pendingPage, isLoading: pendingLoading } = useAdminVenuesPending()
  const { data: allPage, isLoading: allLoading } = useAdminVenuesAll(page, 10)
  const approve = useApproveVenue()
  const reject = useRejectVenue()
  const suspend = useSuspendVenue()
  const [selected, setSelected] = useState<VenueResponse | null>(null)

  const pending = pendingPage?.content ?? pendingPage?.items ?? []
  const venues = allPage?.content ?? allPage?.items ?? []
  const totalPages = allPage?.totalPages ?? 1
  const totalElements = allPage?.totalElements ?? allPage?.total ?? 0
  const anyPending = approve.isPending || reject.isPending || suspend.isPending

  const closeModal = () => setSelected(null)

  const handleAction = (action: 'approve' | 'reject' | 'suspend', venue: VenueResponse) => {
    const label =
      action === 'approve'
        ? 'Phe duyet'
        : action === 'reject'
          ? 'Tu choi'
          : 'Tam dung'
    const mutation =
      action === 'approve' ? approve : action === 'reject' ? reject : suspend

    mutation.mutate(venue.id, {
      onSuccess: () => {
        toast.success(`${label} "${venue.name}" thanh cong`)
        closeModal()
      },
      onError: () => toast.error(`${label} that bai`),
    })
  }

  const columns: TableColumn<VenueResponse>[] = [
    {
      key: 'name',
      header: 'Ten san',
      render: (venue) => (
        <div>
          <p className="font-medium">{venue.name}</p>
          <p className="text-xs text-muted-foreground">{venue.address}</p>
        </div>
      ),
    },
    { key: 'ownerName', header: 'Chu san' },
    {
      key: 'status',
      header: 'Trang thai',
      render: (venue) => (
        <span
          className={`rounded-full px-2 py-0.5 text-xs font-medium ${STATUS_BADGE[venue.status] ?? 'bg-slate-700 text-slate-300'}`}
        >
          {venue.status}
        </span>
      ),
    },
    {
      key: 'action',
      header: '',
      render: (venue) => (
        <button
          type="button"
          onClick={() => setSelected(venue)}
          className="text-xs text-blue-400 hover:underline"
        >
          Xem chi tiet
        </button>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Quan ly venue</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          Trang {page} / {totalPages} (Tong so {totalElements} venue, {pending.length} cho duyet)
        </p>
      </div>

      <DataTable
        columns={columns}
        data={venues}
        loading={pendingLoading || allLoading}
        keyExtractor={(venue) => venue.id}
        emptyMessage="Khong co venue nao"
      />

      <div className="flex items-center justify-end gap-2">
        <Button
          variant="outline"
          size="icon"
          disabled={page <= 1}
          onClick={() => setPage((current) => current - 1)}
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
          onClick={() => setPage((current) => current + 1)}
        >
          <ChevronRight className="size-4" />
        </Button>
      </div>

      <Modal
        open={!!selected}
        onClose={closeModal}
        title="Chi tiet venue"
        footer={
          selected ? (
            <div className="flex gap-2">
              {(selected.status === 'PENDING' || selected.status === 'SUSPENDED') && (
                <Button
                  disabled={anyPending}
                  onClick={() => handleAction('approve', selected)}
                  className="bg-emerald-700 hover:bg-emerald-600"
                >
                  {selected.status === 'SUSPENDED' ? 'Kich hoat lai' : 'Phe duyet'}
                </Button>
              )}
              {selected.status === 'PENDING' && (
                <Button
                  variant="outline"
                  disabled={anyPending}
                  onClick={() => {
                    if (!window.confirm(`Tu choi venue "${selected.name}"?`)) return
                    handleAction('reject', selected)
                  }}
                  className="border-red-700 text-red-400 hover:bg-red-950"
                >
                  Tu choi
                </Button>
              )}
              {selected.status === 'ACTIVE' && (
                <Button
                  variant="outline"
                  disabled={anyPending}
                  onClick={() => {
                    if (!window.confirm(`Tam dung venue "${selected.name}"?`)) return
                    handleAction('suspend', selected)
                  }}
                  className="border-amber-700 text-amber-400 hover:bg-amber-950"
                >
                  Tam dung
                </Button>
              )}
              <Button variant="outline" onClick={closeModal}>
                Dong
              </Button>
            </div>
          ) : null
        }
      >
        {selected && (
          <div className="space-y-4">
            <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
              <div>
                <p className="text-xs text-muted-foreground">TEN SAN</p>
                <p className="mt-0.5 font-medium">{selected.name}</p>
              </div>
              <div>
                <p className="text-xs text-muted-foreground">CHU SAN</p>
                <p className="mt-0.5 font-medium">{selected.ownerName}</p>
              </div>
              <div>
                <p className="text-xs text-muted-foreground">DIA CHI</p>
                <p className="mt-0.5 text-sm">{selected.address}</p>
              </div>
              <div>
                <p className="text-xs text-muted-foreground">MA GIAY PHEP</p>
                <p className="mt-0.5 font-mono text-sm text-amber-400">
                  {selected.licenseId ?? '-'}
                </p>
              </div>
              <div>
                <p className="text-xs text-muted-foreground">GIO HOAT DONG</p>
                <p className="mt-0.5 text-sm">
                  {selected.openTime?.slice(0, 5)} - {selected.closeTime?.slice(0, 5)}
                </p>
              </div>
              <div>
                <p className="text-xs text-muted-foreground">TRANG THAI</p>
                <span
                  className={`mt-0.5 inline-block rounded-full px-2 py-0.5 text-xs font-medium ${STATUS_BADGE[selected.status] ?? 'bg-slate-700 text-slate-300'}`}
                >
                  {selected.status}
                </span>
              </div>
            </div>
            {selected.description && (
              <div>
                <p className="text-xs text-muted-foreground">MO TA</p>
                <p className="mt-0.5 text-sm">{selected.description}</p>
              </div>
            )}
          </div>
        )}
      </Modal>
    </div>
  )
}
