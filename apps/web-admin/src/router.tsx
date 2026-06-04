import { Navigate, createBrowserRouter } from 'react-router-dom'
import { AdminLayout } from '@/components/layouts/admin-layout'
import { NotFoundPage } from '@/pages/not-found-page'
import { SignInPage } from '@/pages/sign-in-page'
import { AdminAiConfigPage } from '@/pages/admin/admin-ai-config-page'
import { AdminAuditLogsPage } from '@/pages/admin/admin-audit-logs-page'
import { AdminDashboardPage } from '@/pages/admin/admin-dashboard-page'
import { AdminEmployerVerificationPage } from '@/pages/admin/admin-employer-verification-page'
import { AdminJobModerationPage } from '@/pages/admin/admin-job-moderation-page'
import { AdminPackagesPage } from '@/pages/admin/admin-packages-page'
import { AdminPaymentsPage } from '@/pages/admin/admin-payments-page'
import { AdminRbacPage } from '@/pages/admin/admin-rbac-page'
import { AdminSettingsPage } from '@/pages/admin/admin-settings-page'
import { AdminUsersPage } from '@/pages/admin/admin-users-page'

export const router = createBrowserRouter([
  {
    path: '/',
    element: <Navigate to="/admin" replace />,
    errorElement: <NotFoundPage />,
  },
  {
    path: '/signin',
    element: <SignInPage />,
  },
  {
    path: '/admin',
    element: <AdminLayout />,
    errorElement: <NotFoundPage />,
    children: [
      { index: true, element: <AdminDashboardPage /> },
      { path: 'users', element: <AdminUsersPage /> },
      { path: 'rbac', element: <AdminRbacPage /> },
      {
        path: 'employer-verification',
        element: <AdminEmployerVerificationPage />,
      },
      { path: 'job-moderation', element: <AdminJobModerationPage /> },
      { path: 'packages', element: <AdminPackagesPage /> },
      { path: 'payments', element: <AdminPaymentsPage /> },
      { path: 'ai-config', element: <AdminAiConfigPage /> },
      { path: 'settings', element: <AdminSettingsPage /> },
      { path: 'audit-logs', element: <AdminAuditLogsPage /> },
    ],
  },
  {
    path: '*',
    element: <NotFoundPage />,
  },
])
