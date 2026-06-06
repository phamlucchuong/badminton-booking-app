import { useMutation, useQuery } from '@tanstack/react-query'
import { api } from '@/lib/axios'
import { queryClient } from '@/lib/query-client'
import type { ApiResponse, CourtCreateRequest, CourtResponse } from '@/types/api'

export function useCourts(venueId: string) {
  return useQuery({
    queryKey: ['venue', 'courts', venueId],
    queryFn: () =>
      api
        .get<ApiResponse<CourtResponse[]>>(`/venues/${venueId}/courts`)
        .then((response) => response.data.data),
    enabled: !!venueId,
  })
}

export function useCreateCourt(venueId: string) {
  return useMutation({
    mutationFn: (request: CourtCreateRequest) =>
      api
        .post<ApiResponse<CourtResponse>>(`/venues/${venueId}/courts`, request)
        .then((response) => response.data.data),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['venue', 'courts', venueId] }),
  })
}

export function useSetCourtStatus(venueId: string) {
  return useMutation({
    mutationFn: ({ courtId, status }: { courtId: string; status: string }) =>
      api
        .put<ApiResponse<CourtResponse>>(
          `/venues/${venueId}/courts/${courtId}/status?status=${status}`,
        )
        .then((response) => response.data.data),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['venue', 'courts', venueId] }),
  })
}

export function useUpdateCourt(venueId: string) {
  return useMutation({
    mutationFn: ({ courtId, request }: { courtId: string; request: CourtCreateRequest }) =>
      api
        .put<ApiResponse<CourtResponse>>(`/venues/${venueId}/courts/${courtId}`, request)
        .then((response) => response.data.data),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['venue', 'courts', venueId] }),
  })
}
