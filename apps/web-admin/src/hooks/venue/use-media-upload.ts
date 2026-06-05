import { useMutation } from '@tanstack/react-query'
import { api } from '@/lib/axios'
import type { ApiResponse } from '@/types/api'

export function useMediaUpload() {
  return useMutation({
    mutationFn: ({ file, folder }: { file: File; folder: string }) => {
      const form = new FormData()
      form.append('file', file)
      form.append('folder', folder)
      return api
        .post<ApiResponse<string>>('/media', form, {
          headers: { 'Content-Type': 'multipart/form-data' },
        })
        .then((response) => response.data.data)
    },
  })
}
