import type { InputHTMLAttributes, SelectHTMLAttributes } from 'react'
import { cn } from '@/lib/utils'

interface FormFieldProps extends InputHTMLAttributes<HTMLInputElement> {
  label: string
  error?: string
}

export function FormField({ label, error, className, ...props }: FormFieldProps) {
  return (
    <div className="space-y-1.5">
      <label className="text-sm font-medium">{label}</label>
      <input
        className={cn(
          'h-10 w-full rounded-md border border-input bg-background px-3 text-sm transition-colors',
          'focus:outline-none focus:ring-2 focus:ring-ring',
          error && 'border-red-400 focus:ring-red-300',
          className,
        )}
        {...props}
      />
      {error && <p className="text-xs text-red-500">{error}</p>}
    </div>
  )
}

interface SelectFieldProps extends SelectHTMLAttributes<HTMLSelectElement> {
  label: string
  error?: string
  options: { value: string; label: string }[]
}

export function SelectField({
  label,
  error,
  options,
  className,
  ...props
}: SelectFieldProps) {
  return (
    <div className="space-y-1.5">
      <label className="text-sm font-medium">{label}</label>
      <select
        className={cn(
          'h-10 w-full rounded-md border border-input bg-background px-3 text-sm transition-colors',
          'focus:outline-none focus:ring-2 focus:ring-ring',
          error && 'border-red-400 focus:ring-red-300',
          className,
        )}
        {...props}
      >
        {options.map((option) => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
      {error && <p className="text-xs text-red-500">{error}</p>}
    </div>
  )
}
