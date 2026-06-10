import { CheckSquare, LayoutDashboard, Receipt, Star, Users, Zap } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { queryClient } from '@/lib/query-client'
import { useAuthStore } from '@/store/auth'
import { type NavGroup, PortalLayout } from './portal-layout'

const adminNavGroups: NavGroup[] = [
  {
    key: 'overview',
    label: 'Tổng quan',
    items: [{ icon: LayoutDashboard, label: 'Dashboard', to: '/admin' }],
  },
  {
    key: 'manage',
    label: 'Quản lý',
    items: [
      { icon: CheckSquare, label: 'Duyệt venue', to: '/admin/venues' },
      { icon: Users, label: 'Users', to: '/admin/users' },
      { icon: Receipt, label: 'Invoices', to: '/admin/invoices' },
      { icon: Star, label: 'Reviews', to: '/admin/reviews' },
    ],
  },
]

export function AdminLayout() {
  const { roles, setActiveRole } = useAuthStore()
  const navigate = useNavigate()
  const hasVenueRole = roles.includes('ROLE_VENUE_MANAGER')

  const handleSwitch = () => {
    queryClient.clear()
    setActiveRole('ROLE_VENUE_MANAGER')
    navigate('/venue')
  }

  return (
    <PortalLayout
      navGroups={adminNavGroups}
      accentColor="#132D77"
      roleLabel="ADMIN"
      roleIcon={Zap}
      otherRole={hasVenueRole ? 'VENUE MGR' : undefined}
      onSwitchRole={hasVenueRole ? handleSwitch : undefined}
    />
  )
}
