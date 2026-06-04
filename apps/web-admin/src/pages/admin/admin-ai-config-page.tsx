import { Button } from '@/components/ui/button'
import { useCopy } from '@/lib/copy'

export function AdminAiConfigPage() {
  const copy = useCopy()

  return (
    <div className="w-full space-y-5">
      <h1 className="text-2xl font-bold">{copy.aiTitle}</h1>

      <div className="card-surface space-y-5 p-6">
        <div>
          <label className="text-sm font-medium">Support confidence threshold</label>
          <input
            type="range"
            min={0}
            max={100}
            defaultValue={78}
            className="mt-2 w-full"
          />
        </div>
        <div>
          <label className="text-sm font-medium">Timeout (ms)</label>
          <input
            defaultValue={3500}
            className="mt-1.5 h-10 w-full rounded-md border border-input bg-background px-3 text-sm"
          />
        </div>
        <div>
          <label className="text-sm font-medium">Model</label>
          <select className="mt-1.5 h-10 w-full rounded-md border border-input bg-background px-3 text-sm">
            <option>gpt-4.1-mini</option>
            <option>gpt-4.1</option>
            <option>gpt-4o-mini</option>
          </select>
        </div>
        <Button>{copy.aiSave}</Button>
      </div>

      <div className="card-surface p-6">
        <h2 className="mb-3 font-semibold">{copy.aiQueueStats}</h2>
        <div className="grid gap-3 text-sm md:grid-cols-3">
          <div>
            Waiting: <strong>42</strong>
          </div>
          <div>
            Processing: <strong>8</strong>
          </div>
          <div>
            Failed: <strong>2</strong>
          </div>
        </div>
      </div>
    </div>
  )
}
