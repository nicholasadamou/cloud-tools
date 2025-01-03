'use client'

import Link from 'next/link'
import { motion } from 'framer-motion'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { ArrowRight, FileIcon as FileConvert, Minimize2, Image, FileAudio, FileVideo, BookOpen, FileImage, FileText } from 'lucide-react'
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

export default function ServicesPage() {
  const services = [
    {
      icon: FileConvert,
      title: "File Conversion",
      description: "Convert your files to various formats with ease. Support for images, documents, audio, and more.",
      items: [
        { name: 'Image Converter', icon: Image, href: '/tools/converters/image' },
        { name: 'Audio Converter', icon: FileAudio, href: '/tools/converters/audio' },
        { name: 'Video Converter', icon: FileVideo, href: '/tools/converters/video' },
        { name: 'eBook Converter', icon: BookOpen, href: '/tools/converters/ebooks' },
      ]
    },
    {
      icon: Minimize2,
      title: "File Compression",
      description: "Reduce file sizes without compromising quality. Perfect for images, PDFs, and more.",
      items: [
        { name: 'Image Compression', icon: FileImage, href: '/tools/compression/image' },
        { name: 'PDF Compression', icon: FileText, href: '/tools/compression/pdf' },
      ]
    },
  ]

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
                Our Services
              </motion.h1>
              <motion.p
                className="text-xl md:text-2xl opacity-90"
                variants={fadeInUp}
                initial="initial"
                animate="animate"
                transition={{ delay: 0.2 }}
              >
                Discover our powerful file conversion and compression tools
              </motion.p>
            </div>
          </div>
        </motion.section>

        {/* Main Content */}
        <main className="bg-background">
          {/* Services Section */}
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
                {services.map((service, index) => (
                  <motion.div key={index} variants={fadeInUp}>
                    <Card className="h-full flex flex-col">
                      <CardHeader>
                        <CardTitle className="flex items-center text-2xl font-bold">
                          <service.icon className="h-8 w-8 mr-3 text-primary" />
                          {service.title}
                        </CardTitle>
                      </CardHeader>
                      <CardContent className="flex-grow">
                        <p className="text-muted-foreground mb-4">{service.description}</p>
                        <div className="grid grid-cols-2 gap-4">
                          {service.items.map((item, itemIndex) => (
                            <Link key={itemIndex} href={item.href} className="flex items-center text-sm text-secondary-foreground hover:underline">
                              <item.icon className="mr-2 h-4 w-4" /> {item.name}
                            </Link>
                          ))}
                        </div>
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
                Ready to get started?
              </motion.h2>
              <motion.p
                className="text-xl mb-8 text-muted-foreground"
                variants={fadeInUp}
              >
                Try our file conversion and compression tools today.
              </motion.p>
              <motion.div variants={fadeInUp}>
                <Link href="/tools/converters/image">
                  <Button size="lg" className="font-semibold">
                    Start Converting <ArrowRight className="ml-2 h-5 w-5" />
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

