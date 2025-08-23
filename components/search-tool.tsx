'use client';

import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from '@/components/ui/command';
import { Dialog, DialogContent } from '@/components/ui/dialog';
import { Image, FileAudio, FileVideo, BookOpen, FileImage, FileText } from 'lucide-react';

interface Tool {
  name: string;
  href: string;
  icon: React.ComponentType;
  keywords?: string[];
}

const allTools: Tool[] = [
  {
    name: 'Image Converter',
    href: '/tools/converters/image',
    icon: Image,
    keywords: ['image', 'convert', 'jpg', 'png', 'webp', 'gif'],
  },
  {
    name: 'Audio Converter',
    href: '/tools/converters/audio',
    icon: FileAudio,
    keywords: ['audio', 'convert', 'mp3', 'wav', 'ogg', 'flac'],
  },
  {
    name: 'Video Converter',
    href: '/tools/converters/video',
    icon: FileVideo,
    keywords: ['video', 'convert', 'mp4', 'mov', 'avi', 'webm'],
  },
  {
    name: 'eBook Converter',
    href: '/tools/converters/ebooks',
    icon: BookOpen,
    keywords: ['ebook', 'convert', 'epub', 'mobi', 'pdf', 'azw3'],
  },
  {
    name: 'Image Compression',
    href: '/tools/compression/image',
    icon: FileImage,
    keywords: ['image', 'compress', 'jpg', 'png', 'webp', 'gif'],
  },
  {
    name: 'PDF Compression',
    href: '/tools/compression/pdf',
    icon: FileText,
    keywords: ['pdf', 'compress'],
  },
];

export function SearchTool() {
  const router = useRouter();
  const [open, setOpen] = useState(false);

  useEffect(() => {
    const down = (e: KeyboardEvent) => {
      if (e.key === 'k' && (e.metaKey || e.ctrlKey)) {
        e.preventDefault();
        setOpen(open => !open);
      }
    };
    document.addEventListener('keydown', down);
    return () => document.removeEventListener('keydown', down);
  }, []);

  return (
    <>
      <Button
        variant="outline"
        className="relative w-full justify-start text-sm text-muted-foreground sm:pr-12 md:w-40 lg:w-64"
        onClick={() => setOpen(true)}
      >
        <span className="hidden lg:inline-flex">Search tools...</span>
        <span className="inline-flex lg:hidden">Search...</span>
        <kbd className="pointer-events-none absolute right-1.5 top-1/2 transform -translate-y-1/2 hidden h-5 select-none items-center gap-1 rounded border bg-muted px-1.5 font-mono text-[10px] font-medium opacity-100 sm:flex">
          <span className="text-xs">⌘</span>K
        </kbd>
      </Button>
      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="p-0">
          <Command className="rounded-lg border shadow-md">
            <CommandInput placeholder="Type a command or search..." />
            <CommandList>
              <CommandEmpty>No results found.</CommandEmpty>
              <CommandGroup heading="Tools">
                {allTools.map(tool => (
                  <CommandItem
                    key={tool.href}
                    onSelect={() => {
                      router.push(tool.href);
                      setOpen(false);
                    }}
                  >
                    <div className="flex items-center">
                      {/* @ts-expect-error tool.icon may not have correct React component type */}
                      {React.createElement(tool.icon, { className: 'mr-2 h-4 w-4' })}
                      <span>{tool.name}</span>
                    </div>
                  </CommandItem>
                ))}
              </CommandGroup>
            </CommandList>
          </Command>
        </DialogContent>
      </Dialog>
    </>
  );
}
