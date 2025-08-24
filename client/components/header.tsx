import Link from "next/link";
import { Button } from "@/components/ui/button";
import { MobileNav } from "@/components/mobile-nav";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
  DropdownMenuSub,
  DropdownMenuSubTrigger,
  DropdownMenuSubContent,
} from "@/components/ui/dropdown-menu";
import {
  ChevronDown,
  Image,
  Minimize2,
  BookOpen,
  Music,
  Video,
  FileImage,
  FileText,
  RefreshCcw,
} from "lucide-react";
import { SearchTool } from "@/components/search-tool";
import Logo from "@/components/logo";

const toolCategories = [
  {
    name: "Converters",
    icon: RefreshCcw,
    subcategories: [
      { name: "eBooks", href: "/tools/converters/ebooks", icon: BookOpen },
      { name: "Audio", href: "/tools/converters/audio", icon: Music },
      { name: "Video", href: "/tools/converters/video", icon: Video },
      { name: "Image", href: "/tools/converters/image", icon: Image },
    ],
  },
  {
    name: "Compression",
    icon: Minimize2,
    subcategories: [
      { name: "Image", href: "/tools/compression/image", icon: FileImage },
      { name: "PDF", href: "/tools/compression/pdf", icon: FileText },
    ],
  },
];

export default function Header({ children }: { children: React.ReactNode }) {
  return (
    <header className="bg-background border-b border-border sticky top-0 z-50 shadow-sm">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center py-4">
          <div className="flex items-center">
            <Logo />
            <nav className="hidden md:flex items-center ml-6 space-x-4">
              <SearchTool />
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button variant="ghost" className="flex items-center">
                    Tools
                    <ChevronDown className="ml-1 h-4 w-4" />
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent className="w-56">
                  <DropdownMenuLabel>Tools</DropdownMenuLabel>
                  <DropdownMenuSeparator />
                  {toolCategories.map((category) => {
                    const Icon = category.icon;
                    return (
                      <DropdownMenuSub key={category.name}>
                        <DropdownMenuSubTrigger>
                          <Icon className="mr-2 h-4 w-4" />
                          <span>{category.name}</span>
                        </DropdownMenuSubTrigger>
                        <DropdownMenuSubContent className="w-48">
                          {category.subcategories.map((subcategory) => {
                            const SubIcon = subcategory.icon;
                            return (
                              <DropdownMenuItem key={subcategory.name} asChild>
                                <Link
                                  href={subcategory.href}
                                  className="w-full flex items-center"
                                >
                                  <SubIcon className="mr-2 h-4 w-4" />
                                  <span>{subcategory.name}</span>
                                </Link>
                              </DropdownMenuItem>
                            );
                          })}
                        </DropdownMenuSubContent>
                      </DropdownMenuSub>
                    );
                  })}
                </DropdownMenuContent>
              </DropdownMenu>
              <Link
                href="/about"
                className="text-sm hover:text-muted-foreground text-foreground transition-colors"
              >
                About
              </Link>
            </nav>
          </div>
          <div className="flex items-center space-x-4">
            <div className="md:hidden">
              <span className="mr-1">{children}</span>
              <MobileNav />
            </div>
            <div className="hidden md:block">{children}</div>
          </div>
        </div>
      </div>
    </header>
  );
}
