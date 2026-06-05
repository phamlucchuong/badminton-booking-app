import type { ReactNode } from 'react'
import { Navigate } from 'react-router-dom'
import { useAuthStore } from '@/store/auth'

export function VenueGuard({ children }: { children: ReactNode }) {
  const { token, roles } = useAuthStore()

  if (!token) return <Navigate to="/login" replace />
  if (roles.includes('ROLE_VENUE_MANAGER')) return <>{children}</>
  if (roles.includes('ROLE_ADMIN')) return <Navigate to="/admin" replace />

  return <Navigate to="/login" replace />
}
