import { Dumbbell, Lock, Mail } from 'lucide-react'
import { useState } from 'react'
import { Navigate, useNavigate } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { getRolesFromToken } from '@/hooks/use-auth'
import { api } from '@/lib/axios'
import { useCopy } from '@/lib/copy'
import { useAuthStore } from '@/store/auth'
import type { ApiResponse } from '@/types/api'

interface LoginResponse {
  token: string
  refreshToken: string
  authenticated: boolean
}

export function LoginPage() {
  const copy = useCopy()
  const navigate = useNavigate()
  const { token, activeRole, setAuth } = useAuthStore()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  if (token) {
    if (activeRole === 'ROLE_ADMIN') return <Navigate to="/admin" replace />
    if (activeRole === 'ROLE_VENUE_MANAGER') {
      return <Navigate to="/venue" replace />
    }

    return <Navigate to="/select-role" replace />
  }

  const handleLogin = async () => {
    setLoading(true)
    setError(null)

    try {
      const res = await api.post<ApiResponse<LoginResponse>>('/auth', {
        email,
        password,
      })
      const { token: accessToken, refreshToken } = res.data.data
      const roles = getRolesFromToken(accessToken)

      setAuth({
        token: accessToken,
        refreshToken,
        user: { id: '', name: email.split('@')[0] ?? email, email },
        roles,
      })

      if (roles.length === 1) {
        navigate(roles[0] === 'ROLE_ADMIN' ? '/admin' : '/venue', {
          replace: true,
        })
      } else {
        navigate('/select-role', { replace: true })
      }
    } catch (err: unknown) {
      const msg =
        (err as { response?: { data?: { message?: string } } })?.response?.data?.message ??
        copy.loginError
      setError(msg)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="grid min-h-screen bg-background lg:grid-cols-2">
      <div className="px-6 py-10 lg:px-16">
        <div className="flex items-center gap-2">
          <div className="flex size-9 items-center justify-center rounded-lg bg-primary text-primary-foreground">
            <Dumbbell className="size-4" />
          </div>
          <span className="text-lg font-bold">{copy.brand}</span>
        </div>

        <div className="mx-auto mt-20 max-w-md space-y-4">
          <h1 className="text-3xl font-bold">{copy.signInTitle}</h1>

          {error && (
            <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-600 dark:border-red-900 dark:bg-red-950 dark:text-red-400">
              {error}
            </div>
          )}

          <div>
            <label className="text-sm font-medium">{copy.email}</label>
            <div className="relative mt-1.5">
              <Mail className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
              <input
                type="email"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                className="h-11 w-full rounded-md border border-input bg-background pl-9 pr-3 text-sm"
                placeholder="admin@gmail.com"
              />
            </div>
          </div>

          <div>
            <label className="text-sm font-medium">{copy.password}</label>
            <div className="relative mt-1.5">
              <Lock className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
              <input
                type="password"
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                onKeyDown={(event) => event.key === 'Enter' && void handleLogin()}
                className="h-11 w-full rounded-md border border-input bg-background pl-9 pr-3 text-sm"
                placeholder="••••••••"
              />
            </div>
          </div>

          <Button
            className="h-11 w-full"
            onClick={() => void handleLogin()}
            disabled={loading || !email || !password}
          >
            {loading ? copy.loading : copy.login}
          </Button>
        </div>
      </div>

      <div className="hidden items-center justify-center bg-[radial-gradient(circle_at_top,_rgba(255,255,255,0.16),_transparent_35%),linear-gradient(135deg,_#0f2e7a,_#1f5fd6_55%,_#13a4c9)] p-12 text-white lg:flex">
        <div className="max-w-md">
          <h2 className="text-3xl font-bold">{copy.signInVisualTitle}</h2>
          <p className="mt-2 opacity-90">{copy.signInVisualDesc}</p>
        </div>
      </div>
    </div>
  )
}
