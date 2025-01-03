"use client"

import { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { Card, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Download } from 'lucide-react'
import { ScrollArea } from '@/components/ui/scroll-area'

interface ConversionRecord {
  originalName: string
  convertedTo: string
  date: string
  url: string
}

const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.5 }
}

interface ConversionHistoryProps {
  storageKey: string;
}

export default function ConversionHistory({ storageKey }: ConversionHistoryProps) {
  const [history, setHistory] = useState<ConversionRecord[]>([])

  useEffect(() => {
    const storedHistory = JSON.parse(localStorage.getItem(storageKey) || '[]')
    setHistory(storedHistory)
  }, [storageKey])

  return (
    <motion.div
      variants={fadeInUp}
      initial="initial"
      animate="animate"
    >
      <Card className="w-full h-[600px]">
        <CardContent className="p-0">
          <ScrollArea className="h-full">
            {history.length === 0 ? (
              <motion.p 
                className="text-center text-muted-foreground p-4"
                variants={fadeInUp}
                transition={{ delay: 0.2 }}
              >
                No conversion history yet.
              </motion.p>
            ) : (
              <motion.ul 
                className="divide-y divide-border"
                variants={fadeInUp}
                transition={{ delay: 0.2, staggerChildren: 0.1 }}
              >
                {history.map((record, index) => (
                  <motion.li 
                    key={index} 
                    className="p-4 hover:bg-muted/50 transition-colors"
                    variants={fadeInUp}
                  >
                    <div className="flex items-center justify-between">
                      <div>
                        <p className="font-medium truncate text-foreground">{record.originalName}</p>
                        <p className="text-sm text-muted-foreground">Converted to: {record.convertedTo.toUpperCase()}</p>
                        <p className="text-sm text-muted-foreground">{new Date(record.date).toLocaleString()}</p>
                      </div>
                      <Button variant="outline" size="sm" onClick={() => window.open(record.url, '_blank')}>
                        <Download className="w-4 h-4 mr-2" />
                        Download
                      </Button>
                    </div>
                  </motion.li>
                ))}
              </motion.ul>
            )}
          </ScrollArea>
        </CardContent>
      </Card>
    </motion.div>
  )
}

