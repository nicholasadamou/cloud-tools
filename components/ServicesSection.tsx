'use client';

import { motion } from 'framer-motion';
import {
  ArrowRight,
  BookOpen,
  FileAudio,
  FileIcon as FileConvert,
  FileText,
  FileVideo,
  Image,
  Minimize2,
} from 'lucide-react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import React from 'react';

type Tool = {
  name: string;
  icon: React.ComponentType<{ className?: string }>;
  href: string;
};

type Service = {
  title: string;
  description: string;
  icon: React.ComponentType<{ className?: string }>;
  tools: Tool[];
  allToolsLink: string;
};

const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
};

const staggerChildren = {
  animate: {
    transition: {
      staggerChildren: 0.1,
    },
  },
};

const ServiceCard: React.FC<Service> = ({
  title,
  description,
  icon: Icon,
  tools,
  allToolsLink,
}) => (
  <motion.div variants={fadeInUp}>
    <Card className="h-full flex flex-col">
      <CardHeader>
        <CardTitle className="flex items-center text-2xl font-semibold">
          <Icon className="mr-3 h-8 w-8 text-primary" />
          {title}
        </CardTitle>
        <CardDescription>{description}</CardDescription>
      </CardHeader>
      <CardContent className="flex-grow">
        <div className="grid grid-cols-2 gap-4">
          {tools.map((tool, index) => (
            <Link
              key={index}
              href={tool.href}
              className="group flex items-center text-sm text-muted-foreground hover:text-primary transition-colors"
            >
              <tool.icon className="mr-2 h-4 w-4 transition-transform group-hover:scale-110" />
              {tool.name}
            </Link>
          ))}
        </div>
      </CardContent>
      <CardFooter>
        <Link href={allToolsLink} className="w-full">
          <Button className="w-full group">
            All {title} Tools
            <ArrowRight className="ml-2 transition-transform group-hover:translate-x-1" />
          </Button>
        </Link>
      </CardFooter>
    </Card>
  </motion.div>
);

export function ServicesSection() {
  const services: Service[] = [
    {
      title: 'File Conversion',
      description:
        'Convert your files to various formats with ease. Support for images, documents, audio, and more.',
      icon: FileConvert,
      tools: [
        { name: 'Image Converter', icon: Image, href: '/tools/converters/image' },
        { name: 'Audio Converter', icon: FileAudio, href: '/tools/converters/audio' },
        { name: 'Video Converter', icon: FileVideo, href: '/tools/converters/video' },
        { name: 'eBook Converter', icon: BookOpen, href: '/tools/converters/ebooks' },
      ],
      allToolsLink: '/tools/converters',
    },
    {
      title: 'File Compression',
      description:
        'Reduce file sizes without compromising quality. Perfect for images, PDFs, and more.',
      icon: Minimize2,
      tools: [
        { name: 'Image Compression', icon: FileConvert, href: '/tools/compression/image' },
        { name: 'PDF Compression', icon: FileText, href: '/tools/compression/pdf' },
      ],
      allToolsLink: '/tools/compression',
    },
  ];

  return (
    <section id="services" className="bg-background py-16">
      <div className="container mx-auto px-4">
        <motion.h2
          className="text-4xl font-bold text-center mb-8"
          variants={fadeInUp}
          initial="initial"
          animate="animate"
        >
          Our Services
        </motion.h2>
        <motion.div
          className="grid grid-cols-1 md:grid-cols-2 gap-8"
          variants={staggerChildren}
          initial="initial"
          animate="animate"
        >
          {services.map((service, index) => (
            <ServiceCard key={index} {...service} />
          ))}
        </motion.div>
      </div>
    </section>
  );
}
