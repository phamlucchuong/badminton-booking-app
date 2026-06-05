import { useMutation, useQuery } from '@tanstack/react-query'
import { api } from '@/lib/axios'
import { queryClient } from '@/lib/query-client'
import type {
  AdminUserCreateRequest,
  AdminUserResponse,
  ApiResponse,
  PageResponse,
} from '@/types/api'

function normalizePage<T>(page: PageResponse<T>): PageResponse<T> {
  return {
    ...page,
    content: page.content ?? page.items,
    totalElements: page.totalElements ?? page.total,
    currentPage: page.currentPage ?? page.page,
  }
}

export function useAdminUsers(page: number) {
  return useQuery({
    queryKey: ['admin', 'users', page],
    queryFn: () =>
      api
        .get<ApiResponse<PageResponse<AdminUserResponse>>>(`/admin/users?page=${page}`)
        .then((response) => normalizePage(response.data.data)),
  })
}

export function useCreateAdminUser() {
  return useMutation({
    mutationFn: (request: AdminUserCreateRequest) =>
      api
        .post<ApiResponse<AdminUserResponse>>('/admin/users', request)
        .then((response) => response.data.data),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ['admin', 'users'] })
    },
  })
}

export function useDeleteAdminUser() {
  return useMutation({
    mutationFn: (id: string) => api.delete(`/admin/users/${id}`),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ['admin', 'users'] })
    },
  })
}
