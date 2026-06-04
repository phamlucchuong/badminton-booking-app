import { Plus, Trash2 } from 'lucide-react'
import { useMemo, useState } from 'react'
import { Button } from '@/components/ui/button'
import { useCopy } from '@/lib/copy'
import { cn } from '@/lib/utils'

type PermissionAction =
  | 'create'
  | 'read'
  | 'update'
  | 'delete'
  | 'approve'
  | 'verify'
  | 'refund'

interface Role {
  id: string
  name: string
  description: string
  system: boolean
  permissions: Record<string, PermissionAction[]>
}

const resources = [
  { key: 'users', label: 'Users', actions: ['read', 'update', 'delete'] },
  {
    key: 'venues',
    label: 'Venues',
    actions: ['read', 'approve', 'verify'],
  },
  {
    key: 'bookings',
    label: 'Bookings',
    actions: ['read', 'update', 'delete'],
  },
  { key: 'payments', label: 'Payments', actions: ['read', 'refund'] },
  { key: 'settings', label: 'Settings', actions: ['read', 'update'] },
] as const

function initialRoles(): Role[] {
  return [
    {
      id: 'admin',
      name: 'Admin',
      description: 'Full system access',
      system: true,
      permissions: {
        users: ['read', 'update', 'delete'],
        venues: ['read', 'approve', 'verify'],
        bookings: ['read', 'update', 'delete'],
        payments: ['read', 'refund'],
        settings: ['read', 'update'],
      },
    },
    {
      id: 'moderator',
      name: 'Moderator',
      description: 'Review venues and booking disputes',
      system: false,
      permissions: {
        users: ['read'],
        venues: ['read', 'approve', 'verify'],
        bookings: ['read', 'update'],
        payments: ['read'],
        settings: [],
      },
    },
  ]
}

export function AdminRbacPage() {
  const copy = useCopy()
  const [roles, setRoles] = useState<Role[]>(initialRoles)
  const [selectedRoleId, setSelectedRoleId] = useState('admin')
  const [newRoleName, setNewRoleName] = useState('')
  const [newRoleDescription, setNewRoleDescription] = useState('')

  const selectedRole = useMemo(
    () => roles.find((role) => role.id === selectedRoleId) ?? roles[0],
    [roles, selectedRoleId],
  )

  const updatePermission = (
    resourceKey: string,
    action: PermissionAction,
    checked: boolean,
  ) => {
    setRoles((current) =>
      current.map((role) => {
        if (role.id !== selectedRole.id) {
          return role
        }

        const currentActions = new Set(role.permissions[resourceKey] ?? [])
        if (checked) {
          currentActions.add(action)
        } else {
          currentActions.delete(action)
        }

        return {
          ...role,
          permissions: {
            ...role.permissions,
            [resourceKey]: Array.from(currentActions),
          },
        }
      }),
    )
  }

  const createRole = () => {
    const name = newRoleName.trim()
    if (!name) {
      return
    }

    const id = `${name.toLowerCase().replace(/[^a-z0-9]+/g, '-')}-${Date.now()}`
    setRoles((current) => [
      ...current,
      {
        id,
        name,
        description: newRoleDescription.trim(),
        system: false,
        permissions: {
          users: [],
          venues: [],
          bookings: [],
          payments: [],
          settings: [],
        },
      },
    ])
    setSelectedRoleId(id)
    setNewRoleName('')
    setNewRoleDescription('')
  }

  const deleteRole = (roleId: string) => {
    const nextRoles = roles.filter((role) => role.id !== roleId)
    setRoles(nextRoles)
    setSelectedRoleId(nextRoles[0]?.id ?? '')
  }

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between gap-3">
        <h1 className="text-2xl font-bold">{copy.rbacTitle}</h1>
      </div>

      <div className="grid gap-5 lg:grid-cols-[280px_1fr]">
        <div className="card-surface p-3">
          <div className="mb-3 px-2 text-sm font-semibold">{copy.rbacRoles}</div>
          <div className="space-y-2">
            {roles.map((role) => {
              const active = role.id === selectedRole.id
              return (
                <button
                  key={role.id}
                  type="button"
                  onClick={() => setSelectedRoleId(role.id)}
                  className={cn(
                    'flex w-full items-start justify-between rounded-lg border px-3 py-2 text-left',
                    active
                      ? 'border-primary/20 bg-primary/10 text-primary'
                      : 'border-transparent hover:bg-accent',
                  )}
                >
                  <div>
                    <div className="font-medium">{role.name}</div>
                    <div className="mt-1 text-xs text-muted-foreground">
                      {role.description}
                    </div>
                  </div>
                  {!role.system && (
                    <Trash2
                      className="mt-0.5 size-4 text-muted-foreground hover:text-foreground"
                      onClick={(event) => {
                        event.stopPropagation()
                        deleteRole(role.id)
                      }}
                    />
                  )}
                </button>
              )
            })}
          </div>

          <div className="mt-4 space-y-2 border-t border-border pt-4">
            <input
              value={newRoleName}
              onChange={(event) => setNewRoleName(event.target.value)}
              placeholder={copy.rbacRoleName}
              className="h-10 w-full rounded-lg border border-input bg-background px-3 text-sm"
            />
            <input
              value={newRoleDescription}
              onChange={(event) => setNewRoleDescription(event.target.value)}
              placeholder={copy.rbacRoleDesc}
              className="h-10 w-full rounded-lg border border-input bg-background px-3 text-sm"
            />
            <Button className="w-full" onClick={createRole}>
              <Plus className="mr-2 size-4" />
              {copy.rbacCreateRole}
            </Button>
          </div>
        </div>

        <div className="card-surface overflow-hidden">
          <div className="border-b border-border px-5 py-4">
            <h2 className="text-lg font-semibold">{selectedRole.name}</h2>
            <p className="text-sm text-muted-foreground">
              {selectedRole.description}
            </p>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-muted/50 text-left">
                <tr>
                  <th className="p-3">{copy.rbacResource}</th>
                  <th className="p-3">{copy.rbacActions}</th>
                </tr>
              </thead>
              <tbody>
                {resources.map((resource) => (
                  <tr key={resource.key} className="border-t border-border">
                    <td className="p-3 font-medium">{resource.label}</td>
                    <td className="p-3">
                      <div className="flex flex-wrap gap-3">
                        {resource.actions.map((action) => (
                          <label
                            key={action}
                            className="inline-flex items-center gap-2 rounded-full border border-border px-3 py-1.5 text-xs"
                          >
                            <input
                              type="checkbox"
                              checked={selectedRole.permissions[resource.key]?.includes(
                                action as PermissionAction,
                              )}
                              onChange={(event) =>
                                updatePermission(
                                  resource.key,
                                  action as PermissionAction,
                                  event.target.checked,
                                )
                              }
                            />
                            {action}
                          </label>
                        ))}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="flex justify-end gap-3 border-t border-border px-5 py-4">
            <Button variant="outline">{copy.rbacReset}</Button>
            <Button>{copy.rbacSave}</Button>
          </div>
        </div>
      </div>
    </div>
  )
}
