import {
  Building2,
  CalendarDays,
  Clock,
  Dumbbell,
  Image,
  Layers,
  LayoutDashboard,
  Package,
  Receipt,
  Star,
} from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { queryClient } from '@/lib/query-client'
import { useAuthStore } from '@/store/auth'
import { type NavGroup, PortalLayout } from './portal-layout'

const venueNavGroups: NavGroup[] = [
  {
    key: 'overview',
    label: 'Tổng quan',
    items: [{ icon: LayoutDashboard, label: 'Dashboard', to: '/venue' }],
  },
  {
    key: 'facility',
    label: 'Cơ sở',
    items: [
      { icon: Building2, label: 'Thông tin venue', to: '/venue/profile' },
      { icon: Layers, label: 'Quản lý sân', to: '/venue/courts' },
      { icon: Clock, label: 'Giờ hoạt động', to: '/venue/hours' },
      { icon: Package, label: 'Sản phẩm', to: '/venue/products' },
      { icon: Image, label: 'Media', to: '/venue/media' },
    ],
  },
  {
    key: 'operations',
    label: 'Vận hành',
    items: [
      { icon: CalendarDays, label: 'Bookings', to: '/venue/bookings' },
      { icon: Star, label: 'Đánh giá', to: '/venue/reviews' },
      { icon: Receipt, label: 'Hóa đơn', to: '/venue/invoices' },
    ],
  },
]

export function VenueLayout() {
  const { roles, setActiveRole } = useAuthStore()
  const navigate = useNavigate()
  const hasAdminRole = roles.includes('ROLE_ADMIN')

  const handleSwitch = () => {
    queryClient.clear()
    setActiveRole('ROLE_ADMIN')
    navigate('/admin')
  }

  return (
    <PortalLayout
      navGroups={venueNavGroups}
      accentColor="#0d7c5f"
      roleLabel="VENUE MGR"
      roleIcon={Dumbbell}
      otherRole={hasAdminRole ? 'ADMIN' : undefined}
      onSwitchRole={hasAdminRole ? handleSwitch : undefined}
    />
  )
}
