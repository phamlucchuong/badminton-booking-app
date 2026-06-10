import type { ChangeEvent, ReactNode } from 'react'
import { useState } from 'react'
import { ChevronLeft, ChevronRight, Plus } from 'lucide-react'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { DataTable } from '@/components/ui/data-table'
import { FormField } from '@/components/ui/form-field'
import { Modal } from '@/components/ui/modal'
import {
  useAdminUsers,
  useCreateAdminUser,
  useDeleteAdminUser,
} from '@/hooks/admin/use-admin-users'
import type { AdminUserResponse } from '@/types/api'

type TableColumn<T> = {
  key: string
  header: string
  render?: (row: T) => ReactNode
  className?: string
}

export function AdminUsersPage() {
  const [page, setPage] = useState(1)
  const { data: usersPage, isLoading } = useAdminUsers(page)
  const createUser = useCreateAdminUser()
  const deleteUser = useDeleteAdminUser()
  const [showModal, setShowModal] = useState(false)
  const [form, setForm] = useState({ name: '', email: '', phone: '', password: '' })

  const users = usersPage?.content ?? usersPage?.items ?? []
  const totalPages = usersPage?.totalPages ?? 1

  const setField =
    (key: keyof typeof form) =>
    (event: ChangeEvent<HTMLInputElement>) => {
      setForm((current) => ({ ...current, [key]: event.target.value }))
    }

  const handleCreate = async () => {
    await createUser.mutateAsync(form, {
      onSuccess: () => {
        toast.success('Da tao tai khoan')
        setShowModal(false)
        setForm({ name: '', email: '', phone: '', password: '' })
      },
      onError: () => toast.error('Tao tai khoan that bai'),
    })
  }

  const handleDelete = (user: AdminUserResponse) => {
    if (!window.confirm(`Xoa tai khoan "${user.name}" (${user.email})?`)) return
    deleteUser.mutate(user.id, {
      onSuccess: () => toast.success('Da xoa tai khoan'),
      onError: () => toast.error('Xoa that bai'),
    })
  }

  const columns: TableColumn<AdminUserResponse>[] = [
    {
      key: 'name',
      header: 'Ten',
      render: (user) => <span className="font-medium">{user.name}</span>,
    },
    { key: 'email', header: 'Email' },
    { key: 'phone', header: 'SDT' },
    {
      key: 'createdAt',
      header: 'Ngay tao',
      render: (user) => new Date(user.createdAt).toLocaleDateString('vi-VN'),
    },
    {
      key: 'deleted',
      header: 'Trang thai',
      render: (user) => (
        <span
          className={`rounded-full px-2 py-0.5 text-xs font-medium ${
            user.deleted
              ? 'bg-red-900/50 text-red-300'
              : 'bg-emerald-900/50 text-emerald-300'
          }`}
        >
          {user.deleted ? 'Da xoa' : 'Hoat dong'}
        </span>
      ),
    },
    {
      key: 'actions',
      header: '',
      render: (user) => (
        <button
          type="button"
          disabled={user.deleted || deleteUser.isPending}
          onClick={() => handleDelete(user)}
          className="text-xs text-red-400 hover:underline disabled:cursor-not-allowed disabled:opacity-40"
        >
          Xoa
        </button>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold">Nguoi dung</h1>
          <p className="mt-1 text-sm text-muted-foreground">
            Trang {page} / {totalPages}
          </p>
        </div>
        <Button onClick={() => setShowModal(true)}>
          <Plus className="mr-1.5 size-4" />
          Tao tai khoan
        </Button>
      </div>

      <DataTable
        columns={columns}
        data={users}
        loading={isLoading}
        keyExtractor={(user) => user.id}
        emptyMessage="Khong co nguoi dung"
      />

      <div className="flex items-center justify-end gap-2">
        <Button
          variant="outline"
          size="icon"
          disabled={page <= 1}
          onClick={() => setPage((current) => current - 1)}
        >
          <ChevronLeft className="size-4" />
        </Button>
        <span className="text-sm text-muted-foreground">
          {page} / {totalPages}
        </span>
        <Button
          variant="outline"
          size="icon"
          disabled={page >= totalPages}
          onClick={() => setPage((current) => current + 1)}
        >
          <ChevronRight className="size-4" />
        </Button>
      </div>

      <Modal
        open={showModal}
        onClose={() => setShowModal(false)}
        title="Tao tai khoan moi"
        footer={
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setShowModal(false)}>
              Huy
            </Button>
            <Button
              onClick={() => void handleCreate()}
              disabled={
                createUser.isPending ||
                !form.name ||
                !form.email ||
                !form.phone ||
                !form.password
              }
            >
              {createUser.isPending ? 'Dang tao...' : 'Tao tai khoan'}
            </Button>
          </div>
        }
      >
        <div className="space-y-4">
          <FormField
            label="Ten *"
            value={form.name}
            onChange={setField('name')}
            placeholder="Nguyen Van A"
          />
          <FormField
            label="Email *"
            type="email"
            value={form.email}
            onChange={setField('email')}
            placeholder="user@example.com"
          />
          <FormField
            label="So dien thoai *"
            value={form.phone}
            onChange={setField('phone')}
            placeholder="0901234567"
          />
          <FormField
            label="Mat khau *"
            type="password"
            value={form.password}
            onChange={setField('password')}
            placeholder="password123"
          />
        </div>
      </Modal>
    </div>
  )
}
