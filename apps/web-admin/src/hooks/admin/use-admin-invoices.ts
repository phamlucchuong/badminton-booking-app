import { useMutation, useQuery } from '@tanstack/react-query'
import { api } from '@/lib/axios'
import { queryClient } from '@/lib/query-client'
import type { ApiResponse, PlatformFeeInvoice } from '@/types/api'

const QUERY_KEY = ['admin', 'invoices', 'pending'] as const

export function useAdminInvoices() {
  return useQuery({
    queryKey: QUERY_KEY,
    queryFn: () =>
      api
        .get<ApiResponse<PlatformFeeInvoice[]>>('/admin/invoices/pending')
        .then((response) => response.data.data),
  })
}

export function useGenerateInvoice() {
  return useMutation({
    mutationFn: ({ venueId, period }: { venueId: string; period: string }) =>
      api
        .post<ApiResponse<PlatformFeeInvoice>>(
          `/admin/invoices/generate?venueId=${venueId}&period=${encodeURIComponent(period)}`,
        )
        .then((response) => response.data.data),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: QUERY_KEY })
    },
  })
}

export function useMarkInvoicePaid() {
  return useMutation({
    mutationFn: (id: string) =>
      api
        .put<ApiResponse<PlatformFeeInvoice>>(`/admin/invoices/${id}/paid`)
        .then((response) => response.data.data),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: QUERY_KEY })
    },
  })
}
