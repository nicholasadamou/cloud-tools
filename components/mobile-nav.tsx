'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  Menu,
  Home,
  PenToolIcon as Tools,
  Info,
  ChevronRight,
  Image,
  Minimize2,
  BookOpen,
  Music,
  Video,
  FileImage,
  FileText,
  RefreshCcw,
  Briefcase,
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from '@/components/ui/sheet';
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from '@/components/ui/accordion';
import { ThemeToggle } from '@/components/theme-toggle';
import { SearchTool } from './search-tool';

const toolCategories = [
  {
    name: 'Converters',
    icon: RefreshCcw,
    subcategories: [
      { name: 'eBooks', href: '/tools/converters/ebooks', icon: BookOpen },
      { name: 'Audio', href: '/tools/converters/audio', icon: Music },
      { name: 'Video', href: '/tools/converters/video', icon: Video },
      { name: 'Image', href: '/tools/converters/image', icon: Image },
    ],
  },
  {
    name: 'Compression',
    icon: Minimize2,
    subcategories: [
      { name: 'Image', href: '/tools/compression/image', icon: FileImage },
      { name: 'PDF', href: '/tools/compression/pdf', icon: FileText },
    ],
  },
];

const navItems = [
  { name: 'Home', href: '/', icon: Home },
  { name: 'Jobs', href: '/jobs', icon: Briefcase },
  { name: 'About', href: '/about', icon: Info },
];

export function MobileNav() {
  const pathname = usePathname();

  return (
    <Sheet>
      <SheetTrigger asChild>
        <Button variant="ghost" size="icon" className="md:hidden">
          <Menu className="h-6 w-6" />
          <span className="sr-only">Toggle mobile navigation</span>
        </Button>
      </SheetTrigger>
      <SheetContent side="left" className="w-[300px] sm:w-[400px]">
        <SheetHeader className="border-b pb-4 mb-4 flex items-center justify-between">
          <SheetTitle className="text-2xl font-bold">Cloud Tools</SheetTitle>
          <SearchTool />
        </SheetHeader>
        <nav className="flex flex-col space-y-4">
          {navItems.map(item => {
            const Icon = item.icon;
            const isActive = pathname === item.href;
            return (
              <Link
                key={item.name}
                href={item.href}
                className={`flex items-center justify-between p-2 rounded-lg transition-colors ${
                  isActive ? 'bg-primary text-primary-foreground' : 'hover:bg-muted'
                }`}
              >
                <div className="flex items-center space-x-4">
                  <Icon className="h-5 w-5" />
                  <span className="text-lg font-medium">{item.name}</span>
                </div>
                <ChevronRight className="h-5 w-5" />
              </Link>
            );
          })}
          <Accordion type="multiple" className="w-full">
            <AccordionItem value="tools">
              <AccordionTrigger className="flex items-center justify-between p-2 rounded-lg transition-colors hover:bg-muted hover:no-underline">
                <div className="flex items-center space-x-4">
                  <Tools className="h-5 w-5" />
                  <span className="text-lg font-medium">Tools</span>
                </div>
              </AccordionTrigger>
              <AccordionContent>
                <div className="pl-4 space-y-2">
                  {toolCategories.map(category => (
                    <Accordion type="single" collapsible className="w-full" key={category.name}>
                      <AccordionItem value={category.name}>
                        <AccordionTrigger className="flex items-center justify-between p-2 rounded-lg transition-colors hover:bg-muted hover:no-underline">
                          <div className="flex items-center space-x-4">
                            <category.icon className="h-4 w-4" />
                            <span className="text-md font-medium">{category.name}</span>
                          </div>
                        </AccordionTrigger>
                        <AccordionContent>
                          <div className="pl-8 space-y-2">
                            {category.subcategories.map(subcategory => (
                              <Link
                                key={subcategory.name}
                                href={subcategory.href}
                                className="flex items-center space-x-2 p-2 rounded-lg transition-colors hover:bg-muted"
                              >
                                <subcategory.icon className="h-4 w-4" />
                                <span>{subcategory.name}</span>
                              </Link>
                            ))}
                          </div>
                        </AccordionContent>
                      </AccordionItem>
                    </Accordion>
                  ))}
                </div>
              </AccordionContent>
            </AccordionItem>
          </Accordion>
        </nav>
        <div className="mt-6 flex items-center justify-between">
          <span className="text-sm font-medium">Switch theme</span>
          <ThemeToggle />
        </div>
      </SheetContent>
    </Sheet>
  );
}
