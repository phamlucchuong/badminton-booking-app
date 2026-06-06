import { Package2, Plus } from 'lucide-react'
import { useState, type ChangeEvent } from 'react'
import { toast } from 'sonner'
import { Button } from '@/components/ui/button'
import { DataTable } from '@/components/ui/data-table'
import { FormField, SelectField } from '@/components/ui/form-field'
import { Modal } from '@/components/ui/modal'
import { useMyVenue } from '@/hooks/venue/use-my-venue'
import { useCreateProduct, useProducts } from '@/hooks/venue/use-products'
import type { ProductResponse } from '@/types/api'

const CATEGORIES = [
  { value: 'RACKET_RENTAL', label: 'Cho thuê vợt' },
  { value: 'SHUTTLECOCK', label: 'Cầu lông' },
  { value: 'EQUIPMENT', label: 'Phụ kiện' },
  { value: 'BEVERAGE', label: 'Đồ uống' },
  { value: 'OTHER', label: 'Khác' },
]

const CATEGORY_LABELS = Object.fromEntries(CATEGORIES.map((item) => [item.value, item.label]))

export function VenueProductsPage() {
  const { data: venue } = useMyVenue()
  const venueId = venue?.id ?? ''
  const { data: products, isLoading } = useProducts(venueId)
  const createProduct = useCreateProduct(venueId)

  const [showModal, setShowModal] = useState(false)
  const [form, setForm] = useState({
    name: '',
    description: '',
    category: 'BEVERAGE',
    price: '',
    unit: '',
    stock: '',
  })

  const set =
    (key: keyof typeof form) =>
    (event: ChangeEvent<HTMLInputElement | HTMLSelectElement>) =>
      setForm((current) => ({ ...current, [key]: event.target.value }))

  const handleCreate = async () => {
    await createProduct.mutateAsync({
      name: form.name,
      description: form.description || undefined,
      category: form.category,
      price: Number(form.price),
      unit: form.unit,
      stock: Number(form.stock),
    })
    toast.success('Đã thêm sản phẩm')
    setShowModal(false)
    setForm({ name: '', description: '', category: 'BEVERAGE', price: '', unit: '', stock: '' })
  }

  const columns = [
    {
      key: 'name',
      header: 'Sản phẩm',
      render: (row: ProductResponse) => (
        <div className="flex items-center gap-3">
          {row.imageId ? (
            <img
              src={row.imageId}
              alt={row.name}
              className="size-12 rounded-xl border border-border object-cover"
            />
          ) : (
            <div className="flex size-12 items-center justify-center rounded-xl border border-dashed border-border bg-muted text-muted-foreground">
              <Package2 className="size-5" />
            </div>
          )}
          <div>
            <p className="font-medium text-foreground">{row.name}</p>
            {row.description ? (
              <p className="line-clamp-2 text-xs text-muted-foreground">{row.description}</p>
            ) : null}
          </div>
        </div>
      ),
    },
    {
      key: 'category',
      header: 'Danh mục',
      render: (row: ProductResponse) => (
        <span className="rounded-full border border-border bg-muted px-2 py-0.5 text-xs">
          {CATEGORY_LABELS[row.category] ?? row.category}
        </span>
      ),
    },
    {
      key: 'price',
      header: 'Giá',
      render: (row: ProductResponse) => `${row.price.toLocaleString('vi-VN')}đ/${row.unit}`,
    },
    { key: 'stock', header: 'Tồn kho', render: (row: ProductResponse) => row.stock },
    {
      key: 'active',
      header: 'Trạng thái',
      render: (row: ProductResponse) => (
        <span className={`rounded-full px-2 py-0.5 text-xs ${row.active ? 'bg-green-900/50 text-green-300' : 'bg-muted text-muted-foreground'}`}>
          {row.active ? 'Hoạt động' : 'Ẩn'}
        </span>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Sản phẩm</h1>
          <p className="mt-1 text-sm text-muted-foreground">{products?.length ?? 0} sản phẩm</p>
        </div>
        <Button onClick={() => setShowModal(true)}>
          <Plus className="mr-1.5 size-4" />
          Thêm sản phẩm
        </Button>
      </div>

      <DataTable
        columns={columns}
        data={products ?? []}
        loading={isLoading}
        keyExtractor={(row) => row.id}
        emptyMessage="Chưa có sản phẩm nào"
      />

      <Modal
        open={showModal}
        onClose={() => setShowModal(false)}
        title="Thêm sản phẩm mới"
        footer={
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setShowModal(false)}>
              Hủy
            </Button>
            <Button onClick={() => void handleCreate()} disabled={createProduct.isPending || !form.name || !form.price || !form.unit}>
              {createProduct.isPending ? 'Đang lưu...' : 'Thêm'}
            </Button>
          </div>
        }
      >
        <div className="space-y-4">
          <FormField label="Tên sản phẩm *" value={form.name} onChange={set('name')} />
          <SelectField label="Danh mục *" value={form.category} onChange={set('category')} options={CATEGORIES} />
          <div className="grid grid-cols-2 gap-3">
            <FormField label="Giá (VND) *" type="number" value={form.price} onChange={set('price')} placeholder="10000" />
            <FormField label="Đơn vị *" value={form.unit} onChange={set('unit')} placeholder="chai, ống, vợt/buổi..." />
          </div>
          <FormField label="Số lượng tồn kho" type="number" value={form.stock} onChange={set('stock')} placeholder="0" />
          <FormField label="Mô tả" value={form.description} onChange={set('description')} />
        </div>
      </Modal>
    </div>
  )
}
