import { useState, type ChangeEvent } from 'react'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { FormField } from '@/components/ui/form-field'
import { useMyVenue } from '@/hooks/venue/use-my-venue'
import { useCreateVenueProfile, useUpdateVenue } from '@/hooks/venue/use-update-venue'
import type { VenueResponse } from '@/types/api'

const STATUS_LABEL: Record<string, string> = {
  PENDING: 'Đang chờ duyệt',
  ACTIVE: 'Đang hoạt động',
  SUSPENDED: 'Đã tạm dừng',
  REJECTED: 'Đã từ chối',
}

const STATUS_COLOR: Record<string, string> = {
  PENDING: 'bg-amber-900/50 text-amber-300',
  ACTIVE: 'bg-green-900/50 text-green-300',
  SUSPENDED: 'bg-red-900/50 text-red-300',
  REJECTED: 'bg-red-900/50 text-red-300',
}

export function VenueProfilePage() {
  const { data: venue, isLoading } = useMyVenue()

  if (isLoading) {
    return <div className="py-16 text-center text-sm text-muted-foreground">Đang tải...</div>
  }

  return <VenueProfileForm key={venue?.id ?? 'new'} venue={venue} />
}

function VenueProfileForm({ venue }: { venue?: VenueResponse }) {
  const update = useUpdateVenue(venue?.id ?? '')
  const create = useCreateVenueProfile()

  const [form, setForm] = useState({
    name: venue?.name ?? '',
    address: venue?.address ?? '',
    description: venue?.description ?? '',
    openTime: venue?.openTime?.slice(0, 5) ?? '06:00',
    closeTime: venue?.closeTime?.slice(0, 5) ?? '22:00',
    bankName: '',
    bankNumber: '',
    bankAccountName: '',
    licenseId: venue?.licenseId ?? '',
    latitude: venue?.latitude?.toString() ?? '',
    longitude: venue?.longitude?.toString() ?? '',
  })

  const set =
    (key: keyof typeof form) =>
    (event: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
      setForm((current) => ({ ...current, [key]: event.target.value }))

  const handleSave = async () => {
    if (venue) {
      await update.mutateAsync({
        name: form.name,
        address: form.address,
        description: form.description || undefined,
        openTime: form.openTime || undefined,
        closeTime: form.closeTime || undefined,
        bankName: form.bankName || undefined,
        bankNumber: form.bankNumber || undefined,
        bankAccountName: form.bankAccountName || undefined,
        latitude: form.latitude ? Number(form.latitude) : undefined,
        longitude: form.longitude ? Number(form.longitude) : undefined,
      })
      toast.success('Đã lưu thông tin sân')
    } else {
      await create.mutateAsync({
        name: form.name,
        address: form.address,
        description: form.description || undefined,
        openTime: form.openTime || undefined,
        closeTime: form.closeTime || undefined,
        bankName: form.bankName || undefined,
        bankNumber: form.bankNumber || undefined,
        bankAccountName: form.bankAccountName || undefined,
        licenseId: form.licenseId,
        latitude: Number(form.latitude),
        longitude: Number(form.longitude),
      })
      toast.success('Đã tạo sân thành công')
    }
  }

  const isPending = update.isPending || create.isPending

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Thông tin venue</h1>
          {venue && (
            <span
              className={`mt-1 inline-block rounded-full px-2 py-0.5 text-xs font-medium ${STATUS_COLOR[venue.status]}`}
            >
              {STATUS_LABEL[venue.status]}
            </span>
          )}
        </div>
        <Button
          onClick={() => void handleSave()}
          disabled={
            isPending ||
            !form.name ||
            !form.address ||
            (!venue && (!form.licenseId || !form.latitude || !form.longitude))
          }
        >
          {isPending ? 'Đang lưu...' : venue ? 'Lưu thay đổi' : 'Tạo venue'}
        </Button>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <div className="space-y-4 rounded-xl border border-border bg-card p-5">
          <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
            Thông tin cơ bản
          </p>
          <FormField label="Tên sân *" value={form.name} onChange={set('name')} placeholder="Sân cầu lông ABC" />
          <FormField label="Địa chỉ *" value={form.address} onChange={set('address')} placeholder="123 Nguyễn Trãi, Q.1" />
          <div>
            <label className="text-sm font-medium">Mô tả</label>
            <textarea
              value={form.description}
              onChange={set('description')}
              rows={3}
              className="mt-1.5 h-20 w-full resize-none rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-ring"
            />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <FormField label="Giờ mở cửa" type="time" value={form.openTime} onChange={set('openTime')} />
            <FormField label="Giờ đóng cửa" type="time" value={form.closeTime} onChange={set('closeTime')} />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <FormField label="Latitude *" type="number" step="any" value={form.latitude} onChange={set('latitude')} placeholder="10.7769" />
            <FormField label="Longitude *" type="number" step="any" value={form.longitude} onChange={set('longitude')} placeholder="106.7009" />
          </div>
          {!venue && (
            <FormField label="Mã giấy phép *" value={form.licenseId} onChange={set('licenseId')} placeholder="GP-2026-001" />
          )}
        </div>

        <div className="space-y-4 rounded-xl border border-border bg-card p-5">
          <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
            Thông tin ngân hàng
          </p>
          <FormField label="Tên ngân hàng" value={form.bankName} onChange={set('bankName')} placeholder="Vietcombank" />
          <FormField label="Số tài khoản" value={form.bankNumber} onChange={set('bankNumber')} placeholder="1234567890" />
          <FormField label="Tên chủ tài khoản" value={form.bankAccountName} onChange={set('bankAccountName')} placeholder="NGUYEN VAN A" />
          {venue && (
            <div className="rounded-md border border-border bg-muted/30 p-4 text-xs text-muted-foreground">
              <p className="font-medium text-foreground">Lưu ý</p>
              <p className="mt-1">
                Bạn có thể cập nhật thông tin hiển thị và ngân hàng tại đây. Tọa độ được giữ để đồng bộ
                vị trí sân trên hệ thống.
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
