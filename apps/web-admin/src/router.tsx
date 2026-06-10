import { createBrowserRouter } from 'react-router-dom'
import { AdminLayout } from '@/components/layouts/admin-layout'
import { VenueLayout } from '@/components/layouts/venue-layout'
import { AdminGuard } from '@/guards/admin-guard'
import { VenueGuard } from '@/guards/venue-guard'
import { AdminDashboardPage } from '@/pages/admin/dashboard'
import { AdminInvoicesPage } from '@/pages/admin/invoices'
import { AdminReviewsPage } from '@/pages/admin/reviews'
import { AdminUsersPage } from '@/pages/admin/users'
import { AdminVenuesPage } from '@/pages/admin/venues'
import { LoginPage } from '@/pages/login'
import { NotFoundPage } from '@/pages/not-found-page'
import { RootRedirectPage } from '@/pages/root-redirect-page'
import { RoleSelectPage } from '@/pages/select-role'
import { VenueBookingsPage } from '@/pages/venue/bookings'
import { VenueCourtsPage } from '@/pages/venue/courts'
import { VenueDashboardPage } from '@/pages/venue/dashboard'
import { VenueHoursPage } from '@/pages/venue/hours'
import { VenueInvoicesPage } from '@/pages/venue/invoices'
import { VenueMediaPage } from '@/pages/venue/media'
import { VenueProductsPage } from '@/pages/venue/products'
import { VenueProfilePage } from '@/pages/venue/profile'
import { VenueReviewsPage } from '@/pages/venue/reviews'

export const router = createBrowserRouter([
  { path: '/', element: <RootRedirectPage /> },
  { path: '/login', element: <LoginPage /> },
  { path: '/select-role', element: <RoleSelectPage /> },
  {
    path: '/admin',
    element: (
      <AdminGuard>
        <AdminLayout />
      </AdminGuard>
    ),
    children: [
      { index: true, element: <AdminDashboardPage /> },
      { path: 'venues', element: <AdminVenuesPage /> },
      { path: 'users', element: <AdminUsersPage /> },
      { path: 'invoices', element: <AdminInvoicesPage /> },
      { path: 'reviews', element: <AdminReviewsPage /> },
    ],
  },
  {
    path: '/venue',
    element: (
      <VenueGuard>
        <VenueLayout />
      </VenueGuard>
    ),
    children: [
      { index: true, element: <VenueDashboardPage /> },
      { path: 'profile', element: <VenueProfilePage /> },
      { path: 'courts', element: <VenueCourtsPage /> },
      { path: 'hours', element: <VenueHoursPage /> },
      { path: 'products', element: <VenueProductsPage /> },
      { path: 'bookings', element: <VenueBookingsPage /> },
      { path: 'reviews', element: <VenueReviewsPage /> },
      { path: 'media', element: <VenueMediaPage /> },
      { path: 'invoices', element: <VenueInvoicesPage /> },
    ],
  },
  { path: '*', element: <NotFoundPage /> },
])
