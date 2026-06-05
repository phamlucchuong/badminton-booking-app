import { useState } from 'react'
import { toast } from 'sonner'
import { useMyVenue } from '@/hooks/venue/use-my-venue'
import { useReplyReview, useVenueReviews } from '@/hooks/venue/use-venue-reviews'
import type { ReviewResponse } from '@/types/api'

function StarRating({ rating }: { rating: number }) {
  return <span className="text-amber-400">{'★'.repeat(rating)}{'☆'.repeat(5 - rating)}</span>
}

function ReviewCard({ review, venueId }: { review: ReviewResponse; venueId: string }) {
  const [text, setText] = useState('')
  const [editing, setEditing] = useState(false)
  const reply = useReplyReview(venueId)

  const handleReply = async () => {
    if (!text.trim()) return
    await reply.mutateAsync({ id: review.id, replyText: text.trim() })
    toast.success('Đã gửi phản hồi')
    setText('')
    setEditing(false)
  }

  return (
    <div className="space-y-3 rounded-xl border border-border bg-card p-4">
      <div className="flex items-start justify-between">
        <div>
          <p className="font-semibold">{review.user.name}</p>
          <p className="text-xs text-muted-foreground">{new Date(review.createdAt).toLocaleDateString('vi-VN')}</p>
        </div>
        <StarRating rating={review.rating} />
      </div>
      <p className="text-sm text-foreground">{review.content}</p>

      {review.replyText ? (
        <div className="rounded-r-md border-l-2 border-[#0d7c5f] bg-[#0d7c5f]/10 px-3 py-2">
          <p className="text-xs font-semibold text-[#0d7c5f]">Phản hồi của sân</p>
          <p className="mt-0.5 text-sm">{review.replyText}</p>
        </div>
      ) : (
        <div className="space-y-2">
          {!editing ? (
            <button type="button" onClick={() => setEditing(true)} className="text-xs text-[#0d7c5f] hover:underline">
              + Phản hồi đánh giá này
            </button>
          ) : (
            <div className="flex gap-2">
              <input
                type="text"
                value={text}
                onChange={(event) => setText(event.target.value)}
                onKeyDown={(event) => event.key === 'Enter' && void handleReply()}
                placeholder="Nhập phản hồi..."
                className="flex-1 rounded-md border border-input bg-background px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-ring"
              />
              <button
                type="button"
                disabled={reply.isPending || !text.trim()}
                onClick={() => void handleReply()}
                className="rounded-md bg-[#0d7c5f] px-3 py-1.5 text-xs text-white disabled:opacity-50"
              >
                Gửi
              </button>
              <button type="button" onClick={() => setEditing(false)} className="rounded-md border border-border px-3 py-1.5 text-xs">
                Hủy
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  )
}

export function VenueReviewsPage() {
  const { data: venue } = useMyVenue()
  const venueId = venue?.id ?? ''
  const { data: reviewsPage, isLoading } = useVenueReviews(venueId)

  const reviews = reviewsPage?.items ?? []
  const avg = reviews.length
    ? (reviews.reduce((sum, review) => sum + review.rating, 0) / reviews.length).toFixed(1)
    : '—'

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Đánh giá</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            {reviews.length} đánh giá · TB <span className="font-semibold text-amber-400">{avg} ★</span>
          </p>
        </div>
      </div>

      {isLoading && <p className="text-sm text-muted-foreground">Đang tải...</p>}

      {reviews.length === 0 && !isLoading && (
        <p className="py-12 text-center text-sm text-muted-foreground">Chưa có đánh giá nào</p>
      )}

      <div className="space-y-4">
        {reviews.map((review) => (
          <ReviewCard key={review.id} review={review} venueId={venueId} />
        ))}
      </div>
    </div>
  )
}
