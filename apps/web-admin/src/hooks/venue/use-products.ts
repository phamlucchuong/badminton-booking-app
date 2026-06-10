import { useMutation, useQuery } from '@tanstack/react-query'
import { api } from '@/lib/axios'
import { queryClient } from '@/lib/query-client'
import type { ApiResponse, ProductCreateRequest, ProductResponse } from '@/types/api'

export function useProducts(venueId: string) {
  return useQuery({
    queryKey: ['venue', 'products', venueId],
    queryFn: () =>
      api
        .get<ApiResponse<ProductResponse[]>>(`/venues/${venueId}/products`)
        .then((response) => response.data.data),
    enabled: !!venueId,
  })
}

export function useCreateProduct(venueId: string) {
  return useMutation({
    mutationFn: (request: ProductCreateRequest) =>
      api
        .post<ApiResponse<ProductResponse>>(`/venues/${venueId}/products`, request)
        .then((response) => response.data.data),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['venue', 'products', venueId] }),
  })
}
