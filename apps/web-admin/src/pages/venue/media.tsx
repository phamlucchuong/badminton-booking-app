import { Upload } from 'lucide-react'
import { useRef, useState } from 'react'
import { toast } from 'sonner'
import { useMediaUpload } from '@/hooks/venue/use-media-upload'
import { useMyVenue } from '@/hooks/venue/use-my-venue'

export function VenueMediaPage() {
  const { data: venue } = useMyVenue()
  const upload = useMediaUpload()
  const inputRef = useRef<HTMLInputElement>(null)
  const [uploadedUrls, setUploadedUrls] = useState<string[]>([])

  const handleFiles = async (files: FileList | null) => {
    if (!files || !venue) return

    for (const file of Array.from(files)) {
      if (file.size > 5 * 1024 * 1024) {
        toast.error(`${file.name} quá 5MB`)
        continue
      }
      const url = await upload.mutateAsync({ file, folder: `venues/${venue.id}` })
      if (url) {
        setUploadedUrls((current) => [...current, url])
        toast.success(`Đã tải lên ${file.name}`)
      }
    }
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Media</h1>

      <div
        className="flex cursor-pointer flex-col items-center justify-center rounded-xl border-2 border-dashed border-border bg-card py-12 transition-colors hover:border-[#0d7c5f]"
        onClick={() => inputRef.current?.click()}
        onDragOver={(event) => event.preventDefault()}
        onDrop={(event) => {
          event.preventDefault()
          void handleFiles(event.dataTransfer.files)
        }}
      >
        <Upload className="size-8 text-muted-foreground" />
        <p className="mt-2 text-sm font-medium">Kéo thả hoặc click để chọn ảnh</p>
        <p className="text-xs text-muted-foreground">PNG, JPG, WEBP · tối đa 5MB/ảnh</p>
        <input
          ref={inputRef}
          type="file"
          accept="image/*"
          multiple
          className="hidden"
          onChange={(event) => void handleFiles(event.target.files)}
        />
      </div>

      {upload.isPending && <p className="text-center text-sm text-muted-foreground">Đang tải lên...</p>}

      {uploadedUrls.length > 0 && (
        <div>
          <p className="mb-3 text-sm font-semibold">Ảnh đã tải lên ({uploadedUrls.length})</p>
          <div className="grid grid-cols-3 gap-3 sm:grid-cols-4 lg:grid-cols-6">
            {uploadedUrls.map((url, index) => (
              <div key={index} className="group relative aspect-square overflow-hidden rounded-lg border border-border">
                <img src={url} alt={`upload-${index}`} className="h-full w-full object-cover" />
                <button
                  type="button"
                  onClick={() => {
                    void navigator.clipboard.writeText(url)
                    toast.success('Đã copy URL')
                  }}
                  className="absolute inset-0 flex items-center justify-center bg-black/60 text-xs text-white opacity-0 transition-opacity group-hover:opacity-100"
                >
                  Copy URL
                </button>
              </div>
            ))}
          </div>
          <p className="mt-2 text-xs text-muted-foreground">
            Lưu ý: URL ảnh chỉ lưu trong session này. Dùng ngay hoặc copy lại.
          </p>
        </div>
      )}
    </div>
  )
}
