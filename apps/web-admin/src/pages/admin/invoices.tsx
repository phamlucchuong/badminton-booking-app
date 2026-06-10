import type { ChangeEvent, ReactNode } from 'react'
import { useState } from 'react'
import { Plus } from 'lucide-react'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { DataTable } from '@/components/ui/data-table'
import { FormField, SelectField } from '@/components/ui/form-field'
import { Modal } from '@/components/ui/modal'
import {
  useAdminInvoices,
  useGenerateInvoice,
  useMarkInvoicePaid,
} from '@/hooks/admin/use-admin-invoices'
import { useAdminVenuesAll } from '@/hooks/admin/use-admin-venues'
import type { PlatformFeeInvoice } from '@/types/api'

type FilterStatus = 'all' | 'pending' | 'paid'
type TableColumn<T> = {
  key: string
  header: string
  render?: (row: T) => ReactNode
  className?: string
}

export function AdminInvoicesPage() {
  const { data: invoices, isLoading } = useAdminInvoices()
  const { data: venuesPage } = useAdminVenuesAll()
  const generateInvoice = useGenerateInvoice()
  const markPaid = useMarkInvoicePaid()
  const [filter, setFilter] = useState<FilterStatus>('pending')
  const [showModal, setShowModal] = useState(false)
  const [form, setForm] = useState({ venueId: '', period: '' })

  const allInvoices = invoices ?? []
  const filtered =
    filter === 'all'
      ? allInvoices
      : filter === 'pending'
        ? allInvoices.filter((invoice) => invoice.status === 'PENDING')
        : allInvoices.filter((invoice) => invoice.status === 'PAID')
  const venues = venuesPage?.content ?? venuesPage?.items ?? []

  const setField =
    (key: keyof typeof form) =>
    (event: ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
      setForm((current) => ({ ...current, [key]: event.target.value }))
    }

  const handleGenerate = async () => {
    if (!/^\d{4}-\d{2}$/.test(form.period)) {
      toast.error('Ky phai co dinh dang YYYY-MM, vi du 2026-06')
      return
    }

    await generateInvoice.mutateAsync(
      { venueId: form.venueId, period: form.period },
      {
        onSuccess: () => {
          toast.success('Da tao hoa don')
          setShowModal(false)
          setForm({ venueId: '', period: '' })
        },
        onError: () => toast.error('Tao hoa don that bai'),
      },
    )
  }

  const handleMarkPaid = (invoice: PlatformFeeInvoice) => {
    markPaid.mutate(invoice.id, {
      onSuccess: () => {
        toast.success(`Da danh dau dong hoa don ${invoice.venue.name} / ${invoice.period}`)
      },
      onError: () => toast.error('Cap nhat that bai'),
    })
  }

  const columns: TableColumn<PlatformFeeInvoice>[] = [
    {
      key: 'venue',
      header: 'Venue',
      render: (invoice) => <span className="font-medium">{invoice.venue.name}</span>,
    },
    { key: 'period', header: 'Ky' },
    {
      key: 'totalBookings',
      header: 'Booking',
      render: (invoice) => String(invoice.totalBookings),
    },
    {
      key: 'totalRevenue',
      header: 'Doanh thu',
      render: (invoice) => `${invoice.totalRevenue.toLocaleString('vi-VN')}d`,
    },
    {
      key: 'feeAmount',
      header: 'Phi nen tang',
      render: (invoice) => (
        <span className="font-semibold text-amber-400">
          {invoice.feeAmount.toLocaleString('vi-VN')}d
        </span>
      ),
    },
    { key: 'dueDate', header: 'Han dong' },
    {
      key: 'status',
      header: 'Trang thai',
      render: (invoice) => (
        <span
          className={`rounded-full px-2 py-0.5 text-xs font-medium ${
            invoice.status === 'PAID'
              ? 'bg-emerald-900/50 text-emerald-300'
              : 'bg-amber-900/50 text-amber-300'
          }`}
        >
          {invoice.status === 'PAID' ? 'Da dong' : 'Chua dong'}
        </span>
      ),
    },
    {
      key: 'action',
      header: '',
      render: (invoice) =>
        invoice.status === 'PENDING' ? (
          <button
            type="button"
            disabled={markPaid.isPending}
            onClick={() => handleMarkPaid(invoice)}
            className="rounded bg-emerald-700 px-2 py-1 text-xs text-white disabled:opacity-50"
          >
            Da dong
          </button>
        ) : (
          <span className="text-xs text-muted-foreground">-</span>
        ),
    },
  ]

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold">Hoa don phi nen tang</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            {allInvoices.filter((invoice) => invoice.status === 'PENDING').length} chua dong
          </p>
        </div>
        <div className="flex items-center gap-3">
          <select
            value={filter}
            onChange={(event) => setFilter(event.target.value as FilterStatus)}
            className="h-9 rounded-md border border-input bg-background px-3 text-sm"
          >
            <option value="all">Tat ca</option>
            <option value="pending">Chua dong</option>
            <option value="paid">Da dong</option>
          </select>
          <Button onClick={() => setShowModal(true)}>
            <Plus className="mr-1.5 size-4" />
            Tao hoa don
          </Button>
        </div>
      </div>

      <DataTable
        columns={columns}
        data={filtered}
        loading={isLoading}
        keyExtractor={(invoice) => invoice.id}
        emptyMessage="Khong co hoa don"
      />

      <Modal
        open={showModal}
        onClose={() => setShowModal(false)}
        title="Tao hoa don"
        footer={
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setShowModal(false)}>
              Huy
            </Button>
            <Button
              onClick={() => void handleGenerate()}
              disabled={generateInvoice.isPending || !form.venueId || !form.period}
            >
              {generateInvoice.isPending ? 'Dang tao...' : 'Tao hoa don'}
            </Button>
          </div>
        }
      >
        <div className="space-y-4">
          <SelectField
            label="Venue *"
            value={form.venueId}
            onChange={setField('venueId')}
            options={[
              { value: '', label: 'Chon venue...' },
              ...venues.map((venue) => ({ value: venue.id, label: venue.name })),
            ]}
          />
          <FormField
            label="Ky * (YYYY-MM)"
            value={form.period}
            onChange={setField('period')}
            placeholder="2026-06"
            pattern="\\d{4}-\\d{2}"
          />
          <p className="text-xs text-muted-foreground">
            Vi du: <code>2026-06</code> cho thang 6 nam 2026
          </p>
        </div>
      </Modal>
    </div>
  )
}
