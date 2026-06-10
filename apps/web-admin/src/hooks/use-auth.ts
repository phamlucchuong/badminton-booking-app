import { useAuthStore } from '@/store/auth'

function decodeBase64Url(value: string) {
  const normalized = value.replace(/-/g, '+').replace(/_/g, '/')
  const padded = normalized.padEnd(Math.ceil(normalized.length / 4) * 4, '=')
  return atob(padded)
}

export const getRolesFromToken = (token: string): string[] => {
  try {
    const payload = JSON.parse(decodeBase64Url(token.split('.')[1])) as {
      scope?: string
    }

    return (payload.scope ?? '')
      .split(' ')
      .filter(Boolean)
      .map((role) => (role.startsWith('ROLE_') ? role : `ROLE_${role}`))
  } catch {
    return []
  }
}

export function useAuth() {
  const { token, roles, activeRole } = useAuthStore()

  return {
    isLoggedIn: !!token,
    isAdmin: roles.includes('ROLE_ADMIN'),
    isVenueManager: roles.includes('ROLE_VENUE_MANAGER'),
    isDualRole: roles.length > 1,
    activeRole,
  }
}
