'use client'

import Link from 'next/link'
import { motion } from 'framer-motion'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { ArrowRight, FileImage, FileText } from 'lucide-react'
import { PageTransition } from '@/components/page-transition'

const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.5 }
}

const staggeredFadeIn = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.5, staggerChildren: 0.1 }
}

const compressionTools = [
  {
    title: "Image Compression",
    description: "Reduce the file size of your images without compromising quality.",
    icon: FileImage,
    href: "/tools/compression/image"
  },
  {
    title: "PDF Compression",
    description: "Compress PDF files to reduce their size while maintaining readability.",
    icon: FileText,
    href: "/tools/compression/pdf"
  }
]

export default function CompressionPage() {
  return (
    <PageTransition>
      <div className="flex flex-col">
        {/* Hero Section */}
        <motion.section
          className="bg-gradient-to-br from-primary to-primary/70 text-primary-foreground py-24 md:py-32"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.8 }}
        >
          <div className="container mx-auto px-4">
            <div className="max-w-3xl mx-auto text-center">
              <motion.h1
                className="text-5xl md:text-6xl font-extrabold mb-6 leading-tight"
                variants={fadeInUp}
                initial="initial"
                animate="animate"
              >
                File Compression
              </motion.h1>
              <motion.p
                className="text-xl md:text-2xl opacity-90"
                variants={fadeInUp}
                initial="initial"
                animate="animate"
                transition={{ delay: 0.2 }}
              >
                Reduce file sizes without compromising quality
              </motion.p>
            </div>
          </div>
        </motion.section>

        {/* Main Content */}
        <main className="flex-grow bg-background">
          {/* Compression Tools Section */}
          <motion.section
            className="py-16 md:py-24"
            variants={staggeredFadeIn}
            initial="initial"
            animate="animate"
          >
            <div className="container mx-auto px-4">
              <motion.div
                className="grid grid-cols-1 md:grid-cols-2 gap-8"
                variants={staggeredFadeIn}
              >
                {compressionTools.map((tool, index) => (
                  <motion.div key={index} variants={fadeInUp}>
                    <Card className="h-full flex flex-col">
                      <CardHeader>
                        <CardTitle className="flex items-center text-2xl font-bold">
                          <tool.icon className="h-8 w-8 mr-3 text-primary" />
                          {tool.title}
                        </CardTitle>
                      </CardHeader>
                      <CardContent className="flex-grow flex flex-col justify-between">
                        <p className="text-muted-foreground mb-4">{tool.description}</p>
                        <Link href={tool.href}>
                          <Button className="w-full mt-4">
                            Go to {tool.title} <ArrowRight className="ml-2 h-4 w-4" />
                          </Button>
                        </Link>
                      </CardContent>
                    </Card>
                  </motion.div>
                ))}
              </motion.div>
            </div>
          </motion.section>

          {/* Call to Action */}
          <motion.section
            className="bg-secondary py-16"
            variants={fadeInUp}
            initial="initial"
            animate="animate"
            transition={{ delay: 0.4 }}
          >
            <div className="container mx-auto px-4 text-center">
              <motion.h2
                className="text-3xl font-bold mb-6"
                variants={fadeInUp}
              >
                Need to compress your files?
              </motion.h2>
              <motion.p
                className="text-xl mb-8 text-muted-foreground"
                variants={fadeInUp}
              >
                Choose a compression tool above to get started, or explore our other services.
              </motion.p>
              <motion.div variants={fadeInUp}>
                <Link href="/tools/converters">
                  <Button size="lg" className="font-semibold">
                    Explore Conversion Tools <ArrowRight className="ml-2 h-5 w-5" />
                  </Button>
                </Link>
              </motion.div>
            </div>
          </motion.section>
        </main>
      </div>
    </PageTransition>
  )
}

