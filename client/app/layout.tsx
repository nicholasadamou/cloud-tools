import React from "react";
import { Inter } from "next/font/google";
import { Toaster } from "@/components/ui/toaster";
import Header from "@/components/header";
import Footer from "@/components/footer";
import { ThemeProvider } from "@/components/theme-provider";
import { ThemeToggle } from "@/components/theme-toggle";
import { AnimatePresence } from "framer-motion";

import "@/styles/globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata = {
  title: "Cloud - Cloud Tools for Developers",
  description:
    "Cloud is a collection of tools for developers to help them build better applications.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body
        className={`${inter.className} flex flex-col min-h-screen`}
        suppressHydrationWarning
      >
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          <Header>
            <ThemeToggle />
          </Header>
          <AnimatePresence mode="wait">
            <main className="bg-secondary flex-grow">{children}</main>
          </AnimatePresence>
          <Footer />
          <Toaster />
        </ThemeProvider>
      </body>
    </html>
  );
}
