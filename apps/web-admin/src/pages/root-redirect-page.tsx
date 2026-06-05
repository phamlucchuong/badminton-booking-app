import { Navigate } from 'react-router-dom'
import { useAuthStore } from '@/store/auth'

export function RootRedirectPage() {
  const { token, activeRole } = useAuthStore()

  if (!token) return <Navigate to="/login" replace />
  if (activeRole === 'ROLE_ADMIN') return <Navigate to="/admin" replace />
  if (activeRole === 'ROLE_VENUE_MANAGER') {
    return <Navigate to="/venue" replace />
  }

  return <Navigate to="/select-role" replace />
}
