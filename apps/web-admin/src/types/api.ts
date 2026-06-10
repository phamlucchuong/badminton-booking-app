export interface ApiResponse<T> {
  code: number
  message: string | null
  data: T
}

export interface PageResponse<T> {
  items: T[]
  total: number
  page: number
  pageSize: number
  totalPages: number
  content?: T[]
  totalElements?: number
  currentPage?: number
}

export interface VenueResponse {
  id: string
  ownerName: string
  name: string
  address: string
  latitude: number | null
  longitude: number | null
  description: string | null
  licenseId: string | null
  status: 'PENDING' | 'ACTIVE' | 'SUSPENDED' | 'REJECTED'
  openTime: string
  closeTime: string
  platformFeeRate: number
  createdAt: string
}

export interface VenueUpdateRequest {
  name: string
  address: string
  latitude?: number
  longitude?: number
  description?: string
  openTime?: string
  closeTime?: string
  bankName?: string
  bankNumber?: string
  bankAccountName?: string
}

export interface VenueCreateRequest extends VenueUpdateRequest {
  licenseId: string
}

export interface CourtResponse {
  id: string
  venueId: string
  venueName: string
  name: string
  courtType: 'STANDARD' | 'VIP' | 'OUTDOOR'
  pricePerHour: number
  status: 'ACTIVE' | 'MAINTENANCE' | 'INACTIVE'
  description: string | null
}

export interface CourtCreateRequest {
  name: string
  courtType: string
  pricePerHour: number
  description?: string
}

export interface VenueOperatingHourResponse {
  dayOfWeek: string
  openTime: string | null
  closeTime: string | null
  closed: boolean
}

export interface VenueOperatingHourRequest {
  dayOfWeek: string
  openTime: string | null
  closeTime: string | null
  closed: boolean
}

export interface ProductResponse {
  id: string
  venueId: string
  name: string
  description: string | null
  category: string
  price: number
  unit: string
  stock: number
  imageId?: string | null
  active: boolean
}

export interface ProductCreateRequest {
  name: string
  description?: string
  category: string
  price: number
  unit: string
  stock: number
}

export interface BookingProductResponse {
  productName: string
  quantity: number
  unitPrice: number
  totalPrice: number
}

export interface BookingResponse {
  id: string
  userName: string
  courtName: string
  venueName: string
  bookingDate: string
  startTime: string
  endTime: string
  type: string
  status: 'PENDING' | 'CONFIRMED' | 'CANCELLED' | 'COMPLETED' | 'IN_PROGRESS'
  totalAmount: number
  notes: string | null
  cancelReason: string | null
  createdAt: string
  products: BookingProductResponse[]
}

export interface ReviewResponse {
  id: string
  user: { id: string; name: string; email: string }
  rating: number
  content: string
  replyText: string | null
  replyAt: string | null
  createdAt: string
}

export interface PlatformFeeInvoice {
  id: string
  venue: { id: string; name: string }
  period: string
  totalBookings: number
  totalRevenue: number
  feeAmount: number
  status: 'PENDING' | 'PAID'
  dueDate: string
  paidAt: string | null
}

export interface SystemStatsResponse {
  totalUsers: number
  totalVenues: number
  activeVenues: number
  pendingVenues: number
  totalBookings: number
  completedBookings: number
  totalPlatformRevenue: number
  pendingInvoices: number
}

export interface AdminUserResponse {
  id: string
  name: string
  phone: string
  email: string
  createdAt: string
  deleted: boolean
}

export interface AdminUserCreateRequest {
  name: string
  phone: string
  email: string
  password: string
}
