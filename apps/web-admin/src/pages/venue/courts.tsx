import { Plus, Pencil, ChevronLeft, ChevronRight } from 'lucide-react'
import { useState, type ChangeEvent } from 'react'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { FormField, SelectField } from '@/components/ui/form-field'
import { Modal } from '@/components/ui/modal'
import { useCourts, useCreateCourt, useSetCourtStatus, useUpdateCourt } from '@/hooks/venue/use-courts'
import { useMyVenue } from '@/hooks/venue/use-my-venue'
import type { CourtResponse } from '@/types/api'

const STATUS_BADGE: Record<string, string> = {
  ACTIVE: 'bg-green-900/50 text-green-300',
  MAINTENANCE: 'bg-amber-900/50 text-amber-300',
  INACTIVE: 'bg-muted text-muted-foreground',
}

export function VenueCourtsPage() {
  const { data: venue } = useMyVenue()
  const venueId = venue?.id ?? ''
  const { data: courts, isLoading } = useCourts(venueId)
  const createCourt = useCreateCourt(venueId)
  const updateCourt = useUpdateCourt(venueId)
  const setStatus = useSetCourtStatus(venueId)

  const [page, setPage] = useState(1)
  const pageSize = 6

  const [showModal, setShowModal] = useState(false)
  const [editingCourt, setEditingCourt] = useState<CourtResponse | null>(null)
  const [form, setForm] = useState({
    name: '',
    courtType: 'STANDARD',
    pricePerHour: '',
    description: '',
  })

  const set =
    (key: keyof typeof form) =>
    (event: ChangeEvent<HTMLInputElement | HTMLSelectElement>) =>
      setForm((current) => ({ ...current, [key]: event.target.value }))

  const handleOpenCreate = () => {
    setEditingCourt(null)
    setForm({ name: '', courtType: 'STANDARD', pricePerHour: '', description: '' })
    setShowModal(true)
  }

  const handleOpenEdit = (court: CourtResponse) => {
    setEditingCourt(court)
    setForm({
      name: court.name,
      courtType: court.courtType,
      pricePerHour: String(court.pricePerHour),
      description: court.description || '',
    })
    setShowModal(true)
  }

  const handleSave = async () => {
    if (editingCourt) {
      await updateCourt.mutateAsync({
        courtId: editingCourt.id,
        request: {
          name: form.name,
          courtType: form.courtType,
          pricePerHour: Number(form.pricePerHour),
          description: form.description || undefined,
        },
      })
      toast.success('Đã cập nhật thông tin sân')
    } else {
      await createCourt.mutateAsync({
        name: form.name,
        courtType: form.courtType,
        pricePerHour: Number(form.pricePerHour),
        description: form.description || undefined,
      })
      toast.success('Đã thêm sân mới')
    }
    setShowModal(false)
    setForm({ name: '', courtType: 'STANDARD', pricePerHour: '', description: '' })
  }

  const handleStatusChange = (court: CourtResponse, status: string) => {
    setStatus.mutate(
      { courtId: court.id, status },
      { onSuccess: () => toast.success(`Đã đổi trạng thái ${court.name} → ${status}`) },
    )
  }

  const items = courts ?? []
  const totalElements = items.length
  const totalPages = Math.max(1, Math.ceil(totalElements / pageSize))
  const currentPage = Math.min(page, totalPages)
  const startIndex = (currentPage - 1) * pageSize
  const endIndex = startIndex + pageSize
  const paginatedCourts = items.slice(startIndex, endIndex)

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Quản lý sân</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Trang {currentPage} / {totalPages} (Tổng số {totalElements} sân)
          </p>
        </div>
        <Button onClick={handleOpenCreate}>
          <Plus className="mr-1.5 size-4" />
          Thêm sân
        </Button>
      </div>

      {isLoading && <p className="text-sm text-muted-foreground">Đang tải...</p>}

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {paginatedCourts.map((court) => (
          <div key={court.id} className="space-y-3 rounded-xl border border-border bg-card p-4">
            <div className="flex items-start justify-between">
              <p className="font-semibold">{court.name}</p>
              <div className="flex items-center gap-2">
                <span className={`rounded-full px-2 py-0.5 text-xs font-medium ${STATUS_BADGE[court.status]}`}>
                  {court.status}
                </span>
                <button
                  type="button"
                  onClick={() => handleOpenEdit(court)}
                  className="rounded p-1 text-muted-foreground hover:bg-muted hover:text-foreground"
                  title="Chỉnh sửa sân"
                >
                  <Pencil className="size-3.5" />
                </button>
              </div>
            </div>
            <p className="text-xs text-muted-foreground">
              {court.courtType} · <span className="font-medium text-[#0d7c5f]">{court.pricePerHour.toLocaleString('vi-VN')}đ/h</span>
            </p>
            {court.description && <p className="text-xs text-muted-foreground">{court.description}</p>}
            <select
              value={court.status}
              onChange={(event) => handleStatusChange(court, event.target.value)}
              className="w-full rounded-md border border-input bg-background px-2 py-1.5 text-xs"
            >
              <option value="ACTIVE">ACTIVE</option>
              <option value="MAINTENANCE">MAINTENANCE</option>
              <option value="INACTIVE">INACTIVE</option>
            </select>
          </div>
        ))}

        {paginatedCourts.length < pageSize && (
          <button
            type="button"
            onClick={handleOpenCreate}
            className="flex min-h-[140px] items-center justify-center rounded-xl border-2 border-dashed border-border bg-card/50 text-muted-foreground transition-colors hover:border-[#0d7c5f] hover:text-[#0d7c5f]"
          >
            <div className="text-center">
              <Plus className="mx-auto size-6" />
              <p className="mt-1 text-xs">Thêm sân mới</p>
            </div>
          </button>
        )}
      </div>

      {totalElements > 0 && (
        <div className="flex items-center justify-between border-t border-border pt-4">
          <p className="text-xs text-muted-foreground">
            Hiển thị {startIndex + 1} - {Math.min(endIndex, totalElements)} trên tổng số {totalElements} sân
          </p>
          <div className="flex items-center gap-2">
            <Button
              variant="outline"
              size="icon"
              disabled={currentPage <= 1}
              onClick={() => setPage((current) => current - 1)}
            >
              <ChevronLeft className="size-4" />
            </Button>
            <span className="text-sm text-muted-foreground">
              {currentPage} / {totalPages}
            </span>
            <Button
              variant="outline"
              size="icon"
              disabled={currentPage >= totalPages}
              onClick={() => setPage((current) => current + 1)}
            >
              <ChevronRight className="size-4" />
            </Button>
          </div>
        </div>
      )}

      <Modal
        open={showModal}
        onClose={() => setShowModal(false)}
        title={editingCourt ? 'Chỉnh sửa thông tin sân' : 'Thêm sân mới'}
        footer={
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setShowModal(false)}>
              Hủy
            </Button>
            <Button
              onClick={() => void handleSave()}
              disabled={createCourt.isPending || updateCourt.isPending || !form.name || !form.pricePerHour}
            >
              {createCourt.isPending || updateCourt.isPending ? 'Đang lưu...' : editingCourt ? 'Lưu thay đổi' : 'Thêm sân'}
            </Button>
          </div>
        }
      >
        <div className="space-y-4">
          <FormField label="Tên sân *" value={form.name} onChange={set('name')} placeholder="Sân 1" />
          <SelectField
            label="Loại sân *"
            value={form.courtType}
            onChange={set('courtType')}
            options={[
              { value: 'STANDARD', label: 'STANDARD' },
              { value: 'VIP', label: 'VIP' },
              { value: 'OUTDOOR', label: 'OUTDOOR' },
            ]}
          />
          <FormField label="Giá/giờ (VND) *" type="number" value={form.pricePerHour} onChange={set('pricePerHour')} placeholder="100000" />
          <FormField label="Mô tả" value={form.description} onChange={set('description')} placeholder="Tùy chọn" />
        </div>
      </Modal>
    </div>
  )
}
