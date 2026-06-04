import { Button } from '@/components/ui/button'
import { useCopy } from '@/lib/copy'

function Field({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <label className="text-sm font-medium">{label}</label>
      <input
        defaultValue={value}
        className="mt-1.5 h-10 w-full rounded-md border border-input bg-background px-3 text-sm"
      />
    </div>
  )
}

export function AdminSettingsPage() {
  const copy = useCopy()

  return (
    <div className="w-full space-y-5">
      <h1 className="text-2xl font-bold">{copy.systemTitle}</h1>
      <div className="card-surface space-y-4 p-6">
        <div className="flex flex-wrap gap-2 text-sm">
          {['Courts', 'Redis', 'RabbitMQ', 'JWT'].map((tab, index) => (
            <button
              key={tab}
              type="button"
              className={
                index === 0
                  ? 'rounded-lg border border-primary/20 bg-primary/10 px-3 py-1.5 text-primary'
                  : 'rounded-lg border border-border px-3 py-1.5 hover:bg-accent'
              }
            >
              {tab}
            </button>
          ))}
        </div>

        <div className="grid gap-4 md:grid-cols-2">
          <Field label="Max images per venue" value="12" />
          <Field label="Supported formats" value="jpg,png,webp" />
          <Field label="Redis host" value="localhost" />
          <Field label="Redis port" value="6379" />
          <Field label="JWT expiry (minutes)" value="120" />
        </div>

        <Button>{copy.systemSave}</Button>
      </div>
    </div>
  )
}
