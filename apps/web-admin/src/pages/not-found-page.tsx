import { ArrowLeft } from 'lucide-react'
import { Link } from 'react-router-dom'
import { useCopy } from '@/lib/copy'

export function NotFoundPage() {
  const copy = useCopy()

  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-6">
      <div className="w-full max-w-2xl text-center">
        <p className="text-8xl font-black leading-none tracking-tight text-foreground md:text-9xl">
          {copy.notFoundTitle}
        </p>
        <h1 className="mt-4 text-xl font-bold text-foreground">
          {copy.notFoundHeading}
        </h1>
        <p className="mx-auto mt-3 max-w-md text-sm text-muted-foreground">
          {copy.notFoundDesc}
        </p>
        <Link
          to="/"
          className="mt-8 inline-flex items-center gap-2 rounded-lg border border-primary/30 bg-primary px-5 py-2.5 text-sm font-semibold uppercase tracking-wide text-white shadow-sm transition-colors hover:bg-primary/90"
        >
          <ArrowLeft className="size-4" />
          {copy.backHome}
        </Link>
      </div>
    </div>
  )
}
