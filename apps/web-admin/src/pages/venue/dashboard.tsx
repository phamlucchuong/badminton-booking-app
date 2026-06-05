import { toast } from 'sonner'
import { useNavigate } from 'react-router-dom'
import { useCourts } from '@/hooks/venue/use-courts'
import {
  useCancelBooking,
  useCompleteBooking,
  useConfirmBooking,
  useVenueBookings,
} from '@/hooks/venue/use-venue-bookings'
import { useVenueInvoices } from '@/hooks/venue/use-venue-invoices'
import { useMyVenue } from '@/hooks/venue/use-my-venue'
import { useVenueReviews } from '@/hooks/venue/use-venue-reviews'

const statusColor: Record<string, string> = {
  PENDING: 'border-amber-500 bg-amber-900/30',
  CONFIRMED: 'border-blue-500 bg-blue-900/30',
  COMPLETED: 'border-green-500 bg-green-900/30',
  IN_PROGRESS: 'border-green-500 bg-green-900/30',
}

const toMinutes = (time: string) => {
  const [hours, minutes] = time.split(':').map(Number)
  return hours * 60 + minutes
}

const toPercent = (time: string, open: string, close: string) => {
  const openMinutes = toMinutes(open)
  const closeMinutes = toMinutes(close)
  const timeMinutes = toMinutes(time)
  return Math.max(0, Math.min(100, ((timeMinutes - openMinutes) / (closeMinutes - openMinutes)) * 100))
}

const todayStr = () => {
  const date = new Date()
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
}

