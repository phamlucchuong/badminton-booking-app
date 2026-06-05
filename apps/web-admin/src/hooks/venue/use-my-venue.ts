import { useQuery } from '@tanstack/react-query'
import { api } from '@/lib/axios'
import type { ApiResponse, VenueResponse } from '@/types/api'

export function useMyVenue() {
  return useQuery({
    queryKey: ['venue', 'my'],
    queryFn: () =>
      api.get<ApiResponse<VenueResponse>>('/venues/my').then((response) => response.data.data),
    staleTime: 5 * 60_000,
    retry: false,
  })
}
