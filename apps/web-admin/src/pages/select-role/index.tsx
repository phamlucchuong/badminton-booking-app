import { Dumbbell, Zap } from 'lucide-react'
import { Navigate, useNavigate } from 'react-router-dom'
import { useCopy } from '@/lib/copy'
import { queryClient } from '@/lib/query-client'
import { useAuthStore } from '@/store/auth'

export function RoleSelectPage() {
  const { token, roles, setActiveRole } = useAuthStore()
  const navigate = useNavigate()
  const copy = useCopy()

  if (!token) return <Navigate to="/login" replace />
  if (roles.length === 1) {
    return <Navigate to={roles[0] === 'ROLE_ADMIN' ? '/admin' : '/venue'} replace />
  }

  const select = (role: string) => {
    queryClient.clear()
    setActiveRole(role)
    navigate(role === 'ROLE_ADMIN' ? '/admin' : '/venue', { replace: true })
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-background p-4">
      <div className="w-full max-w-md space-y-6">
        <div className="text-center">
          <h1 className="text-2xl font-bold">{copy.selectRoleTitle}</h1>
          <p className="mt-1 text-sm text-muted-foreground">{copy.selectRoleDesc}</p>
        </div>

        <div className="grid gap-4">
          <button
            type="button"
            onClick={() => select('ROLE_ADMIN')}
            className="flex items-center gap-4 rounded-xl border-2 border-transparent bg-card p-6 text-left shadow-sm transition-all hover:border-[#132D77] hover:shadow-md"
          >
            <div className="flex size-12 shrink-0 items-center justify-center rounded-xl bg-[#132D77] text-white">
              <Zap className="size-6" />
            </div>
            <div>
              <div className="text-base font-semibold">{copy.adminPortal}</div>
              <div className="mt-0.5 text-sm text-muted-foreground">{copy.adminPortalDesc}</div>
            </div>
          </button>

          <button
            type="button"
            onClick={() => select('ROLE_VENUE_MANAGER')}
            className="flex items-center gap-4 rounded-xl border-2 border-transparent bg-card p-6 text-left shadow-sm transition-all hover:border-[#0d7c5f] hover:shadow-md"
          >
            <div className="flex size-12 shrink-0 items-center justify-center rounded-xl bg-[#0d7c5f] text-white">
              <Dumbbell className="size-6" />
            </div>
            <div>
              <div className="text-base font-semibold">{copy.venuePortal}</div>
              <div className="mt-0.5 text-sm text-muted-foreground">{copy.venuePortalDesc}</div>
            </div>
          </button>
        </div>
      </div>
    </div>
  )
}
