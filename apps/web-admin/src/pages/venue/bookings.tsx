import { ChevronLeft, ChevronRight } from 'lucide-react'
import { useState } from 'react'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { useCourts } from '@/hooks/venue/use-courts'
import {
  useCancelBooking,
  useCompleteBooking,
  useConfirmBooking,
  useVenueBookings,
} from '@/hooks/venue/use-venue-bookings'
import { useMyVenue } from '@/hooks/venue/use-my-venue'
import { cn } from '@/lib/utils'

const STATUS_BLOCK: Record<string, string> = {
  PENDING: 'border-amber-500 bg-amber-900/30 text-amber-200',
  CONFIRMED: 'border-blue-500 bg-blue-900/30 text-blue-200',
  COMPLETED: 'border-green-500 bg-green-900/30 text-green-200',
  IN_PROGRESS: 'border-green-500 bg-green-900/30 text-green-200',
  CANCELLED: 'border-border bg-muted/20 text-muted-foreground',
}

const toMinutes = (time: string) => {
  const [hours, minutes] = time.split(':').map(Number)
  return hours * 60 + minutes
}

const toPercent = (time: string, open: string, close: string) => {
  const openMinutes = toMinutes(open)
  const closeMinutes = toMinutes(close)
  return Math.max(0, Math.min(100, ((toMinutes(time) - openMinutes) / (closeMinutes - openMinutes)) * 100))
}

const fmtDate = (date: Date) =>
  `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`

const fmtDateLabel = (iso: string) => {
  const date = new Date(iso)
  return date.toLocaleDateString('vi-VN', {
    weekday: 'short',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  })
}

