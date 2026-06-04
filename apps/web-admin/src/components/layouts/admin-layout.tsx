import {
  Bell,
  Brain,
  ChevronDown,
  CreditCard,
  FileWarning,
  KeyRound,
  LayoutDashboard,
  Menu,
  Moon,
  Package,
  ScrollText,
  Search,
  Settings,
  ShieldCheck,
  Sparkles,
  Sun,
  Users,
} from 'lucide-react'
import { useMemo, useState, type ReactNode } from 'react'
import {
  Navigate,
  NavLink,
  Outlet,
  useLocation,
  useNavigate,
} from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { useCopy } from '@/lib/copy'
import { cn } from '@/lib/utils'
import { useAuthStore } from '@/store/auth'
import { usePreferencesStore } from '@/store/preferences'

export function AdminLayout() {
  const copy = useCopy()
  const navigate = useNavigate()
  const { pathname } = useLocation()
  const [collapsed, setCollapsed] = useState(false)
  const [openGroups, setOpenGroups] = useState<Record<string, boolean>>({
    overview: true,
    access: true,
    operations: true,
    platform: true,
  })
  const theme = usePreferencesStore((state) => state.theme)
  const language = usePreferencesStore((state) => state.language)
  const toggleTheme = usePreferencesStore((state) => state.toggleTheme)
  const toggleLanguage = usePreferencesStore((state) => state.toggleLanguage)
  const user = useAuthStore((state) => state.user)
  const token = useAuthStore((state) => state.token)
  const clearAuth = useAuthStore((state) => state.clearAuth)

  const navGroups = useMemo(
    () => [
      {
        key: 'overview',
        label: copy.overviewGroup,
        items: [{ to: '/admin', label: copy.navOverview, icon: LayoutDashboard }],
      },
      {
        key: 'access',
        label: copy.accessGroup,
        items: [
          { to: '/admin/users', label: copy.navUsers, icon: Users },
          { to: '/admin/rbac', label: copy.navRbac, icon: KeyRound },
          {
            to: '/admin/employer-verification',
            label: copy.navEmployerVerification,
            icon: ShieldCheck,
          },
        ],
      },
      {
        key: 'operations',
        label: copy.operationsGroup,
        items: [
          {
            to: '/admin/job-moderation',
            label: copy.navJobModeration,
            icon: FileWarning,
          },
          { to: '/admin/packages', label: copy.navPackages, icon: Package },
          { to: '/admin/payments', label: copy.navPayments, icon: CreditCard },
        ],
      },
      {
        key: 'platform',
        label: copy.platformGroup,
        items: [
          { to: '/admin/ai-config', label: copy.navAiConfig, icon: Brain },
          { to: '/admin/settings', label: copy.navSettings, icon: Settings },
          { to: '/admin/audit-logs', label: copy.navAuditLogs, icon: ScrollText },
        ],
      },
    ],
    [copy],
  )

  if (!token) {
    return <Navigate to="/signin" replace />
  }

  return (
    <div className="flex min-h-screen bg-background">
      <aside
        className={cn(
          'sticky top-0 flex h-screen flex-col border-r border-sidebar-border bg-sidebar transition-all',
          collapsed ? 'w-16' : 'w-64',
        )}
      >
        <div className="flex h-16 items-center border-b border-sidebar-border px-4">
          <NavLink to="/admin" className="flex min-w-0 items-center gap-2">
            <div className="flex size-8 items-center justify-center rounded-lg bg-primary text-primary-foreground">
              <Sparkles className="size-4" />
            </div>
            {!collapsed && <span className="font-bold">{copy.brand}</span>}
          </NavLink>
        </div>

        <nav className="flex-1 space-y-2 overflow-y-auto p-2">
          {navGroups.map((group) => {
            const groupHasActive = group.items.some(
              (item) =>
                pathname === item.to ||
                (item.to !== '/admin' && pathname.startsWith(item.to)),
            )

            if (group.items.length === 1) {
              const item = group.items[0]
              return (
                <AdminNavLink
                  key={item.to}
                  to={item.to}
                  icon={<item.icon className="size-4" />}
                  label={item.label}
                  collapsed={collapsed}
                />
              )
            }

            const expanded = collapsed ? false : (openGroups[group.key] ?? groupHasActive)

            return (
              <div key={group.key} className="space-y-1">
                <button
                  type="button"
                  onClick={() =>
                    setOpenGroups((state) => ({
                      ...state,
                      [group.key]: !expanded,
                    }))
                  }
                  className={cn(
                    'flex w-full items-center rounded-lg px-2 py-1.5 text-xs font-semibold uppercase tracking-wide text-muted-foreground hover:bg-sidebar-accent',
                    collapsed && 'justify-center px-0',
                  )}
                >
                  {!collapsed && <span className="truncate">{group.label}</span>}
                  {!collapsed && (
                    <ChevronDown
                      className={cn(
                        'ml-auto size-3.5 transition-transform',
                        expanded && 'rotate-180',
                      )}
                    />
                  )}
                  {collapsed && (
                    <div
                      className={cn(
                        'size-1.5 rounded-full',
                        groupHasActive ? 'bg-primary' : 'bg-muted-foreground/40',
                      )}
                    />
                  )}
                </button>

                {expanded &&
                  group.items.map((item) => (
                    <AdminNavLink
                      key={item.to}
                      to={item.to}
                      icon={<item.icon className="size-4" />}
                      label={item.label}
                      collapsed={collapsed}
                    />
                  ))}
              </div>
            )
          })}
        </nav>

        <button
          type="button"
          onClick={() => setCollapsed((value) => !value)}
          className="m-2 w-[calc(100%-1rem)] rounded-lg border border-border px-3 py-2 text-xs text-muted-foreground hover:bg-accent"
        >
          {collapsed ? <Menu className="mx-auto size-4" /> : copy.collapseSidebar}
        </button>
      </aside>

      <div className="flex min-w-0 flex-1 flex-col">
        <header className="sticky top-0 z-20 flex h-16 items-center gap-3 border-b border-border bg-card px-5">
          <div className="relative max-w-md flex-1">
            <Search className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
            <input
              placeholder={copy.searchPlaceholder}
              className="h-9 w-full rounded-lg border border-input bg-background pl-9 pr-3 text-sm"
            />
          </div>

          <div className="ml-auto flex items-center gap-2">
            <button
              type="button"
              onClick={toggleLanguage}
              className="relative flex h-9 w-[84px] cursor-pointer items-center rounded-lg border border-border bg-muted/60 p-1 text-xs"
              title="Toggle language"
            >
              <span
                className={cn(
                  'absolute top-1 h-7 w-9 rounded-md bg-primary transition-transform duration-200',
                  language === 'EN' ? 'translate-x-0' : 'translate-x-[38px]',
                )}
              />
              <span
                className={cn(
                  'relative z-10 w-9 text-center transition-colors duration-200',
                  language === 'EN'
                    ? 'text-primary-foreground'
                    : 'text-muted-foreground',
                )}
              >
                EN
              </span>
              <span
                className={cn(
                  'relative z-10 w-9 text-center transition-colors duration-200',
                  language === 'VI'
                    ? 'text-primary-foreground'
                    : 'text-muted-foreground',
                )}
              >
                VI
              </span>
            </button>

            <Button
              variant="outline"
              size="icon"
              onClick={toggleTheme}
              className="h-9 w-9 bg-muted/60 text-muted-foreground"
              title="Toggle theme"
            >
              {theme === 'dark' ? (
                <Sun className="h-4 w-4 transition-transform duration-300 hover:rotate-12" />
              ) : (
                <Moon className="h-4 w-4 transition-transform duration-300 hover:-rotate-12" />
              )}
            </Button>

            <button type="button" className="rounded-lg p-2 hover:bg-accent">
              <Bell className="size-5" />
            </button>

            <button
              type="button"
              onClick={() => {
                clearAuth()
                navigate('/signin')
              }}
              className="flex items-center gap-2 rounded-lg px-2 py-1.5 hover:bg-accent"
            >
              <div className="flex size-8 items-center justify-center rounded-full bg-primary/15 text-xs font-bold text-primary">
                {(user?.name ?? 'A').slice(0, 1)}
              </div>
              <div className="hidden text-left md:block">
                <div className="text-sm font-medium">
                  {user?.name ?? 'Admin Badminton'}
                </div>
                <div className="text-xs text-muted-foreground">
                  {copy.accountActions}
                </div>
              </div>
            </button>
          </div>
        </header>

        <main className="mx-auto flex-1 w-full max-w-[1600px] p-6">
          <Outlet />
        </main>
      </div>
    </div>
  )
}

interface AdminNavLinkProps {
  to: string
  icon: ReactNode
  label: string
  collapsed: boolean
}

function AdminNavLink({
  to,
  icon,
  label,
  collapsed,
}: AdminNavLinkProps) {
  return (
    <NavLink
      to={to}
      end={to === '/admin'}
      className={({ isActive }) =>
        cn(
          'flex items-center gap-3 rounded-lg border border-transparent px-3 py-2 text-sm',
          isActive
            ? 'border-primary/20 bg-primary/10 font-semibold text-primary'
            : 'text-sidebar-foreground hover:bg-sidebar-accent',
          collapsed && 'justify-center px-0',
        )
      }
    >
      {icon}
      {!collapsed && <span>{label}</span>}
    </NavLink>
  )
}
