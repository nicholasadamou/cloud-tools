import { File } from 'lucide-react'
import { Badge } from '@/components/ui/badge'

interface SelectedFileProps {
  file: File
  fileType: string | null
}

export function SelectedFile({ file, fileType }: SelectedFileProps) {
  return (
    <div className="flex items-center space-x-4 p-4 bg-gray-50 rounded-lg">
      <div className="flex-shrink-0">
        <File className="h-10 w-10 text-gray-400" />
      </div>
      <div className="flex-grow min-w-0">
        <p className="text-sm font-medium text-gray-900 truncate">
          {file.name}
        </p>
        <p className="text-sm text-gray-500">
          {(file.size / 1024 / 1024).toFixed(2)} MB
        </p>
      </div>
      {fileType && (
        <div className="flex-shrink-0">
          <Badge variant="secondary" className="uppercase">
            {fileType}
          </Badge>
        </div>
      )}
    </div>
  )
}

