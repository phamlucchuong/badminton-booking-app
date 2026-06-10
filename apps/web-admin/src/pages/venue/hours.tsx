import { useState } from 'react'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { useOperatingHours, useUpdateOperatingHours } from '@/hooks/venue/use-operating-hours'
import { useMyVenue } from '@/hooks/venue/use-my-venue'
import { cn } from '@/lib/utils'
import type { VenueOperatingHourRequest, VenueOperatingHourResponse } from '@/types/api'

const DAYS: { key: string; label: string }[] = [
  { key: 'MONDAY', label: 'Thứ 2' },
  { key: 'TUESDAY', label: 'Thứ 3' },
  { key: 'WEDNESDAY', label: 'Thứ 4' },
  { key: 'THURSDAY', label: 'Thứ 5' },
  { key: 'FRIDAY', label: 'Thứ 6' },
  { key: 'SATURDAY', label: 'Thứ 7' },
  { key: 'SUNDAY', label: 'Chủ nhật' },
]

const DEFAULT_HOURS: VenueOperatingHourRequest[] = DAYS.map((day) => ({
  dayOfWeek: day.key,
  openTime: '06:00',
  closeTime: '22:00',
  closed: false,
}))

export function VenueHoursPage() {
  const { data: venue } = useMyVenue()
  const venueId = venue?.id ?? ''
  const { data: serverHours, isLoading } = useOperatingHours(venueId)

  if (isLoading) {
    return <div className="py-16 text-center text-sm text-muted-foreground">Đang tải...</div>
  }

  return <VenueHoursEditor key={venueId || 'default'} venueId={venueId} serverHours={serverHours ?? []} />
}

function VenueHoursEditor({
  venueId,
  serverHours,
}: {
  venueId: string
  serverHours: VenueOperatingHourResponse[]
}) {
  const update = useUpdateOperatingHours(venueId)
  const [hours, setHours] = useState<VenueOperatingHourRequest[]>(
    serverHours.length > 0
      ? DAYS.map((day) => {
          const found = serverHours.find((hour) => hour.dayOfWeek === day.key)
          return {
            dayOfWeek: day.key,
            openTime: found?.openTime?.slice(0, 5) ?? '06:00',
            closeTime: found?.closeTime?.slice(0, 5) ?? '22:00',
            closed: found?.closed ?? false,
          }
        })
      : DEFAULT_HOURS,
  )

  const updateDay = (
    index: number,
    field: keyof VenueOperatingHourRequest,
    value: string | boolean,
  ) =>
    setHours((current) => current.map((hour, hourIndex) => (hourIndex === index ? { ...hour, [field]: value } : hour)))

  const handleSave = async () => {
    await update.mutateAsync(
      hours.map((hour) => ({
        ...hour,
        openTime: hour.closed ? null : hour.openTime,
        closeTime: hour.closed ? null : hour.closeTime,
      })),
    )
    toast.success('Đã lưu giờ hoạt động')
  }
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Giờ hoạt động</h1>
        <Button onClick={() => void handleSave()} disabled={update.isPending}>
          {update.isPending ? 'Đang lưu...' : 'Lưu thay đổi'}
        </Button>
      </div>

      <div className="overflow-hidden rounded-xl border border-border bg-card">
        <div className="grid grid-cols-[130px_1fr_1fr_100px] gap-0 border-b border-border bg-muted/50 px-4 py-3 text-xs font-medium uppercase tracking-wide text-muted-foreground">
          <span>Ngày</span>
          <span>Giờ mở</span>
          <span>Giờ đóng</span>
          <span>Trạng thái</span>
        </div>

        {DAYS.map((day, index) => {
          const row = hours[index]
          return (
            <div
              key={day.key}
              className={cn(
                'grid grid-cols-[130px_1fr_1fr_100px] items-center gap-0 border-t border-border px-4 py-3',
                row.closed && 'opacity-50',
              )}
            >
              <span className="text-sm font-medium">{day.label}</span>
              <input
                type="time"
                value={row.openTime ?? ''}
                disabled={row.closed}
                onChange={(event) => updateDay(index, 'openTime', event.target.value)}
                className="h-9 w-28 rounded-md border border-input bg-background px-2 text-sm disabled:cursor-not-allowed"
              />
              <input
                type="time"
                value={row.closeTime ?? ''}
                disabled={row.closed}
                onChange={(event) => updateDay(index, 'closeTime', event.target.value)}
                className="h-9 w-28 rounded-md border border-input bg-background px-2 text-sm disabled:cursor-not-allowed"
              />
              <button
                type="button"
                onClick={() => updateDay(index, 'closed', !row.closed)}
                className={cn(
                  'rounded-full px-3 py-1 text-xs font-medium transition-colors',
                  row.closed
                    ? 'bg-muted text-muted-foreground hover:bg-accent'
                    : 'bg-green-900/50 text-green-300 hover:bg-green-900/70',
                )}
              >
                {row.closed ? 'Nghỉ' : 'Mở cửa'}
              </button>
            </div>
          )
        })}
      </div>
    </div>
  )
}
