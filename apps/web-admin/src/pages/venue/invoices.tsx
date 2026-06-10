import { DataTable } from '@/components/ui/data-table'
import { useVenueInvoices } from '@/hooks/venue/use-venue-invoices'
import type { PlatformFeeInvoice } from '@/types/api'

export function VenueInvoicesPage() {
  const { data: invoices, isLoading } = useVenueInvoices()

  const columns = [
    { key: 'period', header: 'Kỳ', render: (row: PlatformFeeInvoice) => row.period },
    {
      key: 'totalBookings',
      header: 'Số booking',
      render: (row: PlatformFeeInvoice) => row.totalBookings,
    },
    {
      key: 'totalRevenue',
      header: 'Doanh thu',
      render: (row: PlatformFeeInvoice) => `${row.totalRevenue.toLocaleString('vi-VN')}đ`,
    },
    {
      key: 'feeAmount',
      header: 'Phí nền tảng',
      render: (row: PlatformFeeInvoice) => (
        <span className="font-semibold text-amber-400">{row.feeAmount.toLocaleString('vi-VN')}đ</span>
      ),
    },
    { key: 'dueDate', header: 'Hạn đóng', render: (row: PlatformFeeInvoice) => row.dueDate },
    {
      key: 'status',
      header: 'Trạng thái',
      render: (row: PlatformFeeInvoice) => (
        <span className={`rounded-full px-2 py-0.5 text-xs font-medium ${row.status === 'PAID' ? 'bg-green-900/50 text-green-300' : 'bg-amber-900/50 text-amber-300'}`}>
          {row.status === 'PAID' ? 'Đã đóng' : 'Chưa đóng'}
        </span>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Hóa đơn phí nền tảng</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          Admin sẽ cập nhật trạng thái sau khi nhận thanh toán
        </p>
      </div>

      <DataTable
        columns={columns}
        data={(invoices ?? []).sort((left, right) => right.period.localeCompare(left.period))}
        loading={isLoading}
        keyExtractor={(row) => row.id}
        emptyMessage="Chưa có hóa đơn nào"
      />
    </div>
  )
}
