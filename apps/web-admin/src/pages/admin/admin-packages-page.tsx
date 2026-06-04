import { Button } from '@/components/ui/button'
import { useCopy } from '@/lib/copy'

export function AdminPackagesPage() {
  const copy = useCopy()

  return (
    <div className="space-y-5">
      <h1 className="text-2xl font-bold">{copy.packagesTitle}</h1>

      <div className="grid gap-4 md:grid-cols-3">
        {[
          {
            name: 'Starter',
            price: '1,200,000 VND / month',
            features: ['2 courts listed', 'Basic promotion tools'],
            featured: false,
          },
          {
            name: 'Growth',
            price: '3,500,000 VND / month',
            features: ['Unlimited courts', 'Priority ranking', 'Booking analytics'],
            featured: true,
          },
          {
            name: 'Enterprise',
            price: '8,000,000 VND / month',
            features: ['Custom reporting', 'Dedicated support'],
            featured: false,
          },
        ].map((item) => (
          <div key={item.name} className="card-surface p-5">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-bold">{item.name}</h2>
              {item.featured && (
                <span className="rounded-full bg-primary/10 px-2 py-1 text-xs text-primary">
                  Popular
                </span>
              )}
            </div>
            <div className="mt-3 text-2xl font-bold">{item.price}</div>
            <ul className="mt-4 space-y-2 text-sm text-muted-foreground">
              {item.features.map((feature) => (
                <li key={feature}>• {feature}</li>
              ))}
            </ul>
            <Button className="mt-5" variant="outline">
              Edit price
            </Button>
          </div>
        ))}
      </div>
    </div>
  )
}
