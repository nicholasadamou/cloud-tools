"use client"

import React, { useState, useEffect, useRef } from 'react'
import { motion } from 'framer-motion'
import { useRouter } from 'next/navigation'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardFooter, CardHeader } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { toast } from '@/hooks/use-toast'
import { Loader2 } from 'lucide-react'
import { Progress } from '@/components/ui/progress'
import { SelectedFile } from '@/components/selected-file'

const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.5 }
}

interface FileUploaderProps {
  fileType: 'image' | 'video' | 'audio' | 'ebook' | 'pdf';
  formats: string[];
  apiEndpoint: string;
  storageKey: string;
  isCompression?: boolean;
}

export default function FileUploader({ fileType, formats, apiEndpoint, storageKey, isCompression = false }: FileUploaderProps) {
  const [file, setFile] = useState<File | null>(null)
  const [currentFileType, setCurrentFileType] = useState<string | null>(null)
  const [convertTo, setConvertTo] = useState<string>('')
  const [availableFormats, setAvailableFormats] = useState<string[]>(formats)
  const [isLoading, setIsLoading] = useState(false)
  const [progress, setProgress] = useState(0)
  const router = useRouter()
  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (file) {
      const type = file.type.split('/')[1]
      setCurrentFileType(type)
      setAvailableFormats(formats.filter(format => format !== type))
      setConvertTo('')
    } else {
      setCurrentFileType(null)
      setAvailableFormats(formats)
    }
  }, [file, formats])

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = e.target.files?.[0]
    setFile(selectedFile || null)
  }

  const clearSelection = () => {
    setFile(null);
    setCurrentFileType(null);
    setConvertTo('');
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!file || (!isCompression && !convertTo)) {
      toast({
        title: "Error",
        description: `Please select a ${fileType} ${!isCompression ? 'and conversion format' : ''}.`,
        variant: "destructive",
      })
      return
    }

    setIsLoading(true)
    setProgress(0)
    const formData = new FormData()
    formData.append('file', file)
    if (!isCompression) {
      formData.append('convertTo', convertTo)
    }

    try {
      const response = await fetch(apiEndpoint, {
        method: 'POST',
        body: formData,
      })

      const reader = response.body?.getReader()
      const contentLength = +response.headers.get('Content-Length')!
      let receivedLength = 0

      while(true) {
        const { done, value } = await reader!.read()
        if (done) break
        receivedLength += value.length
        setProgress(Math.round((receivedLength / contentLength) * 100))
      }

      const data = await response.json()

      if (response.ok) {
        toast({
          title: "Success",
          description: `${fileType.charAt(0).toUpperCase() + fileType.slice(1)} ${isCompression ? 'compressed' : 'converted'} successfully!`,
        })
        window.open(data.processedFileUrl, '_blank')
        // Add to conversion/compression history
        const history = JSON.parse(localStorage.getItem(storageKey) || '[]')
        history.unshift({
          originalName: file.name,
          processedTo: isCompression ? `Compressed ${fileType.toUpperCase()}` : convertTo,
          date: new Date().toISOString(),
          url: data.processedFileUrl
        })
        localStorage.setItem(storageKey, JSON.stringify(history.slice(0, 10))) // Keep only last 10 entries
        clearSelection();
        router.refresh();
      } else {
        throw new Error(data.message || `${isCompression ? 'Compression' : 'Conversion'} failed`)
      }
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "An unknown error occurred",
        variant: "destructive",
      })
      clearSelection();
    } finally {
      setIsLoading(false)
      setProgress(0)
    }
  }

  return (
    <motion.div
      variants={fadeInUp}
      initial="initial"
      animate="animate"
    >
      <Card className="w-full">
        <CardHeader className="pb-4">
          <p className="text-sm text-muted-foreground">
            Upload {fileType === 'ebook' ? 'an' : 'a'} {fileType} to compress
            {!isCompression && ' and select the format you want to convert it to'}.
          </p>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit}>
            <div className="space-y-4">
              <motion.div
                className="flex flex-col space-y-1.5"
                variants={fadeInUp}
                transition={{ delay: 0.2 }}
              >
                <Label htmlFor="file">Upload {fileType}</Label>
                <div className="flex h-fit items-center space-x-2">
                  <Input
                    id="file"
                    type="file"
                    accept={`${fileType}/*`}
                    onChange={handleFileChange}
                    disabled={isLoading}
                    className="flex-grow h-fit cursor-pointer file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-primary file:text-primary-foreground hover:file:bg-primary/90"
                    ref={fileInputRef}
                  />
                  {file && (
                    <Button
                      type="button"
                      variant="outline"
                      onClick={clearSelection}
                      disabled={isLoading}
                      className="h-fit"
                    >
                      Clear
                    </Button>
                  )}
                </div>
              </motion.div>
              {file && (
                <motion.div
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 0.3 }}
                >
                  <SelectedFile file={file} fileType={currentFileType} />
                </motion.div>
              )}
              {!isCompression && (
                <motion.div
                  className="flex flex-col space-y-1.5"
                  variants={fadeInUp}
                  transition={{ delay: 0.4 }}
                >
                  <Label htmlFor="format">Convert to</Label>
                  <Select
                    value={convertTo}
                    onValueChange={setConvertTo}
                    disabled={isLoading || !file}
                  >
                    <SelectTrigger id="format">
                      <SelectValue placeholder="Select format" />
                    </SelectTrigger>
                    <SelectContent position="popper">
                      {availableFormats.map((format) => (
                        <SelectItem key={format} value={format}>
                          {format.toUpperCase()}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </motion.div>
              )}
            </div>
          </form>
        </CardContent>
        <CardFooter className="flex flex-col items-stretch space-y-4">
          {isLoading && (
            <motion.div
              className="w-full space-y-2"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
            >
              <Progress value={progress} className="w-full" />
              <p className="text-sm text-center text-muted-foreground">{progress}% complete</p>
            </motion.div>
          )}
          <motion.div
            variants={fadeInUp}
            transition={{ delay: 0.5 }}
          >
            <Button
              type="submit"
              onClick={handleSubmit}
              disabled={isLoading || !file || (!isCompression && !convertTo)}
              className="w-full"
            >
              {isLoading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  {isCompression ? 'Compressing...' : 'Converting...'}
                </>
              ) : (
                `${isCompression ? 'Compress' : 'Convert'} ${fileType}`
              )}
            </Button>
          </motion.div>
        </CardFooter>
      </Card>
    </motion.div>
  )
}