export function VenueDashboardPage() {
  const navigate = useNavigate()
  const { data: venue, isError: noVenue } = useMyVenue()
  const venueId = venue?.id ?? ''
  const today = todayStr()

  const { data: bookingsPage } = useVenueBookings(venueId)
  const { data: invoices } = useVenueInvoices()
  const { data: reviewsPage } = useVenueReviews(venueId)
  const { data: courts } = useCourts(venueId)

  const confirm = useConfirmBooking(venueId)
  const cancel = useCancelBooking(venueId)
  const complete = useCompleteBooking(venueId)

  if (noVenue) {
    return (
      <div className="flex flex-col items-center justify-center gap-4 py-24">
        <p className="text-muted-foreground">Bạn chưa đăng ký sân.</p>
        <button
          type="button"
          onClick={() => navigate('/venue/profile')}
          className="rounded-lg bg-[#0d7c5f] px-4 py-2 text-sm text-white"
        >
          Đăng ký sân ngay
        </button>
      </div>
    )
  }

  const allBookings = bookingsPage?.items ?? []
  const todayBookings = allBookings.filter((booking) => booking.bookingDate === today)
  const pending = todayBookings.filter((booking) => booking.status === 'PENDING')
  const confirmed = todayBookings.filter((booking) => booking.status === 'CONFIRMED')

  const currentMonth = `${new Date().getFullYear()}-${String(new Date().getMonth() + 1).padStart(2, '0')}`
  const currentInvoice = (invoices ?? []).find((invoice) => invoice.period === currentMonth)
  const unpaidCount = (invoices ?? []).filter((invoice) => invoice.status === 'PENDING').length

  const allReviews = reviewsPage?.items ?? []
  const avgRating = allReviews.length
    ? (allReviews.reduce((sum, review) => sum + review.rating, 0) / allReviews.length).toFixed(1)
    : '—'

  const openTime = venue?.openTime ?? '06:00:00'
  const closeTime = venue?.closeTime ?? '22:00:00'
  const courtList = courts ?? []

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Dashboard</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          {venue?.name} · Hôm nay {today}
        </p>
      </div>

      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        {[
          {
            label: 'Booking hôm nay',
            value: todayBookings.length,
            sub: `${pending.length} chờ xác nhận`,
            warn: false,
          },
          {
            label: 'Doanh thu tháng',
            value: currentInvoice ? `${(currentInvoice.totalRevenue / 1_000_000).toFixed(1)}M` : '—',
            sub: `kỳ ${currentMonth}`,
            warn: false,
          },
          {
            label: 'Đánh giá TB',
            value: `${avgRating} ★`,
            sub: `${allReviews.length} đánh giá`,
            warn: false,
          },
          {
            label: 'Hóa đơn chưa đóng',
            value: unpaidCount,
            sub: unpaidCount > 0 ? 'Kiểm tra invoices' : 'Không có',
            warn: unpaidCount > 0,
          },
        ].map((card) => (
          <div
            key={card.label}
            className={`rounded-xl border bg-card p-4 ${card.warn ? 'border-amber-500/40' : 'border-border'}`}
          >
            <p className="text-xs text-muted-foreground">{card.label}</p>
            <p className={`mt-1 text-2xl font-bold ${card.warn ? 'text-amber-400' : ''}`}>
              {card.value}
            </p>
            <p className={`mt-0.5 text-xs ${card.warn ? 'text-amber-500' : 'text-[#0d7c5f]'}`}>
              {card.sub}
            </p>
          </div>
        ))}
      </div>

      <div className="grid gap-4 lg:grid-cols-[280px_1fr]">
        <div className="space-y-3 rounded-xl border border-border bg-card p-4">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold uppercase text-amber-400">⚡ Chờ xác nhận</span>
            <span className="rounded-full bg-amber-900/50 px-2 py-0.5 text-xs text-amber-300">
              {pending.length}
            </span>
          </div>

          {pending.length === 0 && (
            <p className="py-4 text-center text-xs text-muted-foreground">
              Không có booking chờ xác nhận
            </p>
          )}

          {pending.map((booking) => (
            <div key={booking.id} className="rounded-lg border-l-2 border-amber-500 bg-muted/30 p-3">
              <div className="flex items-start justify-between">
                <span className="text-sm font-semibold">{booking.userName}</span>
                <span className="text-xs text-[#0d7c5f]">
                  {booking.totalAmount.toLocaleString('vi-VN')}đ
                </span>
              </div>
              <p className="mt-0.5 text-xs text-muted-foreground">
                {booking.courtName} · {booking.startTime.slice(0, 5)}–{booking.endTime.slice(0, 5)}
              </p>
              <div className="mt-2 flex gap-2">
                <button
                  type="button"
                  disabled={confirm.isPending}
                  onClick={() =>
                    confirm.mutate(booking.id, { onSuccess: () => toast.success('Đã xác nhận') })
                  }
                  className="flex-1 rounded bg-[#0d7c5f] py-1 text-xs text-white disabled:opacity-50"
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
                  className="flex-1 rounded bg-red-900/60 py-1 text-xs text-red-300 disabled:opacity-50"
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
                <div key={booking.id} className="rounded-lg border-l-2 border-blue-500 bg-muted/30 p-3">
                  <p className="text-sm font-semibold">{booking.userName}</p>
                  <p className="text-xs text-muted-foreground">
                    {booking.courtName} · {booking.startTime.slice(0, 5)}–{booking.endTime.slice(0, 5)}
                  </p>
                  <button
                    type="button"
                    disabled={complete.isPending}
                    onClick={() =>
                      complete.mutate(booking.id, { onSuccess: () => toast.success('Hoàn thành') })
                    }
                    className="mt-2 w-full rounded bg-muted py-1 text-xs text-muted-foreground hover:bg-accent disabled:opacity-50"
                  >
                    ✓ Hoàn thành
                  </button>
                </div>
              ))}
            </>
          )}
        </div>

        <div className="rounded-xl border border-border bg-card p-4">
          <p className="mb-3 text-sm font-semibold">Lịch sân hôm nay</p>
          {courtList.length === 0 ? (
            <p className="py-8 text-center text-sm text-muted-foreground">Chưa có sân nào được tạo</p>
          ) : (
            <div className="flex gap-2" style={{ height: 240 }}>
              <div className="flex w-10 flex-col justify-between pb-1 pt-4">
                {Array.from({ length: 7 }, (_, index) => {
                  const hour =
                    Math.round(toMinutes(openTime) / 60) +
                    Math.round((index * (toMinutes(closeTime) - toMinutes(openTime))) / 6 / 60)
                  return (
                    <span key={index} className="text-[9px] text-muted-foreground">
                      {String(hour).padStart(2, '0')}:00
                    </span>
                  )
                })}
              </div>

              {courtList.map((court) => {
                const courtBookings = todayBookings.filter((booking) => booking.courtName === court.name)
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
                          title={`${booking.userName} · ${booking.startTime.slice(0, 5)}–${booking.endTime.slice(0, 5)}`}
                          className={`absolute left-1 right-1 flex items-center justify-center overflow-hidden rounded border text-[7px] ${statusColor[booking.status] ?? 'border-border'}`}
                          style={{
                            top: `${16 + top * 0.85}%`,
                            height: `${Math.max(height * 0.85, 4)}%`,
                          }}
                        >
                          {booking.userName.slice(0, 6)}
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
              ['Đã xác nhận', 'bg-blue-900/30 border-blue-500'],
              ['Hoàn thành', 'bg-green-900/30 border-green-500'],
            ].map(([label, classes]) => (
              <div key={label} className="flex items-center gap-1.5">
                <span className={`h-2.5 w-2.5 rounded-sm border ${classes}`} />
                <span className="text-[9px] text-muted-foreground">{label}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
