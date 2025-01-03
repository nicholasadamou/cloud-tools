import { Cloud } from 'lucide-react'
import Link from 'next/link'

export default function Logo() {
  return (
    <Link href="/" className="flex items-center">
      <Cloud className="w-8 h-8 mr-2 text-primary" />
      <span className="text-2xl font-bold text-foreground">Cloud Tools</span>
    </Link>
  )
}

