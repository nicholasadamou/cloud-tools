"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { ArrowRight, Users, Target, Shield } from "lucide-react";
import { PageTransition } from "@/components/page-transition";

const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.5 },
};

export default function AboutPage() {
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
                About Cloud Tools
              </motion.h1>
              <motion.p
                className="text-xl md:text-2xl opacity-90"
                variants={fadeInUp}
                initial="initial"
                animate="animate"
                transition={{ delay: 0.2 }}
              >
                Empowering users with efficient file management solutions
              </motion.p>
            </div>
          </div>
        </motion.section>

        {/* Main Content */}
        <main className="flex-grow bg-background">
          {/* Our Story Section */}
          <motion.section
            className="py-16 md:py-24"
            variants={fadeInUp}
            initial="initial"
            animate="animate"
            transition={{ delay: 0.4 }}
          >
            <div className="container mx-auto px-4">
              <h2 className="text-3xl font-bold text-center mb-8">Our Story</h2>
              <div className="max-w-3xl mx-auto">
                <p className="text-lg mb-6">
                  Cloud Tools was founded in 2025 with a simple mission: to make
                  file conversion and compression accessible to everyone. We
                  recognized the challenges people face when dealing with
                  incompatible file formats or oversized files, and we set out
                  to create a solution that&rsquo;s both powerful and easy to
                  use.
                </p>
                <p className="text-lg mb-6">
                  Our team of passionate developers and designers worked
                  tirelessly to create a suite of cloud-based tools that can
                  handle a wide range of file types and operations. We believe
                  that technology should simplify your life, not complicate it,
                  and that&rsquo;s the principle that guides everything we do.
                </p>
                <p className="text-lg">
                  Today, Cloud Tools serves thousands of users worldwide,
                  helping them convert, compress, and manage their files with
                  ease. We&rsquo;re constantly innovating and expanding our
                  offerings to meet the evolving needs of our users.
                </p>
              </div>
            </div>
          </motion.section>

          {/* Our Values Section */}
          <motion.section
            className="bg-secondary py-16 md:py-24"
            variants={fadeInUp}
            initial="initial"
            animate="animate"
            transition={{ delay: 0.6 }}
          >
            <div className="container mx-auto px-4">
              <h2 className="text-3xl font-bold text-center mb-12">
                Our Values
              </h2>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                <motion.div variants={fadeInUp} transition={{ delay: 0.8 }}>
                  <Card>
                    <CardContent className="p-6 text-center">
                      <Users className="h-12 w-12 text-primary mx-auto mb-4" />
                      <h3 className="text-xl font-semibold mb-2">
                        User-Centric
                      </h3>
                      <p className="text-muted-foreground">
                        We put our users first in everything we do, constantly
                        seeking feedback and improving our tools to meet their
                        needs.
                      </p>
                    </CardContent>
                  </Card>
                </motion.div>
                <motion.div variants={fadeInUp} transition={{ delay: 1 }}>
                  <Card>
                    <CardContent className="p-6 text-center">
                      <Target className="h-12 w-12 text-primary mx-auto mb-4" />
                      <h3 className="text-xl font-semibold mb-2">Innovation</h3>
                      <p className="text-muted-foreground">
                        We&rsquo;re always pushing the boundaries of
                        what&rsquo;s possible, striving to create cutting-edge
                        solutions for file management.
                      </p>
                    </CardContent>
                  </Card>
                </motion.div>
                <motion.div variants={fadeInUp} transition={{ delay: 1.2 }}>
                  <Card>
                    <CardContent className="p-6 text-center">
                      <Shield className="h-12 w-12 text-primary mx-auto mb-4" />
                      <h3 className="text-xl font-semibold mb-2">Security</h3>
                      <p className="text-muted-foreground">
                        We prioritize the security and privacy of our
                        users&rsquo; data, implementing robust measures to
                        protect their files.
                      </p>
                    </CardContent>
                  </Card>
                </motion.div>
              </div>
            </div>
          </motion.section>

          {/* Call to Action */}
          <motion.section
            className="bg-gradient-to-br from-primary to-primary/70 text-primary-foreground py-20"
            variants={fadeInUp}
            initial="initial"
            animate="animate"
            transition={{ delay: 1.4 }}
          >
            <div className="container mx-auto px-4">
              <div className="max-w-4xl mx-auto text-center">
                <h2 className="text-4xl font-bold mb-6">
                  Ready to Transform Your Files?
                </h2>
                <p className="text-xl mb-10 opacity-90">
                  Join thousands of satisfied users and experience the power of
                  Cloud Tools today.
                </p>
                <Link href="/tools/converters/image">
                  <Button
                    size="lg"
                    variant="secondary"
                    className="font-semibold text-primary hover:text-primary bg-secondary hover:bg-secondary-dark transition-colors duration-200 ease-in-out px-8 py-3 shadow-md hover:shadow-lg transform hover:scale-105"
                  >
                    Get Started <ArrowRight className="ml-2 h-5 w-5" />
                  </Button>
                </Link>
              </div>
            </div>
          </motion.section>
        </main>
      </div>
    </PageTransition>
  );
}
