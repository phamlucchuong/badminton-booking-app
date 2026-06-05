export interface ApiResponse<T> {
  code: number
  message: string | null
  data: T
}

export interface PageResponse<T> {
  content: T[]
  totalElements: number
  totalPages: number
  currentPage: number
  pageSize: number
}
