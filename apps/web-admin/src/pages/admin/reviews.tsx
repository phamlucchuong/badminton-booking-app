export function AdminReviewsPage() {
  return (
    <div className="flex flex-col items-center justify-center gap-4 py-24 text-center">
      <div className="rounded-full border border-border bg-muted/30 p-6">
        <span className="text-4xl">Reviews</span>
      </div>
      <div>
        <h1 className="text-xl font-semibold">Quan ly danh gia</h1>
        <p className="mt-2 max-w-xs text-sm text-muted-foreground">
          Tinh nang kiem duyet danh gia dang duoc phat trien.
        </p>
      </div>
      <span className="rounded-full border border-blue-700/40 bg-blue-950/30 px-3 py-1 text-xs text-blue-400">
        Sap ra mat
      </span>
    </div>
  )
}
