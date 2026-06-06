import { useQuery } from '@tanstack/react-query'
import { api } from '@/lib/axios'
import type { ApiResponse, SystemStatsResponse } from '@/types/api'

export function useAdminStats() {
  return useQuery({
    queryKey: ['admin', 'stats'],
    queryFn: () =>
      api
        .get<ApiResponse<SystemStatsResponse>>('/admin/stats')
        .then((response) => response.data.data),
    staleTime: 60_000,
    retry: false,
  })
}
