'use client'

import Link from 'next/link'
import { motion } from 'framer-motion'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { ArrowRight, Zap, Lock, Cloud, Repeat, Minimize2, Smartphone, Globe } from 'lucide-react'
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

export default function FeaturesPage() {
  const features = [
    {
      icon: Repeat,
      title: "File Conversion",
      description: "Convert files between various formats with ease. Support for images, documents, audio, and more."
    },
    {
      icon: Minimize2,
      title: "File Compression",
      description: "Reduce file sizes without compromising quality. Perfect for images, PDFs, and other large files."
    },
    {
      icon: Zap,
      title: "Fast Processing",
      description: "Experience lightning-fast file processing with our optimized cloud infrastructure."
    },
    {
      icon: Lock,
      title: "Secure & Private",
      description: "Your files are encrypted during transfer and automatically deleted after processing."
    },
    {
      icon: Cloud,
      title: "Cloud-Powered",
      description: "Access our tools from anywhere, on any device with internet access."
    },
    {
      icon: Smartphone,
      title: "Mobile Friendly",
      description: "Our responsive design ensures a seamless experience on smartphones and tablets."
    },
    {
      icon: Globe,
      title: "Multiple Languages",
      description: "Support for multiple languages to serve users from around the world."
    },
    {
      icon: ArrowRight,
      title: "Batch Processing",
      description: "Convert or compress multiple files at once to save time and effort."
    }
  ]

  return (
    <PageTransition>
      <div className="flex flex-col min-h-screen">
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
                Powerful Features for File Management
              </motion.h1>
              <motion.p
                className="text-xl md:text-2xl opacity-90"
                variants={fadeInUp}
                initial="initial"
                animate="animate"
                transition={{ delay: 0.2 }}
              >
                Discover the tools that make Cloud Tools the best choice for file conversion and compression
              </motion.p>
            </div>
          </div>
        </motion.section>

        {/* Main Content */}
        <main className="flex-grow bg-background">
          {/* Features Grid */}
          <motion.section
            className="py-16 md:py-24"
            variants={staggeredFadeIn}
            initial="initial"
            animate="animate"
          >
            <div className="container mx-auto px-4">
              <motion.div
                className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8"
                variants={staggeredFadeIn}
              >
                {features.map((feature, index) => (
                  <motion.div key={index} variants={fadeInUp}>
                    <Card>
                      <CardHeader>
                        <CardTitle className="flex items-center text-2xl font-bold">
                          <feature.icon className="h-8 w-8 mr-3 text-primary" />
                          {feature.title}
                        </CardTitle>
                      </CardHeader>
                      <CardContent>
                        <p className="text-muted-foreground">{feature.description}</p>
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
                Ready to experience these features?
              </motion.h2>
              <motion.p
                className="text-xl mb-8 text-muted-foreground"
                variants={fadeInUp}
              >
                Start converting and compressing your files with Cloud Tools today.
              </motion.p>
              <motion.div variants={fadeInUp}>
                <Link href="/tools/converters/image">
                  <Button size="lg" className="font-semibold">
                    Get Started <ArrowRight className="ml-2 h-5 w-5" />
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