export function VenueBookingsPage() {
  const { data: venue } = useMyVenue()
  const venueId = venue?.id ?? ''
  const openTime = venue?.openTime ?? '06:00:00'
  const closeTime = venue?.closeTime ?? '22:00:00'

  const [selectedDate, setSelectedDate] = useState(fmtDate(new Date()))

  const { data: bookingsPage, isLoading } = useVenueBookings(venueId)
  const { data: courts } = useCourts(venueId)

  const confirm = useConfirmBooking(venueId)
  const cancel = useCancelBooking(venueId)
  const complete = useCompleteBooking(venueId)

  const allBookings = bookingsPage?.items ?? []
  const dayBookings = allBookings.filter((booking) => booking.bookingDate === selectedDate)
  const pending = dayBookings.filter((booking) => booking.status === 'PENDING')
  const confirmed = dayBookings.filter((booking) => booking.status === 'CONFIRMED')

  const changeDate = (delta: number) => {
    const date = new Date(selectedDate)
    date.setDate(date.getDate() + delta)
    setSelectedDate(fmtDate(date))
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Bookings</h1>
        <div className="flex items-center gap-2">
          <Button variant="outline" size="icon" onClick={() => changeDate(-1)}>
            <ChevronLeft className="size-4" />
          </Button>
          <div className="min-w-[180px] rounded-lg border border-[#0d7c5f]/50 bg-card px-3 py-1.5 text-center text-sm">
            {fmtDateLabel(selectedDate)}
          </div>
          <Button variant="outline" size="icon" onClick={() => changeDate(1)}>
            <ChevronRight className="size-4" />
          </Button>
          <Button variant="outline" onClick={() => setSelectedDate(fmtDate(new Date()))}>
            Hôm nay
          </Button>
        </div>
      </div>

      {isLoading && <p className="text-sm text-muted-foreground">Đang tải...</p>}

      <div className="grid gap-4 lg:grid-cols-[300px_1fr]">
        <div className="space-y-3 rounded-xl border border-border bg-card p-4">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold uppercase text-amber-400">⚡ Chờ xác nhận</span>
            <span className="rounded-full bg-amber-900/50 px-2 py-0.5 text-xs text-amber-300">
              {pending.length}
            </span>
          </div>

          {pending.length === 0 && (
            <p className="py-3 text-center text-xs text-muted-foreground">Không có booking chờ xác nhận</p>
          )}

          {pending.map((booking) => (
            <div key={booking.id} className="space-y-1.5 rounded-lg border-l-2 border-amber-500 bg-muted/30 p-3">
              <div className="flex items-start justify-between">
                <p className="text-sm font-semibold">{booking.userName}</p>
                <p className="text-xs font-medium text-[#0d7c5f]">
                  {booking.totalAmount.toLocaleString('vi-VN')}đ
                </p>
              </div>
              <p className="text-xs text-muted-foreground">
                {booking.courtName} · {booking.startTime.slice(0, 5)}–{booking.endTime.slice(0, 5)}
              </p>
              <p className="text-xs text-muted-foreground">
                {booking.products.length > 0 ? `+${booking.products.length} sản phẩm` : 'Không có sản phẩm'}
              </p>
              <div className="flex gap-2 pt-1">
                <button
                  type="button"
                  disabled={confirm.isPending}
                  onClick={() => confirm.mutate(booking.id, { onSuccess: () => toast.success('Đã xác nhận') })}
                  className="flex-1 rounded bg-[#0d7c5f] py-1.5 text-xs text-white disabled:opacity-50"
                >
                  ✓ Xác nhận
                </button>
                <button
                  type="button"
                  disabled={cancel.isPending}
                  onClick={() => {
                    if (window.confirm('Từ chối booking này?')) {
                      cancel.mutate({ id: booking.id }, { onSuccess: () => toast.success('Đã từ chối') })
                    }
                  }}
                  className="flex-1 rounded bg-red-900/60 py-1.5 text-xs text-red-300 disabled:opacity-50"
                >
                  ✕ Từ chối
                </button>
              </div>
            </div>
          ))}

          {confirmed.length > 0 && (
            <>
              <p className="pt-1 text-xs font-semibold uppercase text-blue-400">
                Đã xác nhận · {confirmed.length}
              </p>
              {confirmed.map((booking) => (
                <div key={booking.id} className="space-y-1.5 rounded-lg border-l-2 border-blue-500 bg-muted/30 p-3">
                  <p className="text-sm font-semibold">{booking.userName}</p>
                  <p className="text-xs text-muted-foreground">
                    {booking.courtName} · {booking.startTime.slice(0, 5)}–{booking.endTime.slice(0, 5)}
                  </p>
                  <button
                    type="button"
                    disabled={complete.isPending}
                    onClick={() => complete.mutate(booking.id, { onSuccess: () => toast.success('Hoàn thành') })}
                    className="w-full rounded bg-muted py-1.5 text-xs text-muted-foreground hover:bg-accent disabled:opacity-50"
                  >
                    ✓ Hoàn thành
                  </button>
                </div>
              ))}
            </>
          )}
        </div>

        <div className="rounded-xl border border-border bg-card p-4">
          <p className="mb-3 text-sm font-semibold">Timeline sân — {fmtDateLabel(selectedDate)}</p>
          {(courts ?? []).length === 0 ? (
            <p className="py-8 text-center text-sm text-muted-foreground">Chưa có sân nào</p>
          ) : (
            <div className="flex gap-2" style={{ height: 360 }}>
              <div className="flex w-10 flex-col justify-between pb-1 pt-4 text-[9px] text-muted-foreground">
                {Array.from({ length: 9 }, (_, index) => {
                  const openHour = Math.floor(toMinutes(openTime) / 60)
                  const closeHour = Math.ceil(toMinutes(closeTime) / 60)
                  const hour = openHour + Math.round((index * (closeHour - openHour)) / 8)
                  return <span key={index}>{String(hour).padStart(2, '0')}:00</span>
                })}
              </div>
              {(courts ?? []).map((court) => {
                const courtBookings = dayBookings.filter(
                  (booking) => booking.courtName === court.name && booking.status !== 'CANCELLED',
                )
                return (
                  <div key={court.id} className="relative flex-1 rounded bg-muted/20">
                    <p className="border-b border-border py-1 text-center text-[9px] text-muted-foreground">
                      {court.name}
                    </p>
                    {courtBookings.map((booking) => {
                      const top = toPercent(booking.startTime, openTime, closeTime)
                      const height = toPercent(booking.endTime, openTime, closeTime) - top
                      return (
                        <div
                          key={booking.id}
                          title={`${booking.userName}\n${booking.startTime.slice(0, 5)}–${booking.endTime.slice(0, 5)}\n${booking.status}`}
                          className={cn(
                            'absolute left-1 right-1 flex items-center overflow-hidden rounded border px-1 text-[7px]',
                            STATUS_BLOCK[booking.status] ?? 'border-border bg-muted',
                          )}
                          style={{ top: `${16 + top * 0.83}%`, height: `${Math.max(height * 0.83, 5)}%` }}
                        >
                          <span className="truncate">{booking.userName}</span>
                        </div>
                      )
                    })}
                  </div>
                )
              })}
            </div>
          )}
          <div className="mt-2 flex gap-4">
            {[
              ['Chờ duyệt', 'bg-amber-900/30 border-amber-500'],
              ['Xác nhận', 'bg-blue-900/30 border-blue-500'],
              ['Hoàn thành', 'bg-green-900/30 border-green-500'],
            ].map(([label, classes]) => (
              <div key={label} className="flex items-center gap-1.5">
                <span className={cn('h-2.5 w-2.5 rounded-sm border', classes)} />
                <span className="text-[9px] text-muted-foreground">{label}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
