import { useMutation, useQuery } from '@tanstack/react-query'
import { api } from '@/lib/axios'
import { queryClient } from '@/lib/query-client'
import type { ApiResponse, PageResponse, ReviewResponse } from '@/types/api'

function normalizePage<T>(page: PageResponse<T>): PageResponse<T> {
  return {
    ...page,
    content: page.content ?? page.items,
    totalElements: page.totalElements ?? page.total,
    currentPage: page.currentPage ?? page.page,
  }
}

export function useVenueReviews(venueId: string) {
  return useQuery({
    queryKey: ['venue', 'reviews', venueId],
    queryFn: () =>
      api
        .get<ApiResponse<PageResponse<ReviewResponse>>>(
          `/reviews?targetType=VENUE&targetId=${venueId}&page=1&size=50`,
        )
        .then((response) => normalizePage(response.data.data)),
    enabled: !!venueId,
  })
}

export function useReplyReview(venueId: string) {
  return useMutation({
    mutationFn: ({ id, replyText }: { id: string; replyText: string }) =>
      api.put(`/reviews/${id}/reply?replyText=${encodeURIComponent(replyText)}`),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['venue', 'reviews', venueId] }),
  })
}
