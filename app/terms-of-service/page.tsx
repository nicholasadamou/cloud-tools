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

export default function TermsOfServicePage() {
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
                Terms of Service
              </motion.h1>
              <motion.p
                className="text-xl md:text-2xl opacity-90"
                variants={fadeInUp}
                initial="initial"
                animate="animate"
                transition={{ delay: 0.2 }}
              >
                Please read these terms carefully before using our services
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
                  1. Acceptance of Terms
                </motion.h2>
                <motion.p
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 0.7 }}
                >
                  By accessing or using Cloud Tools services, you agree to be bound by these Terms
                  of Service and all applicable laws and regulations. If you do not agree with any
                  part of these terms, you may not use our services.
                </motion.p>

                <motion.h2
                  className="text-3xl font-bold"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 0.8 }}
                >
                  2. Description of Service
                </motion.h2>
                <motion.p
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 0.9 }}
                >
                  Cloud Tools provides online file conversion and compression services. We reserve
                  the right to modify, suspend, or discontinue any part of the service at any time
                  without notice.
                </motion.p>

                <motion.h2
                  className="text-3xl font-bold"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1 }}
                >
                  3. User Responsibilities
                </motion.h2>
                <motion.p
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1.1 }}
                >
                  You are responsible for:
                </motion.p>
                <motion.ul
                  className="list-disc pl-6 space-y-2"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1.2 }}
                >
                  <li>Maintaining the confidentiality of your account information</li>
                  <li>All activities that occur under your account</li>
                  <li>
                    Ensuring that your use of the service does not violate any applicable laws or
                    regulations
                  </li>
                </motion.ul>

                <motion.h2
                  className="text-3xl font-bold"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1.3 }}
                >
                  4. Intellectual Property Rights
                </motion.h2>
                <motion.p
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1.4 }}
                >
                  You retain all rights to the content you upload to our service. By using our
                  service, you grant us a worldwide, non-exclusive license to use, store, and
                  process your content solely for the purpose of providing our services to you.
                </motion.p>

                <motion.h2
                  className="text-3xl font-bold"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1.5 }}
                >
                  5. Prohibited Uses
                </motion.h2>
                <motion.p
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1.6 }}
                >
                  You agree not to use the service to:
                </motion.p>
                <motion.ul
                  className="list-disc pl-6 space-y-2"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1.7 }}
                >
                  <li>
                    Upload, transmit, or distribute any content that is unlawful, harmful,
                    threatening, abusive, or infringing on any third party rights
                  </li>
                  <li>
                    Impersonate any person or entity or falsely state or misrepresent your
                    affiliation with a person or entity
                  </li>
                  <li>
                    Interfere with or disrupt the service or servers or networks connected to the
                    service
                  </li>
                </motion.ul>

                <motion.h2
                  className="text-3xl font-bold"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1.8 }}
                >
                  6. Limitation of Liability
                </motion.h2>
                <motion.p
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 1.9 }}
                >
                  To the fullest extent permitted by applicable law, Cloud Tools shall not be liable
                  for any indirect, incidental, special, consequential, or punitive damages, or any
                  loss of profits or revenues, whether incurred directly or indirectly, or any loss
                  of data, use, goodwill, or other intangible losses resulting from your use of our
                  service.
                </motion.p>

                <motion.h2
                  className="text-3xl font-bold"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 2 }}
                >
                  7. Changes to Terms
                </motion.h2>
                <motion.p
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 2.1 }}
                >
                  We reserve the right to modify these Terms of Service at any time. We will notify
                  users of any significant changes by posting a notice on our website or sending an
                  email.
                </motion.p>

                <motion.h2
                  className="text-3xl font-bold"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 2.2 }}
                >
                  8. Governing Law
                </motion.h2>
                <motion.p
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 2.3 }}
                >
                  These Terms of Service shall be governed by and construed in accordance with the
                  laws of [Your Jurisdiction], without regard to its conflict of law provisions.
                </motion.p>

                <motion.h2
                  className="text-3xl font-bold"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 2.4 }}
                >
                  9. Contact Us
                </motion.h2>
                <motion.p
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 2.5 }}
                >
                  If you have any questions about these Terms of Service, please contact us at:
                </motion.p>
                <motion.p
                  className="font-semibold"
                  variants={fadeInUp}
                  initial="initial"
                  animate="animate"
                  transition={{ delay: 2.6 }}
                >
                  legal@cloudtools.com
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
            transition={{ delay: 2.7 }}
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
