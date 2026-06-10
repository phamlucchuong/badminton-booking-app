import { useMutation } from '@tanstack/react-query'
import { api } from '@/lib/axios'
import { queryClient } from '@/lib/query-client'
import type {
  ApiResponse,
  VenueCreateRequest,
  VenueResponse,
  VenueUpdateRequest,
} from '@/types/api'

export function useUpdateVenue(venueId: string) {
  return useMutation({
    mutationFn: (request: VenueUpdateRequest) =>
      api
        .put<ApiResponse<VenueResponse>>(`/venues/${venueId}`, request)
        .then((response) => response.data.data),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['venue', 'my'] }),
  })
}

export function useCreateVenueProfile() {
  return useMutation({
    mutationFn: (request: VenueCreateRequest) =>
      api
        .post<ApiResponse<VenueResponse>>('/venues', request)
        .then((response) => response.data.data),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['venue', 'my'] }),
  })
}
