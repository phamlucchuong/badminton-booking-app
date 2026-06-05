import {
  ChevronDown,
  Menu,
  Moon,
  Search,
  Sun,
  type LucideIcon,
} from 'lucide-react'
import { useState, type ReactNode } from 'react'
import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { api } from '@/lib/axios'
import { useCopy } from '@/lib/copy'
import { queryClient } from '@/lib/query-client'
import { cn } from '@/lib/utils'
import { useAuthStore } from '@/store/auth'
import { usePreferencesStore } from '@/store/preferences'

export interface NavItem {
  icon: LucideIcon
  label: string
  to: string
}

export interface NavGroup {
  key: string
  label: string
  items: NavItem[]
}

interface PortalLayoutProps {
  navGroups: NavGroup[]
  accentColor: string
  roleLabel: string
  roleIcon: LucideIcon
  otherRole?: string
  onSwitchRole?: () => void
}

export function PortalLayout({
  navGroups,
  accentColor,
  roleLabel,
  roleIcon: RoleIcon,
  otherRole,
  onSwitchRole,
}: PortalLayoutProps) {
  const copy = useCopy()
  const navigate = useNavigate()
  const { pathname } = useLocation()
  const [collapsed, setCollapsed] = useState(false)
  const [openGroups, setOpenGroups] = useState<Record<string, boolean>>({})
  const theme = usePreferencesStore((state) => state.theme)
  const toggleTheme = usePreferencesStore((state) => state.toggleTheme)
  const toggleLanguage = usePreferencesStore((state) => state.toggleLanguage)
  const language = usePreferencesStore((state) => state.language)
  const user = useAuthStore((state) => state.user)
  const refreshToken = useAuthStore((state) => state.refreshToken)
  const clearAuth = useAuthStore((state) => state.clearAuth)

  const handleLogout = async () => {
    try {
      await api.post('/auth/logout', { refreshToken })
    } catch {
      // Clear local state even if the backend request fails.
    }

    clearAuth()
    queryClient.clear()
    navigate('/login')
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
          <div className="flex min-w-0 items-center gap-2">
            <div
              className="flex size-8 shrink-0 items-center justify-center rounded-lg text-white"
              style={{ backgroundColor: accentColor }}
            >
              <RoleIcon className="size-4" />
            </div>
            {!collapsed && (
              <div className="min-w-0">
                <div className="truncate text-sm font-bold">{copy.brand}</div>
                <div
                  className="mt-0.5 inline-block rounded px-1.5 py-0 text-[9px] font-semibold uppercase tracking-wide text-white"
                  style={{ backgroundColor: accentColor }}
                >
                  {roleLabel}
                </div>
              </div>
            )}
          </div>
        </div>

        <nav className="flex-1 space-y-1 overflow-y-auto p-2">
          {navGroups.map((group) => {
            const groupHasActive = group.items.some(
              (item) =>
                pathname === item.to ||
                (item.to !== '/admin' && item.to !== '/venue' && pathname.startsWith(item.to)),
            )

            if (group.items.length === 1) {
              const item = group.items[0]
              return (
                <PortalNavLink
                  key={item.to}
                  to={item.to}
                  icon={<item.icon className="size-4" />}
                  label={item.label}
                  collapsed={collapsed}
                  accentColor={accentColor}
                />
              )
            }

            const expanded = collapsed ? false : (openGroups[group.key] ?? groupHasActive)

            return (
              <div key={group.key} className="space-y-0.5">
                <button
                  type="button"
                  onClick={() =>
                    setOpenGroups((state) => ({ ...state, [group.key]: !expanded }))
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
                    <PortalNavLink
                      key={item.to}
                      to={item.to}
                      icon={<item.icon className="size-4" />}
                      label={item.label}
                      collapsed={collapsed}
                      accentColor={accentColor}
                    />
                  ))}
              </div>
            )
          })}
        </nav>

        <div className="space-y-1 p-2">
          {otherRole && onSwitchRole && !collapsed && (
            <button
              type="button"
              onClick={onSwitchRole}
              className="w-full rounded-lg border border-border px-3 py-2 text-xs text-muted-foreground hover:bg-accent"
            >
              ↔ {otherRole}
            </button>
          )}
          <button
            type="button"
            onClick={() => setCollapsed((value) => !value)}
            className="w-full rounded-lg border border-border px-3 py-2 text-xs text-muted-foreground hover:bg-accent"
          >
            {collapsed ? <Menu className="mx-auto size-4" /> : copy.collapseSidebar}
          </button>
        </div>
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
                  language === 'EN' ? 'text-primary-foreground' : 'text-muted-foreground',
                )}
              >
                EN
              </span>
              <span
                className={cn(
                  'relative z-10 w-9 text-center transition-colors duration-200',
                  language === 'VI' ? 'text-primary-foreground' : 'text-muted-foreground',
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
            >
              {theme === 'dark' ? <Sun className="size-4" /> : <Moon className="size-4" />}
            </Button>

            <button
              type="button"
              onClick={() => void handleLogout()}
              className="flex items-center gap-2 rounded-lg px-2 py-1.5 hover:bg-accent"
            >
              <div
                className="flex size-8 shrink-0 items-center justify-center rounded-full text-xs font-bold text-white"
                style={{ backgroundColor: accentColor }}
              >
                {(user?.name ?? 'U').slice(0, 1).toUpperCase()}
              </div>
              <div className="hidden text-left md:block">
                <div className="text-sm font-medium">{user?.name ?? 'User'}</div>
                <div className="text-xs text-muted-foreground">{copy.logout}</div>
              </div>
            </button>
          </div>
        </header>

        <main className="mx-auto w-full max-w-[1600px] flex-1 p-6">
          <Outlet />
        </main>
      </div>
    </div>
  )
}

interface PortalNavLinkProps {
  to: string
  icon: ReactNode
  label: string
  collapsed: boolean
  accentColor: string
}

function PortalNavLink({
  to,
  icon,
  label,
  collapsed,
  accentColor,
}: PortalNavLinkProps) {
  return (
    <NavLink
      to={to}
      end={to === '/admin' || to === '/venue'}
      className={({ isActive }) =>
        cn(
          'flex items-center gap-3 rounded-lg border border-transparent px-3 py-2 text-sm',
          isActive ? 'font-semibold' : 'text-sidebar-foreground hover:bg-sidebar-accent',
          collapsed && 'justify-center px-0',
        )
      }
      style={({ isActive }) =>
        isActive
          ? {
              color: accentColor,
              borderColor: `${accentColor}33`,
              backgroundColor: `${accentColor}1a`,
            }
          : {}
      }
    >
      {icon}
      {!collapsed && <span>{label}</span>}
    </NavLink>
  )
}
