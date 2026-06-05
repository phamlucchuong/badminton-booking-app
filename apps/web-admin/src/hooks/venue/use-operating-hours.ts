import { useMutation, useQuery } from '@tanstack/react-query'
import { api } from '@/lib/axios'
import { queryClient } from '@/lib/query-client'
import type {
  ApiResponse,
  VenueOperatingHourRequest,
  VenueOperatingHourResponse,
} from '@/types/api'

export function useOperatingHours(venueId: string) {
  return useQuery({
    queryKey: ['venue', 'hours', venueId],
    queryFn: () =>
      api
        .get<ApiResponse<VenueOperatingHourResponse[]>>(`/venues/${venueId}/operating-hours`)
        .then((response) => response.data.data),
    enabled: !!venueId,
  })
}

export function useUpdateOperatingHours(venueId: string) {
  return useMutation({
    mutationFn: (hours: VenueOperatingHourRequest[]) =>
      api
        .put<ApiResponse<VenueOperatingHourResponse[]>>(`/venues/${venueId}/operating-hours`, hours)
        .then((response) => response.data.data),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['venue', 'hours', venueId] }),
  })
}
