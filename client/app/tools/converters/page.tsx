"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  ArrowRight,
  Image,
  FileAudio,
  FileVideo,
  BookOpen,
} from "lucide-react";
import { PageTransition } from "@/components/page-transition";

const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.5 },
};

const staggeredFadeIn = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.5, staggerChildren: 0.1 },
};

const converters = [
  {
    title: "Image Converter",
    description:
      "Convert images between various formats like JPG, PNG, WebP, and GIF.",
    icon: Image,
    href: "/tools/converters/image",
  },
  {
    title: "Audio Converter",
    description:
      "Convert audio files to different formats including MP3, WAV, OGG, and FLAC.",
    icon: FileAudio,
    href: "/tools/converters/audio",
  },
  {
    title: "Video Converter",
    description:
      "Convert video files to popular formats such as MP4, MOV, AVI, and WebM.",
    icon: FileVideo,
    href: "/tools/converters/video",
  },
  {
    title: "eBook Converter",
    description:
      "Convert eBooks between formats like EPUB, MOBI, PDF, and AZW3.",
    icon: BookOpen,
    href: "/tools/converters/ebooks",
  },
];

export default function ConvertersPage() {
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
                File Converters
              </motion.h1>
              <motion.p
                className="text-xl md:text-2xl opacity-90"
                variants={fadeInUp}
                initial="initial"
                animate="animate"
                transition={{ delay: 0.2 }}
              >
                Convert your files to various formats with ease
              </motion.p>
            </div>
          </div>
        </motion.section>

        {/* Main Content */}
        <main className="flex-grow bg-background">
          {/* Converters Section */}
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
                {converters.map((converter, index) => (
                  <motion.div key={index} variants={fadeInUp}>
                    <Card className="h-full flex flex-col">
                      <CardHeader>
                        <CardTitle className="flex items-center text-2xl font-bold">
                          <converter.icon className="h-8 w-8 mr-3 text-primary" />
                          {converter.title}
                        </CardTitle>
                      </CardHeader>
                      <CardContent className="flex-grow flex flex-col justify-between">
                        <p className="text-muted-foreground mb-4">
                          {converter.description}
                        </p>
                        <Link href={converter.href}>
                          <Button className="w-full mt-4">
                            Go to {converter.title}{" "}
                            <ArrowRight className="ml-2 h-4 w-4" />
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
                Ready to convert your files?
              </motion.h2>
              <motion.p
                className="text-xl mb-8 text-muted-foreground"
                variants={fadeInUp}
              >
                Choose a converter above to get started, or explore our other
                tools.
              </motion.p>
              <motion.div variants={fadeInUp}>
                <Link href="/tools/compression">
                  <Button size="lg" className="font-semibold">
                    Explore Compression Tools{" "}
                    <ArrowRight className="ml-2 h-5 w-5" />
                  </Button>
                </Link>
              </motion.div>
            </div>
          </motion.section>
        </main>
      </div>
    </PageTransition>
  );
}
