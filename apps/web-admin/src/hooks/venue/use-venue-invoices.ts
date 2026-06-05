import { useQuery } from '@tanstack/react-query'
import { api } from '@/lib/axios'
import type { ApiResponse, PlatformFeeInvoice } from '@/types/api'

export function useVenueInvoices() {
  return useQuery({
    queryKey: ['venue', 'invoices'],
    queryFn: () =>
      api
        .get<ApiResponse<PlatformFeeInvoice[]>>('/finance/my-invoices')
        .then((response) => response.data.data),
  })
}
