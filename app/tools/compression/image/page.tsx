'use client'

import { motion } from 'framer-motion'
import FileUploader from '@/components/file-uploader'
import ConversionHistory from '@/components/conversion-history'
import { PageTransition } from '@/components/page-transition'
import { ToolSwitcher } from '@/components/tool-switcher'

const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.5 }
}

const imageFormats = ['jpg', 'png', 'webp', 'gif']

export default function ImageCompressionPage() {
  return (
    <PageTransition>
      <motion.div 
        className="bg-secondary container mx-auto px-4 py-8"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.8 }}
      >
        <motion.h1 
          className="text-4xl font-bold mb-8 text-center"
          variants={fadeInUp}
          initial="initial"
          animate="animate"
        >
          Image Compression
        </motion.h1>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          <motion.div
            variants={fadeInUp}
            initial="initial"
            animate="animate"
            transition={{ delay: 0.2 }}
          >
            <h2 className="text-2xl font-semibold mb-4">Compress Image</h2>
            <FileUploader 
              fileType="image"
              formats={imageFormats}
              apiEndpoint="https://your-api-gateway-url.amazonaws.com/compress-image"
              storageKey="imageCompressionHistory"
              isCompression
            />
            <motion.div
              variants={fadeInUp}
              initial="initial"
              animate="animate"
              transition={{ delay: 0.1 }}
              className="mb-8"
            >
              <ToolSwitcher />
            </motion.div>
          </motion.div>
          <motion.div
            variants={fadeInUp}
            initial="initial"
            animate="animate"
            transition={{ delay: 0.4 }}
          >
            <h2 className="text-2xl font-semibold mb-4">Compression History</h2>
            <ConversionHistory storageKey="imageCompressionHistory" />
          </motion.div>
        </div>
      </motion.div>
    </PageTransition>
  )
}

