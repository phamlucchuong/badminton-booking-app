import { create } from 'zustand'
import { persist } from 'zustand/middleware'

interface AuthUser {
  id: string
  name: string
  email: string
}

interface AuthState {
  token: string | null
  refreshToken: string | null
  user: AuthUser | null
  roles: string[]
  activeRole: string | null
  setAuth: (payload: {
    token: string
    refreshToken: string
    user: AuthUser
    roles: string[]
  }) => void
  setActiveRole: (role: string) => void
  clearAuth: () => void
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      token: null,
      refreshToken: null,
      user: null,
      roles: [],
      activeRole: null,
      setAuth: ({ token, refreshToken, user, roles }) =>
        set({
          token,
          refreshToken,
          user,
          roles,
          activeRole: roles.length === 1 ? roles[0] : null,
        }),
      setActiveRole: (role) => set({ activeRole: role }),
      clearAuth: () =>
        set({
          token: null,
          refreshToken: null,
          user: null,
          roles: [],
          activeRole: null,
        }),
    }),
    {
      name: 'badminton-portal-auth',
    },
  ),
)
