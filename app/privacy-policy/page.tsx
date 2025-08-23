'use client';

import Link from 'next/link';
import { motion } from 'framer-motion';
import { Button } from '@/components/ui/button';
import { ArrowRight } from 'lucide-react';
import { PageTransition } from '@/components/page-transition';

const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.5 },
};

export default function PrivacyPolicyPage() {
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
                Privacy Policy
              </motion.h1>
              <motion.p
                className="text-xl md:text-2xl opacity-90"
                variants={fadeInUp}
                initial="initial"
                animate="animate"
                transition={{ delay: 0.2 }}
              >
                How we collect, use, and protect your information
              </motion.p>
            </div>
          </div>
        </motion.section>

        {/* Main Content */}
        <main className="flex-grow bg-background">
          <motion.section
            className="py-16 md:py-24"
            variants={fadeInUp}
            initial="initial"
            animate="animate"
            transition={{ delay: 0.4 }}
          >
            <div className="container mx-auto px-4">
              <div className="max-w-3xl mx-auto space-y-8">
                <motion.h2
                  className="text-3xl font-bold"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 0.6 }}
                >
                  1. Information We Collect
                </motion.h2>
                <motion.p
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 0.7 }}
                >
                  We collect information you provide directly to us when using our services,
                  including:
                </motion.p>
                <motion.ul
                  className="list-disc pl-6 space-y-2"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 0.8 }}
                >
                  <li>
                    Personal information (e.g., name, email address) when you create an account
                  </li>
                  <li>Files you upload for conversion or compression</li>
                  <li>Usage data and analytics information</li>
                </motion.ul>

                <motion.h2
                  className="text-3xl font-bold"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 0.9 }}
                >
                  2. How We Use Your Information
                </motion.h2>
                <motion.p
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1 }}
                >
                  We use the information we collect to:
                </motion.p>
                <motion.ul
                  className="list-disc pl-6 space-y-2"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1.1 }}
                >
                  <li>Provide, maintain, and improve our services</li>
                  <li>Process your file conversions and compressions</li>
                  <li>Send you technical notices, updates, and support messages</li>
                  <li>Respond to your comments and questions</li>
                </motion.ul>

                <motion.h2
                  className="text-3xl font-bold"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1.2 }}
                >
                  3. Data Security
                </motion.h2>
                <motion.p
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1.3 }}
                >
                  We implement appropriate technical and organizational measures to protect your
                  personal information, including encryption of data in transit and at rest.
                  However, no method of transmission over the Internet or electronic storage is 100%
                  secure, so we cannot guarantee absolute security.
                </motion.p>

                <motion.h2
                  className="text-3xl font-bold"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1.4 }}
                >
                  4. Data Retention
                </motion.h2>
                <motion.p
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1.5 }}
                >
                  We retain your personal information only for as long as necessary to fulfill the
                  purposes for which we collected it, including for the purposes of satisfying any
                  legal, accounting, or reporting requirements.
                </motion.p>

                <motion.h2
                  className="text-3xl font-bold"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1.6 }}
                >
                  5. Your Rights
                </motion.h2>
                <motion.p
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1.7 }}
                >
                  Depending on your location, you may have certain rights regarding your personal
                  information, including:
                </motion.p>
                <motion.ul
                  className="list-disc pl-6 space-y-2"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1.8 }}
                >
                  <li>The right to access your personal information</li>
                  <li>The right to rectify inaccurate personal information</li>
                  <li>The right to erase your personal information</li>
                  <li>The right to restrict processing of your personal information</li>
                </motion.ul>

                <motion.h2
                  className="text-3xl font-bold"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1.9 }}
                >
                  6. Changes to This Privacy Policy
                </motion.h2>
                <motion.p
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 2 }}
                >
                  We may update this Privacy Policy from time to time. We will notify you of any
                  changes by posting the new Privacy Policy on this page and updating the
                  &ldquo;Last updated&rdquo; date at the top of this Privacy Policy.
                </motion.p>

                <motion.h2
                  className="text-3xl font-bold"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 2.1 }}
                >
                  7. Contact Us
                </motion.h2>
                <motion.p
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 2.2 }}
                >
                  If you have any questions about this Privacy Policy, please contact us at:
                </motion.p>
                <motion.p
                  className="font-semibold"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 2.3 }}
                >
                  privacy@cloudtools.com
                </motion.p>
              </div>
            </div>
          </motion.section>

          {/* Call to Action */}
          <motion.section
            className="bg-secondary py-16"
            variants={fadeInUp}
            initial="initial"
            animate="animate"
            transition={{ delay: 2.4 }}
          >
            <div className="container mx-auto px-4 text-center">
              <h2 className="text-3xl font-bold mb-6">Ready to get started?</h2>
              <p className="text-xl mb-8 text-muted-foreground">
                Try our file conversion and compression tools today.
              </p>
              <Link href="/tools/converters/image">
                <Button size="lg" className="font-semibold">
                  Get Started <ArrowRight className="ml-2 h-5 w-5" />
                </Button>
              </Link>
            </div>
          </motion.section>
        </main>
      </div>
    </PageTransition>
  );
}
