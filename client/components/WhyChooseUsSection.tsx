"use client";

import { motion } from "framer-motion";
import { Zap, Lock, Cloud } from "lucide-react";
import React from "react";

const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.5 },
};

export const WhyChooseUsSection: React.FC = () => {
  return (
    <section className="bg-secondary py-24">
      <div className="container mx-auto px-4">
        <motion.h2
          className="text-3xl font-bold text-center mb-12"
          variants={fadeInUp}
          initial="initial"
          animate="animate"
        >
          Why Choose Cloud Tools?
        </motion.h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-12">
          <motion.div
            className="text-center"
            variants={fadeInUp}
            initial="initial"
            animate="animate"
            transition={{ delay: 0.2 }}
          >
            <div className="bg-background/50 rounded-full p-6 inline-block mb-6">
              <Zap className="h-12 w-12 text-primary" />
            </div>
            <h3 className="text-xl font-semibold mb-3">Fast Processing</h3>
            <p className="text-muted-foreground">
              Our cloud-based tools ensure quick and efficient file processing.
            </p>
          </motion.div>
          <motion.div
            className="text-center"
            variants={fadeInUp}
            initial="initial"
            animate="animate"
            transition={{ delay: 0.4 }}
          >
            <div className="bg-background/50 rounded-full p-6 inline-block mb-6">
              <Lock className="h-12 w-12 text-primary" />
            </div>
            <h3 className="text-xl font-semibold mb-3">Secure & Private</h3>
            <p className="text-muted-foreground">
              Your files are encrypted and automatically deleted after
              processing.
            </p>
          </motion.div>
          <motion.div
            className="text-center"
            variants={fadeInUp}
            initial="initial"
            animate="animate"
            transition={{ delay: 0.6 }}
          >
            <div className="bg-background/50 rounded-full p-6 inline-block mb-6">
              <Cloud className="h-12 w-12 text-primary" />
            </div>
            <h3 className="text-xl font-semibold mb-3">Cloud-Powered</h3>
            <p className="text-muted-foreground">
              Access our tools from anywhere, on any device with internet
              access.
            </p>
          </motion.div>
        </div>
      </div>
    </section>
  );
};
