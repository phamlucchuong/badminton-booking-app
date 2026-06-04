import { Lock, Mail, Sparkles } from 'lucide-react'
import { Link, Navigate, useNavigate } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { useCopy } from '@/lib/copy'
import { useAuthStore } from '@/store/auth'

export function SignInPage() {
  const copy = useCopy()
  const navigate = useNavigate()
  const token = useAuthStore((state) => state.token)
  const setAuth = useAuthStore((state) => state.setAuth)

  if (token) {
    return <Navigate to="/admin" replace />
  }

  return (
    <div className="grid min-h-screen bg-background lg:grid-cols-2">
      <div className="px-6 py-10 lg:px-16">
        <Link to="/" className="flex items-center gap-2">
          <div className="flex size-9 items-center justify-center rounded-lg bg-primary text-primary-foreground">
            <Sparkles className="size-4" />
          </div>
          <span className="text-lg font-bold">{copy.brand}</span>
        </Link>

        <div className="mx-auto mt-20 max-w-md space-y-4">
          <h1 className="text-3xl font-bold">{copy.signInTitle}</h1>

          <div>
            <label className="text-sm font-medium">{copy.email}</label>
            <div className="relative mt-1.5">
              <Mail className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
              <input
                className="h-11 w-full rounded-md border border-input bg-background pl-9 pr-3 text-sm"
                defaultValue="admin@badminton.vn"
              />
            </div>
          </div>

          <div>
            <div className="flex items-center justify-between">
              <label className="text-sm font-medium">{copy.password}</label>
              <a className="text-xs text-primary">{copy.forgotPassword}</a>
            </div>
            <div className="relative mt-1.5">
              <Lock className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
              <input
                type="password"
                className="h-11 w-full rounded-md border border-input bg-background pl-9 pr-3 text-sm"
                defaultValue="admin123"
              />
            </div>
          </div>

          <Button
            className="h-11 w-full"
            onClick={() => {
              setAuth({
                token: 'demo-admin-token',
                user: {
                  id: '1',
                  name: 'Admin Badminton',
                  email: 'admin@badminton.vn',
                },
              })
              navigate('/admin')
            }}
          >
            {copy.login}
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
