import { useMutation, useQuery } from '@tanstack/react-query'
import { api } from '@/lib/axios'
import { queryClient } from '@/lib/query-client'
import type { ApiResponse, PageResponse, VenueResponse } from '@/types/api'

const KEYS = {
  pending: ['admin', 'venues', 'pending'] as const,
  all: ['admin', 'venues', 'all'] as const,
}

function normalizePage<T>(page: PageResponse<T>): PageResponse<T> {
  return {
    ...page,
    content: page.content ?? page.items,
    totalElements: page.totalElements ?? page.total,
    currentPage: page.currentPage ?? page.page,
  }
}

export function useAdminVenuesPending() {
  return useQuery({
    queryKey: KEYS.pending,
    queryFn: () =>
      api
        .get<ApiResponse<PageResponse<VenueResponse>>>('/venues/pending?page=1&size=50')
        .then((response) => normalizePage(response.data.data)),
  })
}

export function useAdminVenuesAll(page: number = 1, size: number = 10) {
  return useQuery({
    queryKey: [...KEYS.all, page, size] as const,
    queryFn: () =>
      api
        .get<ApiResponse<PageResponse<VenueResponse>>>(`/venues?page=${page}&size=${size}`)
        .then((response) => normalizePage(response.data.data)),
  })
}

function invalidateVenues() {
  void queryClient.invalidateQueries({ queryKey: KEYS.pending })
  void queryClient.invalidateQueries({ queryKey: KEYS.all })
}

export function useApproveVenue() {
  return useMutation({
    mutationFn: (id: string) =>
      api
        .put<ApiResponse<VenueResponse>>(`/venues/${id}/approve`)
        .then((response) => response.data.data),
    onSuccess: invalidateVenues,
  })
}

export function useRejectVenue() {
  return useMutation({
    mutationFn: (id: string) =>
      api
        .put<ApiResponse<VenueResponse>>(`/venues/${id}/reject`)
        .then((response) => response.data.data),
    onSuccess: invalidateVenues,
  })
}

export function useSuspendVenue() {
  return useMutation({
    mutationFn: (id: string) =>
      api
        .put<ApiResponse<VenueResponse>>(`/venues/${id}/suspend`)
        .then((response) => response.data.data),
    onSuccess: invalidateVenues,
  })
}
