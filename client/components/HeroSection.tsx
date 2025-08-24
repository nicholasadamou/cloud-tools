"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import React from "react";

const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.5 },
};

export const HeroSection: React.FC = () => {
  return (
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
            Transform Your Files with Cloud Tools
          </motion.h1>
          <motion.p
            className="text-xl md:text-2xl mb-10 opacity-90"
            variants={fadeInUp}
            initial="initial"
            animate="animate"
            transition={{ delay: 0.2 }}
          >
            Effortlessly convert and compress your files in the cloud
          </motion.p>
          <motion.div
            className="flex flex-col sm:flex-row justify-center space-y-4 sm:space-y-0 sm:space-x-4"
            variants={fadeInUp}
            initial="initial"
            animate="animate"
            transition={{ delay: 0.4 }}
          >
            <Link href="/services">
              <Button
                size="lg"
                variant="secondary"
                className="w-full sm:w-auto"
              >
                Explore Services
              </Button>
            </Link>
            <Link href="/tools/converters/image">
              <Button
                size="lg"
                variant="secondary"
                className="w-full sm:w-auto text-secondary hover:text-foreground bg-primary-foreground/10"
              >
                Start Converting
              </Button>
            </Link>
          </motion.div>
        </div>
      </div>
    </motion.section>
  );
};
