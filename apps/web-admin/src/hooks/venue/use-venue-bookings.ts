import { useMutation, useQuery } from '@tanstack/react-query'
import { api } from '@/lib/axios'
import { queryClient } from '@/lib/query-client'
import type { ApiResponse, BookingResponse, PageResponse } from '@/types/api'

function normalizePage<T>(page: PageResponse<T>): PageResponse<T> {
  return {
    ...page,
    content: page.content ?? page.items,
    totalElements: page.totalElements ?? page.total,
    currentPage: page.currentPage ?? page.page,
  }
}

export function useVenueBookings(venueId: string) {
  return useQuery({
    queryKey: ['venue', 'bookings', venueId],
    queryFn: () =>
      api
        .get<ApiResponse<PageResponse<BookingResponse>>>(`/bookings/venue/${venueId}?page=1&size=100`)
        .then((response) => normalizePage(response.data.data)),
    enabled: !!venueId,
    staleTime: 30_000,
  })
}

export function useConfirmBooking(venueId: string) {
  return useMutation({
    mutationFn: (id: string) => api.put(`/bookings/${id}/confirm`),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['venue', 'bookings', venueId] }),
  })
}

export function useCancelBooking(venueId: string) {
  return useMutation({
    mutationFn: ({ id, reason }: { id: string; reason?: string }) =>
      api.put(`/bookings/${id}/cancel${reason ? `?reason=${encodeURIComponent(reason)}` : ''}`),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['venue', 'bookings', venueId] }),
  })
}

export function useCompleteBooking(venueId: string) {
  return useMutation({
    mutationFn: (id: string) => api.put(`/bookings/${id}/complete`),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['venue', 'bookings', venueId] }),
  })
}
